require 'minitest/autorun'
require 'rack/test'
require 'timeout'

ENV['RACK_ENV'] = 'test'

if !defined? CsManagers
  require_relative '../config/environment'
end
if !defined? Web
  require_relative '../web/api/v1'
end
