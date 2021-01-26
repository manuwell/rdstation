require 'minitest/autorun'
require 'timeout'

class CustomerSuccessManagersBalancing
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

class CustomerSuccessManagersBalancingTests < Minitest::Test
  def test_scenario_one
    cs_managers = [
      { id: 1, score: 60 },
      { id: 2, score: 20 },
      { id: 3, score: 95 },
      { id: 4, score: 75 }
    ]
    customers = [
      { id: 1, score: 90 },
      { id: 2, score: 20 },
      { id: 3, score: 70 },
      { id: 4, score: 40 },
      { id: 5, score: 60 },
      { id: 6, score: 10}
    ]

    balancer = CustomerSuccessManagersBalancing.new(cs_managers, customers, [2, 4])
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    cs_managers = array_to_map([11, 21, 31, 3, 4, 5])
    customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CustomerSuccessManagersBalancing.new(cs_managers, customers, [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    cs_managers = Array.new(1000, 0)
    cs_managers[998] = 100

    customers = Array.new(10000, 10)

    balancer = CustomerSuccessManagersBalancing.new(
      array_to_map(cs_managers),
      array_to_map(customers),
      [1000]
    )

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 999, result
  end

  def test_scenario_four
    balancer = CustomerSuccessManagersBalancing.new(
        array_to_map([1, 2, 3, 4, 5, 6]),
        array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
        []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CustomerSuccessManagersBalancing.new(
      array_to_map([100, 2, 3, 3, 4, 5]),
      array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal balancer.execute, 1
  end

  def test_scenario_six
    balancer = CustomerSuccessManagersBalancing.new(
      array_to_map([100, 99, 88, 3, 4, 5]),
      array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal balancer.execute, 0
  end

  def test_scenario_seven
    balancer = CustomerSuccessManagersBalancing.new(
      array_to_map([100, 99, 88, 3, 4, 5]),
      array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [4, 5, 6]
    )
    assert_equal balancer.execute, 3
  end

  def array_to_map(arr)
    out = []
    arr.each_with_index do |score, index|
      out.push({ id: index + 1, score: score })
    end
    out
  end
end

Minitest.run
