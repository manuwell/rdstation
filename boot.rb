require_relative './config/environment'
require_relative './web/api/v1'

if ENV.fetch('RACK_ENV') == 'development'
  require "sinatra/reloader" if development?
end

if ENV.fetch('RACK_APP') == 'api_v1'
  Web::Api::V1::Application.run!
end
