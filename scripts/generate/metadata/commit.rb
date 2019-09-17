require "json"

require "active_support/core_ext/string/filters"

require_relative "commit_scope"

class Commit
  attr_reader :author,
    :breaking_change,
    :date,
    :deletions_count,
    :description,
    :files_count,
    :insertions_count,
    :message,
    :pr_number,
    :scope,
    :sha,
    :type

  def initialize(attributes)
    @author = attributes.fetch("author")
    @breaking_change = attributes.fetch("breaking_change")
    @deletions_count = attributes["deletions_count"] || 0
    @files_count = attributes.fetch("files_count")
    @date = attributes.fetch("date")
    @description = attributes.fetch("description")
    @insertions_count = attributes["insertions_count"] || 0
    @message = attributes.fetch("message")
    @pr_number = attributes["pr_number"]
    @scope = CommitScope.new(attributes["scope"] || "core")
    @sha = attributes.fetch("sha")
    @type = attributes.fetch("type")
  end

  def breaking_change?
    @breaking_change == true
  end

  def bug_fix?
    type == "fix"
  end

  def category
    scope.category
  end

  def chore?
    type == "chore"
  end

  def component_name
    return @component_name if defined?(@component_name)

    @component_name =
      if new_feature?
        match =  description.match(/`?(?<name>[a-zA-Z_]*)`? (source|transform|sink)/)
        
        if !match.nil? && !match[:name].nil?
          match[:name].downcase
        else
          nil
        end
      else
        scope.component_name
      end
  end

  def component_name!
    if component_name.nil?
      raise "Component name could not be found in commit: #{message}"
    end

    component_name
  end

  def component_type
    scope.component_type
  end

  def component_type!
    if component_type.nil?
      raise "Component type could not be found in commit: #{message}"
    end

    component_type
  end

  def doc_update?
    type == "docs"
  end

  def enhancement?
    type == "improvement"
  end

  def new_component?
    new_feature? && !component_name.nil?
  end

  def new_feature?
    type == "feat"
  end

  def performance_improvement?
    type == "perf"
  end

  def sha_short
    @sha_short ||= sha.truncate(7, omission: "")
  end

  def sink?
    component_type == "sink"
  end

  def source?
    component_type == "source"
  end

  def transform?
    component_type == "transform"
  end
end