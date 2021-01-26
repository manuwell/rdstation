class CSManagers::CustomerSuccessManagersBalancing
  attr_reader :cs_managers, :customers, :cs_managers_away, :cs_managers_acc

  def initialize(cs_managers, customers, cs_managers_away)
    @cs_managers = cs_managers
    @customers = customers
    @cs_managers_away = cs_managers_away
    @cs_managers_acc = {}
    @top_manager = { manager: nil, customers_count: 0, customer_count_tie: false}
  end

  # Returns the id of the CustomerSuccessManagersBalancing with the most customers
  def execute
    customers.each do |customer|
      manager = search_cs_manager(sorted_available_cs_managers, customer)
      next if manager.nil?

      add_customer_to_manager(customer, manager)
    end

    return 0 if @top_manager[:manager].nil? # no manager received a costumer
    return 0 if @top_manager[:customer_count_tie] # tie between two managers

    @top_manager[:manager][:id]
  end

  private

  def add_customer_to_manager(customer, manager)
    @cs_managers_acc[manager[:id]] ||= { manager: manager, customers: []}
    @cs_managers_acc[manager[:id]][:customers] << customer

    manager_customers = @cs_managers_acc[manager[:id]][:customers]
    manager_customers_count = manager_customers.length

    if manager_customers_count > @top_manager[:customers_count]
      @top_manager[:manager] = manager
      @top_manager[:customers_count] = manager_customers_count
      @top_manager[:customer_count_tie] = false
    elsif manager_customers_count == @top_manager[:customers_count]
      @top_manager[:customer_count_tie] = true
    end
  end

  def sorted_available_cs_managers
    @sorted_cs_managers ||= cs_managers.sort do |cs1, cs2|
      cs1[:score] <=> cs2[:score]
    end.select { |cs| !cs_managers_away.include?(cs[:id]) }
  end

  # CSManager[] { id: Integer, score: Integer }
  # Customer { id: Integer, score: Integer }
  def search_cs_manager(cs_managers, customer)
    cs_managers.detect do |cs|
      customer[:score] <= cs[:score]
    end
  end
end
