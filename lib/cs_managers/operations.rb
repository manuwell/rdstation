module Operations
  require_relative 'utils/operation'
  require_relative 'utils/operation_result'

  Dir["#{__dir__}/operations/**/*.rb"].each {|file| require_relative file }
end
