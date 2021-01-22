require 'test_helper'

module Result
  class ModuleFunctionTest < Minitest::Test
    def test_instantiating_an_ok_result
      assert_kind_of(Result::Ok, Result.ok("Everything is fine!"))
    end

    def test_instantiating_an_error_result
      assert_kind_of(Result::Error, Result.error("Something went wrong!"))
    end

    def test_new_results_are_ok_by_default
      assert_kind_of(Result::Ok, Result.new { 1 })
    end

    def test_new_results_are_automapped_to_an_error_if_an_exception_is_raised
      assert_kind_of(Result::Error, Result.new { raise })
    end
  end

  class OkTest < Minitest::Test
    def test_describes_its_state_correctly
      assert Result.ok(:value).ok?
      refute Result.ok(:value).error?
    end

    def test_has_an_ok_value
      assert_equal :value, Result.ok(:value).ok_value
    end

    def test_does_not_have_an_error_value
      assert_nil Result.ok(:value).error_value
    end

    def test_ok_value_or_returns_the_ok_value
      assert_equal :value, Result.ok(:value).ok_value_or(:fallback)
    end

    def test_ok_value_or_else_returns_the_ok_value
      assert_equal :value, Result.ok(:value).ok_value_or_else { :fallback }
    end

    def test_executes_and_then_and_returns_its_result
      assert_equal 2, Result.ok(1).and_then { |n| Result.ok(n + 1) }.ok_value
    end

    def test_and_then_expects_the_return_value_of_the_block_to_be_a_result
      assert_raises TypeError do
        Result.ok(:value).and_then { :raw_return_value }
      end
    end

    def test_does_not_execute_or_else_but_returns_itself_instead
      Result.ok(:value).or_else { Result.error(:new_value) }.tap do |result|
        assert result.ok?
        assert_equal :value, result.ok_value
      end
    end

    def test_yield_ok_wraps_the_return_value_of_the_block_in_an_ok_result
      assert_equal 2, Result.ok(1).yield_ok { |n| n + 1 }.ok_value
    end

    def test_does_not_execute_yield_error_but_returns_itself_instead
      Result.ok(1).yield_error { |n| n + 1 }.tap do |result|
        assert result.ok?
        assert 1, result.ok_value
      end
    end
  end

  class ErrorTest < Minitest::Test
    def test_describes_its_state_correctly
      refute Result.error(:value).ok?
      assert Result.error(:value).error?
    end

    def test_raises_when_attempting_to_read_ok_value
      assert_raises Result::UncheckedError do
        Result.error(:value).ok_value
      end
    end

    def test_has_an_error_value
      assert_equal :value, Result.error(:value).error_value
    end

    def test_ok_value_or_returns_the_fallback_value
      assert_equal :fallback, Result.error(:value).ok_value_or(:fallback)
    end

    def test_ok_value_or_else_executes_the_fallback_block_and_returns_its_result
      assert_equal 2, Result.error(1).ok_value_or_else { |n| n + 1 }
    end

    def test_does_not_run_and_then_block_but_returns_itself_instead
      Result.error(:value).and_then { Result.ok(:new_value) }.tap do |result|
        assert result.error?
        assert_equal :value, result.error_value
      end
    end

    def test_executes_block_passed_to_or_else
      Result.error(1).or_else { |n| Result.ok(n + 1) }.tap do |result|
        assert result.ok?
        assert_equal 2, result.ok_value
      end
    end

    def test_executes_or_else_expects_the_return_value_of_the_block_to_be_a_result
      assert_raises TypeError do
        Result.error(:value).or_else { :new_value }
      end
    end

    def test_does_not_execute_yield_ok_but_returns_itself_instead
      Result.error(1).yield_ok { |n| n + 1 }.tap do |result|
        assert result.error?
        assert_equal 1, result.error_value
      end
    end

    def test_executes_block_passed_to_yield_error_and_wraps_return_value_in_an_error_result
      Result.error(1).yield_error { |n| n + 1 }.tap do |result|
        assert result.error?
        assert 2, result.error_value
      end
    end
  end
end
