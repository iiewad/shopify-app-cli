require 'test_helper'

module Result
  class ConstructorTest < Minitest::Test
    def test_wraps_exceptions_in_an_error_result
      assert Result(RuntimeError.new).error?
    end

    def test_wraps_values_in_a_success_result
      assert Result("Success").success?
    end

    def test_does_not_wrap_another_result_again
      assert_equal "Success", Result(Result("Success")).unwrap
    end

    def test_supports_deferring_result_construction
      assert_equal "Success", Result { "Success" }.call.unwrap
    end

    def test_forwards_caller_argument_when_deferring_result_construction
      assert_equal "Success", Result { |value| value }.call("Success").unwrap
    end

    def test_captures_exceptions_and_wraps_them_in_an_error_when_deferring_result_construction
      assert Result { raise "Error" }.call.error?
    end
  end
  
  class SuccessTest < Minitest::Test
    def test_describes_its_state_correctly
      assert Success.new(:value).success?
      refute Success.new(:value).error?
    end

    def test_unwrap_returns_the_value
      assert_equal :value, Success.new(:value).unwrap
    end

    def test_additional_arguments_to_unwrap_are_ignored
      assert_nothing_raised do
        Success.new(:value).unwrap(:fallback_value)
      end
    end

    def test_then_returns_the_return_value_of_the_block_unchanged_if_it_is_a_result
      assert Success.new("Success").then { Error.new("Error") }.error?

      Success.new(1).then { |n| Success.new(n + 1) }.tap do |result|
        assert result.success?
        assert_equal 2, result.unwrap
      end
    end

    def test_then_automatically_wraps_the_result_of_the_block
      assert_equal 2, Success.new(1).then { |n| n + 1 }.unwrap
    end

    def test_then_captures_exceptions_and_wraps_them_in_an_error
      assert Success.new(1).then { raise "Error" }.error?
    end
  end

  class ErrorTest < Minitest::Test
    def test_describes_its_state_correctly
      refute Error.new(:value).success?
      assert Error.new(:value).error?
    end

    def test_unwrap_raises_an_error_if_no_fallback_has_been_provided
      assert_raises ArgumentError do
        Error.new(:value).unwrap
      end
    end

    def test_unwrap_returns_the_fallback_value
      assert_equal :fallback, Error.new(:error).unwrap(:fallback)
    end

    def test_unwrap_returns_the_return_value_of_the_block
      error = RuntimeError.new
      assert_equal error, Error.new(error).unwrap { |err| err }
    end

    def test_unrwap_raises_an_argument_error_if_a_fallback_value_and_a_block_are_given
      assert_raises ArgumentError do
        Error.new(:error).unwrap(:fallback) {}
      end
    end

    def test_rescue_returns_the_return_value_of_the_block_unchanged_if_it_is_a_result
      assert Error.new("Error").rescue { Success.new("Success") }.success?

      Error.new(1).rescue { |n| Error.new(n + 1) }.tap do |result|
        assert result.error?
        assert_equal 2, result.unwrap { |err| err }
      end
    end

    def test_rescue_automatically_wraps_the_result_of_the_block
      Error.new(1).rescue { |n| n + 1 }.tap do |result|
        assert result.success?
        assert 2, result.unwrap
      end
    end

    def test_rescue_captures_exceptions_and_wraps_them_in_an_error
      assert Error.new(1).then { raise "Error" }.error?
    end
  end
end
