require 'test_helper'

class CSManagers::CustomerSuccessManagersBalancingTests < Minitest::Test
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

    balancer = CSManagers::CustomerSuccessManagersBalancing.new(cs_managers, customers, [2, 4])
    assert_equal 1, balancer.execute
  end

  def test_scenario_two
    cs_managers = array_to_map([11, 21, 31, 3, 4, 5])
    customers = array_to_map( [10, 10, 10, 20, 20, 30, 30, 30, 20, 60])
    balancer = CSManagers::CustomerSuccessManagersBalancing.new(cs_managers, customers, [])
    assert_equal 0, balancer.execute
  end

  def test_scenario_three
    cs_managers = Array.new(1000, 0)
    cs_managers[998] = 100

    customers = Array.new(10000, 10)

    balancer = CSManagers::CustomerSuccessManagersBalancing.new(
      array_to_map(cs_managers),
      array_to_map(customers),
      [1000]
    )

    result = Timeout.timeout(1.0) { balancer.execute }
    assert_equal 999, result
  end

  def test_scenario_four
    balancer = CSManagers::CustomerSuccessManagersBalancing.new(
        array_to_map([1, 2, 3, 4, 5, 6]),
        array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
        []
    )
    assert_equal 0, balancer.execute
  end

  def test_scenario_five
    balancer = CSManagers::CustomerSuccessManagersBalancing.new(
      array_to_map([100, 2, 3, 3, 4, 5]),
      array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      []
    )
    assert_equal balancer.execute, 1
  end

  def test_scenario_six
    balancer = CSManagers::CustomerSuccessManagersBalancing.new(
      array_to_map([100, 99, 88, 3, 4, 5]),
      array_to_map([10, 10, 10, 20, 20, 30, 30, 30, 20, 60]),
      [1, 3, 2]
    )
    assert_equal balancer.execute, 0
  end

  def test_scenario_seven
    balancer = CSManagers::CustomerSuccessManagersBalancing.new(
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
