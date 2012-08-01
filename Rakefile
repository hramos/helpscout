# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "helpscout"
  gem.homepage = "http://github.com/hramos/helpscout"
  gem.license = "MIT"
  gem.summary = %Q{HelpScout API Wrapper}
  gem.description = %Q{}
  gem.email = "hector@parse.com"
  gem.authors = ["Héctor Ramos"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new
