module Serializers
  module Api
    module V1
      class CustomerSerializer
        attr_reader :customer

        def initialize(customer)
          @customer = customer
        end

        def to_h
          {
            id: customer.uuid,
            name: customer.name,
            score: customer.score
          }
        end
        def to_json
          to_h().to_json
        end
      end
    end
  end
end
