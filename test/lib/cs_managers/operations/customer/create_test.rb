require 'test_helper'

class Operations::Customer::CreateTest < Minitest::Test

  def valid_params
    {
      name: 'John Doe',
      score: 10
    }
  end

  def test_creation_with_valid_params
    params = valid_params
    result = Operations::Customer::Create.new.call(params)

    assert_equal true, result.success?, result.translated_errors

    created_customer = result.data[:customer]

    assert_equal false, created_customer.nil?
    assert_equal params[:name], created_customer.name
  end

  def test_failure_for_empty_name
    invalid_params = valid_params
    invalid_params[:name] = ''

    result = Operations::Customer::Create.new.call(invalid_params)

    assert_equal true, result.failure?

    assert_nil result.data[:customer]
    assert_equal 'name is required', result.translated_errors.first
  end
end
