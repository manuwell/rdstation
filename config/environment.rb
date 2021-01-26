require 'rubygems'
require 'bundler'
require 'fileutils'

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
  @logger ||= if APP_ENV == 'production'
                Logger.new(STDOUT)
              else
                filepath = "logs/#{APP_ENV}.log"
                FileUtils.touch(filepath) if !File.exist?(filepath)
                Logger.new(filepath)
              end
end

require_relative '../lib/cs_managers'
