module Operations::Customer
  class Create
    include CsManagers::Operation

    def validate(params)
      validate_presence_of(:name, params[:name])
      validate_score(params[:score])
    end

    def process(params)
      customer = create_customer(params)

      result.assign(:customer, customer)
    end

    protected

    def create_customer(params)
      Customer.create(
        uuid: SecureRandom.uuid,
        name: params[:name],
        score: params[:score]
      )
    end

    def validate_presence_of(attr, value)
      if value.empty?
        result.add_error_message('name is required')
      end
    end

    def validate_score(score)
      if score.to_i < 1 || score.to_i > Customer::MAX_SCORE
        result.add_error_message('score should be between 1 and 100')
      end
    end
  end
end
