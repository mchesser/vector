use futures::Future;

#[cfg(feature = "file-source")]
pub mod file;
pub mod journald;
#[cfg(feature = "rdkafka")]
pub mod kafka;
pub mod statsd;
pub mod stdin;
#[cfg(not(target_os = "windows"))]
pub mod syslog;
pub mod tcp;
pub mod udp;
mod util;
pub mod vector;

pub type Source = Box<dyn Future<Item = (), Error = ()> + Send>;
