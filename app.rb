require 'rubygems'
require 'bundler/setup'

require 'active_support'

require 'sinatra'
require "sinatra/reloader" if development?
require "sinatra/json"
require "sinatra/multi_route"
require 'action_view'
require 'haml'
require 'tilt/haml'
require 'will_paginate-bootstrap'

ENV['RACK_ENV'] ||= 'development'
ENV['environment'] = ENV['RACK_ENV']

set :logging, true
set :static, true
set :show_exceptions, :after_handler if development?

set :vote_secret, ENV["VOTE_SECRET"]
raise "vote secret is required" if settings.vote_secret.blank?

use(Rack::Session::Cookie,
    :path         => '/',
    :secret       => ENV['COOKIE_SECRET'],
    :expire_after => 86400)

use OmniAuth::Builder do
  provider(
    :headers,
    {
      headers: { name: 'HTTP_X_FORWARDED_NAME', email: 'HTTP_X_FORWARDED_EMAIL', token: 'HTTP_AUTHORIZATION' },
      uid_field: :email
    }
  )
end

require_relative 'lib/initializer.rb'
require_relative 'lib/wham_helper.rb'

Dir[File.join(File.dirname(__FILE__),'config','initializers','*.rb')].each { |a| require a }
Dir[File.join(File.dirname(__FILE__),'routes','*.rb')].each { |a| require a }

helpers WhamHelper

use Rack::Deflater
use ActiveRecord::ConnectionAdapters::ConnectionManagement

before do
  if !session[:authenticated]
    unless (['/logout','/error'].include?(request.path_info) || request.path_info =~ /^\/auth/)
      session[:redirect_to] = request.path
      redirect '/auth/headers'
    end
  end
end
