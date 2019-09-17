#!/usr/bin/env ruby

# release-prepare.rb
#
# SUMMARY
#
#   A script that prepares the release .meta/releases/vX.X.X.toml file.
#   Afterwards, the `make generate` command should be used to refresh
#   the generated files against the new release metadata.

#
# Setup
#

# Changes into the release-prepare directory so that we can load the
# Bundler dependencies. Unfortunately, Bundler does not provide a way
# load a Gemfile outside of the cwd.
Dir.chdir "scripts/release-prepare"

#
# Requires
#

require "rubygems"
require "bundler"
Bundler.require(:default)

require "time"

require_relative "util/printer"
require_relative "util/version"

#
# Includes
#

include Printer

#
# Constants
#

ROOT_DIR = Pathname.new("#{Dir.pwd}/../..").cleanpath
RELEASE_META_DIR = "#{ROOT_DIR}/.meta/releases"
TYPES = ["chore", "docs", "feat", "fix", "improvement", "perf"]
TYPES_THAT_REQUIRE_SCOPES = ["feat", "improvement", "fix"]

#
# Functions
#

def get_commit_log(last_version, new_version)
  last_commit = `git rev-parse HEAD`.chomp
  range = "v#{last_version}...#{last_commit}"
  `git log #{range} --no-merges --pretty=format:'%H\t%s\t%aN\t%ad'`.chomp
end

def get_commits(last_version, new_version)
  commit_log = get_commit_log(last_version, new_version)

  commit_log.split("\n").collect do |commit|
    parse_commit_line!(commit)
  end
end

def get_commit_stats(sha)
  `git show --shortstat --oneline #{sha}`.split("\n").last
end

def get_new_version(last_version)
  version_string = get("What is the next version you are releasing? (current version is #{last_version})")

  version =
    begin
      Version.new(version_string)
    rescue ArgumentError => e
      invalid("It looks like the version you entered is invalid: #{e.message}")
      get_new_version(last_version)
    end

  if last_version.bump_type(version).nil?
    invalid("The version you entered must be a single patch, minor, or major bump")
    get_new_version(last_version)
  else
    version
  end
end

def parse_commit_line!(commit_line)
  # Parse the full commit loine
  line_parts = commit_line.split("\t")

  attributes =
    {
      "sha" =>  line_parts.fetch(0),
      "message" => line_parts.fetch(1),
      "author" => line_parts.fetch(2),
      "date" => Time.parse(line_parts.fetch(3))
    }

  # Parse the convention commit message
  commit_message_attributes = parse_commit_message!(attributes.fetch("message"))
  attributes.merge!(commit_message_attributes)

  # Parse the stats
  stats = get_commit_stats(attributes.fetch("sha"))
  stats_attributes = parse_commit_stats!(stats)
  attributes.merge!(stats_attributes)

  attributes
end

def parse_commit_message!(description)
  match = description.match(/^(?<type>[a-z]*)(?<breaking_change>!)?(\((?<scope>[a-z0-9_ ]*)\))?: (?<description>.*?)( \(#(?<pr_number>[0-9]*)\))?$/)

  if match.nil?
    raise <<~EOF
    Commit message does not conform to the conventional commit format.
    
    Unable to parse at all!

      #{description}

    Please correct and retry.
    EOF
  end

  attributes =
    {
      "type" => match[:type],
      "breaking_change" => !match[:breaking_change].nil?,
      "description" => match[:description]
    }

  if match[:scope]
    attributes["scope"] = match[:scope]
  end

  if match[:pr_number]
    attributes["pr_number"] = match[:pr_number].to_i
  end

  type = attributes.fetch("type")
  scope = attributes["scope"]

  if !type.nil? && !TYPES.include?(type)
    raise <<~EOF
    Commit has an invalid type!

    The type must be one of #{TYPES.inspect}.

      #{type.inspect}
    
    Please correct and retry.
    EOF
  end

  if TYPES_THAT_REQUIRE_SCOPES.include?(type) && scope.nil?
    raise <<~EOF
    Commit does not have a scope!

    A scope is required for commits of type #{TYPES_THAT_REQUIRE_SCOPES.inspect}.

      #{description}

    Please correct and retry.
    EOF
  end

  attributes
end

def parse_commit_stats!(stats)
  attributes = {}

  stats.split(", ").each do |stats_part|
    stats_part.strip!

    key =
      case stats_part
      when /insertions?/
        "insertions_count"
      when /deletions?/
        "deletions_count"
      when /files? changed/
        "files_count"
      else
        raise "Invalid commit stat: #{stats_part}"
      end

    count = stats_part.match(/^(?<count>[0-9]*) /)[:count].to_i
    attributes[key] = count
  end

  attributes
end

def create_release_meta_file!(last_version, new_version)
  release_meta_path = "#{RELEASE_META_DIR}/v#{new_version}.toml"

  if File.exists?(release_meta_path)
    words =
      <<~EOF
      It looks like you've already created a release meta file at:

        #{release_meta_path}

      Would you like to reuse this file? Typing 'n' will recreate this file.
      EOF

    input = get(words, ["y", "n"])

    if input == "n"
      File.delete(release_meta_path)
      say("File deleted")
      create_release_meta_file!(last_version, new_version)
    end
  else
    commits = get_commits(last_version, new_version)
    structure = {releases: {new_version.to_s => {commits: commits}}}
    contents = TomlRB.dump(structure)
    
    File.open(release_meta_path, 'w+') do |file|
      file.write(contents)
    end

    words =
      <<~EOF
      I've created a release meta file at:

        #{release_meta_path}

      Please modify and reword as necessary.

      Ready to proceed?
      EOF
    
    if get(words, ["y", "n"]) == "n"
      error!("Ok, re-run this command when you're ready.")
    end
  end

  true
end

#
# Execute
#

title("Creating release meta file...")

last_tag = `git describe --abbrev=0`.chomp
last_version = Version.new(last_tag.gsub(/^v/, ''))
new_version = get_new_version(last_version)
create_release_meta_file!(last_version, new_version)