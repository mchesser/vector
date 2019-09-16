#!/usr/bin/env ruby

# release-notes.rb
#
# SUMMARY
#
#   A script that produces release notes for the upcoming release.

Dir.chdir "scripts/release-notes"

#
# Require
#

require "rubygems"
require "bundler"
Bundler.require(:default)

require "active_support/core_ext/array/conversions"
require "active_support/core_ext/string/filters"
require "active_support/core_ext/string/indent"
require "active_support/core_ext/string/inflections"
require "action_view/helpers/number_helper"
require "erb"
require "pathname"

require_relative "util/printer"
require_relative "util/version"
require_relative "release-notes/commit"
require_relative "release-notes/release"
require_relative "release-notes/scope"
require_relative "release-notes/templates"

#
# Constants
#

ROOT_DIR = Pathname.new("#{Dir.pwd}/../..").cleanpath
DOCS_DIR = "#{ROOT_DIR}/docs"
LAST_TAG = `git describe --abbrev=0`.chomp
LAST_VERSION = Version.new(LAST_TAG.gsub(/^v/, ''))
RELEASE_NOTES_DIR = "#{DOCS_DIR}/meta/release-notes"
SEPARATOR = "-" * 80
RELEASES_META_DIR = "#{ROOT_DIR}/.meta/releases"
UPGRADE_GUIDES_DIR = "#{DOCS_DIR}/usage/administration/updating"

#
# Includes
#

include Printer

#
# Functions
#

def commit_changes!(release)
  branch_name = "#{release.version.major}.#{release.version.minor}"

  commands =
    <<~EOF
    git add docs/*
    git commit -sam 'chore: Prepare v#{release.version} release'
    git push origin master
    git tag -a v#{release.version} -m "v#{release.version}"
    git push origin v#{release.version}
    git branch v#{branch_name}
    git push origin v#{branch_name}
    EOF

  commands.chomp!

  words =
    <<~EOF
    Final step. Let's commit the changes and tag the release:

    #{commands.indent(2)}

    Ready to execute the above commands?
    EOF

  if Printer.get(words, ["y", "n"]) == "n"
    Printer.error!("Ok, I've aborted. Please re-run this command when you're ready.")
  end

  # commands.chomp.split("\n").each do |command|
  #   system(command)

  #   if !$?.success?
  #     error!(
  #       <<~EOF
  #       Command failed!

  #         #{command}

  #       Produced the following error:

  #         #{$?.inspect}
  #       EOF
  #     )
  # end

  true
end

def get_new_version
  version_string = get("What is the next version you are releasing? (current version is #{LAST_VERSION})")

  version =
    begin
      Version.new(version_string)
    rescue ArgumentError => e
      invalid("It looks like the version you entered is invalid: #{e.message}")
      get_new_version
    end

  if LAST_VERSION.bump_type(version).nil?
    invalid("The version you entered must be a single patch, minor, or major bump")
    get_new_version
  else
    version
  end
end

def get_commit_lines(last_version, new_version)
  last_commit = `git rev-parse HEAD`.chomp
  range = "v#{last_version}...#{last_commit}"
  log = `git log #{range} --no-merges --pretty=format:'%H\t%s\t%aN\t%ad'`
  release_meta_path = "#{RELEASES_META_DIR}/v#{new_version}.toml"

  if File.exists?(TMP_COMMITS_FILE)
    words =
      <<~EOF
      It looks like you've already staged commits for this release in:

        #{TMP_COMMITS_FILE}

      Would you like to reuse this file?
      EOF

    input = get(words, ["y", "n"])

    if input == "n"
      File.delete(TMP_COMMITS_FILE)
      say("File deleted")
      get_commit_lines(range)
    end
  else
    File.open(TMP_COMMITS_FILE, 'w+') do |file|
      file.write(log)
    end

    say(
      <<~EOF
      I've staged all commits for this release in the follow file:

        #{TMP_COMMITS_FILE}

      Please modify and reword as necessary. Once done, come back to this window.
      EOF
    )

    get("Hit enter when you are ready to proceed...")
  end

  File.read(TMP_COMMITS_FILE).split("\n")
end

def get_upgrade_guide_path(last_version, new_version)
  input = get("Does this release need an upgrade guide?", ["y", "n"])

  if input == "y"
    guide_name = "from_v#{last_version.major}.#{last_version.minor}_to_v#{new_version.major}.#{new_version.minor}"
    guide_path = "#{UPGRADE_GUIDES_DIR}/#{guide_name}.md"

    if !File.exists?(guide_path)
      loop do
        say(
          <<~EOF
          Please place your upgrade guide in the follow path:

            #{guide_path}

          EOF
        )

        get("Hit enter when you are ready to proceed...")
        
        if File.exists?(guide_path)
          return guide_path
        end

        invalid("You did not add the upgrade guide")
      end
    end
  end

  nil
end

def require_clean_branch!
  files = `git diff-index --name-only HEAD --`.strip

  if files != ""
    error!("Your current branch is not clean. Please commit any pending changes before proceeding.")
  end

  true
end

def require_master_branch!
  branch = `git rev-parse --abbrev-ref HEAD`.chomp

  if branch != "master"
    error!("You must be on the master branch to release.")
  end

  true
end

def save_release_notes!(release)
  templates = Templates.new

  # Create the image
  svg_source = templates.render_hero_svg(release)
  path = "#{DOCS_DIR}/assets/v#{release.version}.svg"
  File.open(path, "w+") { |file| file.write(svg_source) }

  # Create the release notes
  release_notes_source = templates.render_summary(release)
  path = "#{RELEASE_NOTES_DIR}/by-version/#{release.version}.md"
  File.open(path, "w+") { |file| file.write(release_notes_source) }

  words =
    <<~EOF
    Release notes successfully created and placed at:

      #{path}

    Does everything look good?
    EOF

  if get(words, ["y", "n"]) == "n"
    error!("Please modify the staged commits file and rerun this command.")
  end
end

#
# Execute
#

title("Building release notes...")

#require_master_branch!()
#require_clean_branch!()
new_version = get_new_version()
commit_lines = get_commit_lines(LAST_VERSION, new_version)
upgrade_guide_path = get_upgrade_guide_path(LAST_VERSION, new_version)
commits = Commit.all!(commit_lines)
release = Release.new(LAST_VERSION, LAST_TAG, new_version, commits, upgrade_guide_path)

save_release_notes!(release)
commit_changes!(release)

say("🚀 release #{release.version} is out!", color: :green)