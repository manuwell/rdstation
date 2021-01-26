require 'rubygems'
require 'bundler'

APP_ENV = ENV.fetch('RACK_ENV', 'development').freeze
Bundler.require(:default, APP_ENV)

require 'active_record'

if APP_ENV != 'production'
  require 'dotenv/load'
end

ActiveRecord::Base.establish_connection(
  adapter:  'postgresql',
  url:     ENV.fetch('DATABASE_URL')
)

def logger
  @logger ||= Logger.new('tmp/development.log')
end

require_relative '../lib/cs_managers'
