require "ostruct"
require "toml-rb"

require_relative "metadata/batching_sink"
require_relative "metadata/exposing_sink"
require_relative "metadata/links"
require_relative "metadata/release"
require_relative "metadata/source"
require_relative "metadata/streaming_sink"
require_relative "metadata/transform"

# Object representation of the /.meta directory
#
# This represents the /.meta directory in object form. Sub-classes represent
# each sub-component.
class Metadata
  class << self
    def load(meta_dir, opts = {})
      metadata = {}

      Dir.glob("#{meta_dir}/**/*.toml").each do |file|
        hash = TomlRB.load_file(file)
        metadata.deep_merge!(hash)
      end

      new(metadata, opts)
    end
  end

  attr_reader :companies,
    :links,
    :options,
    :releases,
    :sinks,
    :sources,
    :transforms

  def initialize(hash, check_urls: true)
    @companies = hash.fetch("companies")
    @options = OpenStruct.new()
    @releases = OpenStruct.new()
    @sinks = OpenStruct.new()
    @sources = OpenStruct.new()
    @transforms = OpenStruct.new()

    # releases
    release_versions =
      hash.fetch("releases").collect do |version_string, _release_hash|
        Version.new(version_string)
      end

    # Seed the list of releases with the first version
    release_versions << Version.new("0.3.0")

    hash.fetch("releases").collect do |version_string, release_hash|
      version = Version.new(version_string)

      last_version =
        release_versions.
          select { |other_version| other_version < version }.
          sort.
          last

      release_hash["version"] = version_string
      release = Release.new(release_hash, last_version)
      @releases.send("#{version_string}=", release)
    end

    # sources

    hash["sources"].collect do |source_name, source_hash|
      source_hash["name"] = source_name
      source = Source.new(source_hash)
      @sources.send("#{source_name}=", source)
    end

    # transforms

    hash["transforms"].collect do |transform_name, transform_hash|
      transform_hash["name"] = transform_name
      transform = Transform.new(transform_hash)
      @transforms.send("#{transform_name}=", transform)
    end

    # sinks

    hash["sinks"].collect do |sink_name, sink_hash|
      sink_hash["name"] = sink_name

      sink =
        case sink_hash.fetch("egress_method")
        when "batching"
          BatchingSink.new(sink_hash)
        when "exposing"
          ExposingSink.new(sink_hash)
        when "streaming"
          StreamingSink.new(sink_hash)
        end

      @sinks.send("#{sink_name}=", sink)
    end

    transforms_list = @transforms.to_h.values
    transforms_list.each do |transform|
      alternatives = transforms_list.select do |alternative|
        if transform.function_categories != ["convert_types"] && alternative.function_categories.include?("program")
          true
        else
          function_diff = alternative.function_categories - transform.function_categories
          alternative != transform && function_diff != alternative.function_categories
        end
      end

      transform.alternatives = alternatives.sort
    end

    # options

    hash.fetch("options").each do |option_name, option_hash|
      option = Option.new(
        option_hash.merge({"name" => option_name}
      ))

      @options.send("#{option_name}=", option)
    end

    # links

    @links = Links.new(hash.fetch("links"), check_urls: check_urls)
  end

  def components
    @components ||= sources.to_h.values + transforms.to_h.values + sinks.to_h.values
  end

  def latest_major_releases
    version = Version.new("#{latest_version.major}.0.0")

    releases_list.select do |release|
      release.version >= version
    end
  end

  def latest_version
    releases_list.last.version
  end

  def newer_releases(release)
    releases_list.select do |other_release|
      other_release > release
    end
  end

  def previous_minor_release(release)
    version = Version.new("#{release.major}.#{release.minor}.0")

    releases_list.
      select do |release|
        release.version < version
      end.
      last
  end

  def releases_list
    @releases_list ||= @releases.to_h.values.sort
  end

  def relesed_versions
    releases
  end
end