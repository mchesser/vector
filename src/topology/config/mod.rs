use crate::{event::Event, sinks, sources, transforms};
use futures::sync::mpsc;
use indexmap::IndexMap; // IndexMap preserves insertion order, allowing us to output errors in the same order they are present in the file
use serde::{Deserialize, Serialize};
use snafu::{ResultExt, Snafu};
use std::fs::DirBuilder;
use std::{collections::HashMap, path::PathBuf};

mod validation;
mod vars;

#[derive(Deserialize, Serialize, Debug)]
#[serde(deny_unknown_fields)]
pub struct Config {
    #[serde(default)]
    pub data_dir: Option<PathBuf>,
    pub sources: IndexMap<String, Box<dyn SourceConfig>>,
    pub sinks: IndexMap<String, SinkOuter>,
    #[serde(default)]
    pub transforms: IndexMap<String, TransformOuter>,
}

#[derive(Default)]
pub struct GlobalOptions {
    pub data_dir: Option<PathBuf>,
}

#[derive(Debug, Snafu)]
pub enum DataDirError {
    #[snafu(display("data_dir option required, but not given here or globally"))]
    MissingDataDir,
    #[snafu(display("data_dir {:?} does not exist", data_dir))]
    DoesNotExist { data_dir: PathBuf },
    #[snafu(display("data_dir {:?} is not writable", data_dir))]
    NotWritable { data_dir: PathBuf },
    #[snafu(display(
        "Could not create subdirectory {:?} inside of data dir {:?}: {}",
        subdir,
        data_dir,
        source
    ))]
    CouldNotCreate {
        subdir: PathBuf,
        data_dir: PathBuf,
        source: std::io::Error,
    },
}

impl GlobalOptions {
    pub fn from(config: &Config) -> Self {
        Self {
            data_dir: config.data_dir.clone(),
        }
    }

    /// Resolve the `data_dir` option in either the global or local
    /// config, and validate that it exists and is writable.
    pub fn resolve_and_validate_data_dir(
        &self,
        local_data_dir: Option<&PathBuf>,
    ) -> crate::Result<PathBuf> {
        let data_dir = local_data_dir
            .or(self.data_dir.as_ref())
            .ok_or_else(|| DataDirError::MissingDataDir)
            .map_err(|err| Box::new(err))?
            .to_path_buf();
        if !data_dir.exists() {
            return Err(DataDirError::DoesNotExist { data_dir }.into());
        }
        let readonly = std::fs::metadata(&data_dir)
            .map(|meta| meta.permissions().readonly())
            .unwrap_or(true);
        if readonly {
            return Err(DataDirError::NotWritable { data_dir }.into());
        }
        Ok(data_dir)
    }

    /// Resolve the `data_dir` option using
    /// `resolve_and_validate_data_dir` and then ensure a named
    /// subdirectory exists.
    pub fn resolve_and_make_data_subdir(
        &self,
        local: Option<&PathBuf>,
        subdir: &str,
    ) -> crate::Result<PathBuf> {
        let data_dir = self.resolve_and_validate_data_dir(local)?;

        let mut data_subdir = data_dir.clone();
        data_subdir.push(subdir);

        DirBuilder::new()
            .recursive(true)
            .create(&data_subdir)
            .with_context(|| CouldNotCreate { subdir, data_dir })?;
        Ok(data_subdir)
    }
}

#[derive(Debug, Clone, PartialEq)]
pub enum DataType {
    Any,
    Log,
    Metric,
}

#[typetag::serde(tag = "type")]
pub trait SourceConfig: core::fmt::Debug {
    fn build(
        &self,
        name: &str,
        globals: &GlobalOptions,
        out: mpsc::Sender<Event>,
    ) -> crate::Result<sources::Source>;

    fn output_type(&self) -> DataType;
}

#[derive(Deserialize, Serialize, Debug)]
pub struct SinkOuter {
    #[serde(default)]
    pub buffer: crate::buffers::BufferConfig,
    #[serde(default = "healthcheck_default")]
    pub healthcheck: bool,
    pub inputs: Vec<String>,
    #[serde(flatten)]
    pub inner: Box<dyn SinkConfig>,
}

#[typetag::serde(tag = "type")]
pub trait SinkConfig: core::fmt::Debug {
    fn build(
        &self,
        acker: crate::buffers::Acker,
    ) -> crate::Result<(sinks::RouterSink, sinks::Healthcheck)>;

    fn input_type(&self) -> DataType;
}

#[derive(Deserialize, Serialize, Debug)]
pub struct TransformOuter {
    pub inputs: Vec<String>,
    #[serde(flatten)]
    pub inner: Box<dyn TransformConfig>,
}

#[typetag::serde(tag = "type")]
pub trait TransformConfig: core::fmt::Debug {
    fn build(&self) -> crate::Result<Box<dyn transforms::Transform>>;

    fn input_type(&self) -> DataType;

    fn output_type(&self) -> DataType;
}

// Helper methods for programming construction during tests
impl Config {
    pub fn empty() -> Self {
        Self {
            data_dir: None,
            sources: IndexMap::new(),
            sinks: IndexMap::new(),
            transforms: IndexMap::new(),
        }
    }

    pub fn add_source<S: SourceConfig + 'static>(&mut self, name: &str, source: S) {
        self.sources.insert(name.to_string(), Box::new(source));
    }

    pub fn add_sink<S: SinkConfig + 'static>(&mut self, name: &str, inputs: &[&str], sink: S) {
        let inputs = inputs.iter().map(|&s| s.to_owned()).collect::<Vec<_>>();
        let sink = SinkOuter {
            buffer: Default::default(),
            healthcheck: true,
            inner: Box::new(sink),
            inputs,
        };

        self.sinks.insert(name.to_string(), sink);
    }

    pub fn add_transform<T: TransformConfig + 'static>(
        &mut self,
        name: &str,
        inputs: &[&str],
        transform: T,
    ) {
        let inputs = inputs.iter().map(|&s| s.to_owned()).collect::<Vec<_>>();
        let transform = TransformOuter {
            inner: Box::new(transform),
            inputs,
        };

        self.transforms.insert(name.to_string(), transform);
    }

    pub fn load(mut input: impl std::io::Read) -> Result<Self, Vec<String>> {
        let mut source_string = String::new();
        input
            .read_to_string(&mut source_string)
            .map_err(|e| vec![e.to_string()])?;

        let mut vars = std::env::vars().collect::<HashMap<_, _>>();
        if !vars.contains_key("HOSTNAME") {
            if let Some(hostname) = hostname::get_hostname() {
                vars.insert("HOSTNAME".into(), hostname);
            }
        }
        let with_vars = vars::interpolate(&source_string, &vars);

        toml::from_str(&with_vars)
            .map_err(|e| vec![e.to_string()])
            .and_then(|config: Config| {
                if config.sources.is_empty() {
                    return Err(vec!["No sources defined in the config.".to_owned()]);
                }
                if config.sinks.is_empty() {
                    return Err(vec!["No sinks defined in the config.".to_owned()]);
                }

                Ok(config)
            })
    }

    pub fn contains_cycle(&self) -> bool {
        validation::contains_cycle(self)
    }

    pub fn typecheck(&self) -> Result<(), Vec<String>> {
        validation::typecheck(self)
    }
}

impl Clone for Config {
    fn clone(&self) -> Self {
        // This is a hack around the issue of cloning
        // trait objects. So instead to clone the config
        // we first serialize it into json, then back from
        // json. Originally we used toml here but toml does not
        // support serializing `None`.
        let json = serde_json::to_vec(self).unwrap();
        serde_json::from_slice(&json[..]).unwrap()
    }
}

fn healthcheck_default() -> bool {
    true
}
