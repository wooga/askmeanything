require 'rubygems'
require 'bundler'

require File.expand_path(File.dirname(__FILE__) + '/app')

run Sinatra::Application
