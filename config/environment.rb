require 'rubygems'
require 'bundler'

APP_ENV = ENV.fetch('RACK_ENV', 'development').freeze

Bundler.require(:default, APP_ENV)

if APP_ENV != 'development'
  require 'dotenv/load'
end

require_relative '../lib/cs_managers'
