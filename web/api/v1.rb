module Web
  module Api
    module V1
      require 'sinatra/json'
      require 'dry/validation'

      Dir["#{__dir__}/**/*.rb"].each {|file| require_relative file }

      class Application < Web::Api::V1::Base
        use Customers::Create
      end
    end
  end
end
