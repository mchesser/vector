#!/usr/bin/env ruby

# release-prepare.rb
#
# SUMMARY
#
#   A script that prepares the release .meta/releases/vX.X.X.toml file.
#   Afterwards, the `make generate` command should be used to refresh
#   the generated files with the new release metadata.

Dir.chdir "scripts/release-prepare"

#
# Requires
#

require_relative "util/printer"
require_relative "util/version"

#
# Constants
#

ROOT_DIR = Pathname.new("#{Dir.pwd}/../..").cleanpath
META_DIR = "#{ROOT_DIR}/.meta"

#
# Functions
#

def get_new_version(last_version)
  version_string = get("What is the next version you are releasing? (current version is #{last_version})")

  version =
    begin
      Version.new(version_string)
    rescue ArgumentError => e
      invalid("It looks like the version you entered is invalid: #{e.message}")
      get_new_version
    end

  if last_version.bump_type(version).nil?
    invalid("The version you entered must be a single patch, minor, or major bump")
    get_new_version
  else
    version
  end
end

#
# Execute
#

last_tag = `git describe --abbrev=0`.chomp
last_version = Version.new(LAST_TAG.gsub(/^v/, ''))
new_version = get_new_version(last_version)