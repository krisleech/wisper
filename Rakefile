# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  # rubocop is only available in the :development group
end

begin
  require 'bundler/audit/task'
  Bundler::Audit::Task.new
rescue LoadError
  # bundler-audit is only available in the :development group
end

task default: :spec
