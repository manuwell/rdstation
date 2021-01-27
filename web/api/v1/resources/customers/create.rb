module Web::Api::V1::Customers
  class Create < Web::Api::V1::Base

    set :protect_from_csrf, false

    CustomerSerializer = Serializers::Api::V1::CustomerSerializer

    class CreateCustomerSchema < ::Dry::Validation::Contract
      params do
        required(:name).value(:string)
        required(:score).value(:integer)
      end
    end

    post '/api/v1/customers' do
      result = CreateCustomerSchema.new.call(params)
      if result.errors.any?
        json_error_response(400, result.errors)
        return
      end

      op_result = Operations::Customer::Create.new.call(result.to_h)

      if op_result.failure?
        json_error_response(422, op_result.errors)
        return
      end

      customer = op_result.data[:customer]
      serialized_customer = CustomerSerializer.new(customer)
      json_success_response(201, serialized_customer.to_h)
    end
  end
end
