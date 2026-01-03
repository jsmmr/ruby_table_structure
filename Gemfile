# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in table_structure.gemspec
gemspec

gem 'rake'
gem 'rspec'

# These gems were part of the standard library in older Ruby versions
# csv: became a bundled gem in Ruby 3.4
# ostruct: became a bundled gem in Ruby 4.0
gem 'csv' if RUBY_VERSION >= '3.4'
gem 'ostruct' if RUBY_VERSION >= '4.0'
