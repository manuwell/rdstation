require 'minitest/autorun'
require 'timeout'

ENV['RACK_ENV'] = 'test'

require_relative '../config/environment'
