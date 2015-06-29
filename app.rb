require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'haml'

require 'active_support'
require 'active_support/core_ext/object/blank'

ENV['environment'] = ENV['RACK_ENV'] || 'development'

set :logging, true
set :static, true

use(Rack::Session::Cookie,
    :path         => '/',
    :secret       => ENV['COOKIE_SECRET'],
    :expire_after => 86400)

before do
  unless session[:access_token] || request.path_info =~ /^\/(auth|oauth2callback)/
    redirect '/auth'
  end
end

get '/' do
  ""
end
