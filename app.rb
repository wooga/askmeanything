require 'rubygems'
require 'bundler/setup'

require 'active_support'

require 'sinatra'
require "sinatra/reloader" if development?
require "sinatra/json"
require 'sinatra/r18n'
require 'action_view'
require 'haml'
require 'tilt/haml'
require 'will_paginate-bootstrap'

R18n::I18n.default = 'de'
ENV['RACK_ENV'] ||= 'development'
ENV['environment'] = ENV['RACK_ENV']

set :logging, true
set :static, true
set :show_exceptions, :after_handler if development?

use(Rack::Session::Cookie,
    :path         => '/',
    :secret       => ENV['COOKIE_SECRET'],
    :expire_after => 86400)

require_relative 'lib/wham_helper.rb'

Dir[File.join(File.dirname(__FILE__),'config','initializers','*.rb')].each { |a| require a }
Dir[File.join(File.dirname(__FILE__),'routes','*.rb')].each { |a| require a }

helpers WhamHelper, Sinatra::R18n
use Rack::Deflater
register Sinatra::R18n
use ActiveRecord::ConnectionAdapters::ConnectionManagement
