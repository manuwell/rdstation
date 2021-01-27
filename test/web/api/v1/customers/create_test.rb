require 'test_helper'

class Web::Api::V1::Customers::CreateTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Web::Api::V1::Application
  end

  def valid_params
    {
      name: 'John Doe',
      score: 10
    }
  end

  def parse_last_response_body
    JSON.parse(last_response.body)
  rescue StandardError => e
    raise StandardError.new("Body was " + last_response.body)
  end

  def test_creation_with_valid_params
    params = valid_params

    post '/api/v1/customers', valid_params

    assert last_response.created?
    parsed_body = parse_last_response_body

    assert parsed_body['result'] == 'success'
    assert parsed_body['request_id'].present?
    assert parsed_body['messages'].empty?

    customer = parsed_body['data']
    assert_equal params[:name], customer['name']
  end

  def test_failure_for_invalid_data
    invalid_params = {}

    post '/api/v1/customers', invalid_params

    assert last_response.bad_request?
    parsed_body = parse_last_response_body

    assert parsed_body['result'] == 'failure'
    assert parsed_body['request_id'].present?
    assert_equal 1, parsed_body['messages'].count
  end

  def test_failure_for_data_out_of_business
    invalid_params = valid_params
    invalid_params[:score] = 10000 # exceeds the limit

    post '/api/v1/customers', invalid_params

    assert last_response.unprocessable?
    parsed_body = parse_last_response_body

    assert parsed_body['result'] == 'failure'
    assert parsed_body['request_id'].present?
    assert_equal 1, parsed_body['messages'].count
  end
end
