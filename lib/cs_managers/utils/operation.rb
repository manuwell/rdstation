# This is operation class highly based on
# Hanami::Interactor class https://github.com/hanami/utils/blob/master/lib/hanami/interactor.rb
#
# THis module helps us to define business Bounded Context, called Operations.
#
# For example:
#
#   class Customer::Create
#     include CsManagers::Operation
#
#     # some deps this operation depends on
#     def initialize()
#       @persona = persona
#     end
#
#     def validate(result, params)
#       # some raw validations
#       validate_score(params[:score])
#     end
#
#     # {
#     #   name: "CreateCartByLayoutWa",
#     #   score: 10
#     # }
#     def process(result, params)
#       customer = Customer.create(
#         name: params[:name],
#         score: params[:score]
#       )
#
#       result.assigns[:customer] = customer
#     end
#
#     protected
#
#     def validate_score(score)
#       return if score.to_i > 0 and score.to_i <= 100
#
#       result.error("Score should be between 0 and 100")
#     end
#   end
#
#
#   # Usage:
#   operation = Customer::Create.new
#   result = operation.call({
#      name: "Fulano de Tal",
#      score: 10
#   })
#
#   puts result.translated_messages
#
#   puts "Customer created! #{result.assigns[:customer]}"

module CsManagers
  module Operation
    attr_accessor :result

    def call(params = {})
      @result ||= CsManagers::Result.new
      run(params)
      result
    end

    def run(params = {})
      return unless result.success?

      params = params.to_h.with_indifferent_access

      catch :break do
        self.validate(params)
        self.process(params) if result.success?
      end
      result.success?
    rescue StandardError => e
      logger.error(e.message)
      logger.error(e.backtrace)
      result.add_error('operations.standard_error', error_class: e.class, error_message: e.message)
    end

    def process(params)
      raise NotImplementedError,
        "You should implement method:\n   process(params)"
    end

    def validate(params)
      # optional implementation
    end
  end
end
