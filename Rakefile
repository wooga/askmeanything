require 'active_support'
require 'active_support/core_ext/object/blank'
require 'tasks/state_machine'

if File.exists?(".env")
  require 'dotenv'
  Dotenv.load
end

Dir[File.join(File.dirname(__FILE__), 'lib', 'tasks','*.rake')].each do |f|
  load f
end

task :default => :test
task :environment do
  require_relative 'app.rb'
end
