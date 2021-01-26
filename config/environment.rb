require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV.fetch('APP_ENV', 'development'))

require_relative '../lib/cs_managers'
