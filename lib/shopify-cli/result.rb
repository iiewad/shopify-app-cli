# frozen_string_literal: true
# typed: strict

module ShopifyCli
  module Result
    class Success
      def initialize(value)
        @value = value
      end

      def success?
        true
      end

      def error?
        false
      end

      def then(&block)
        Result.wrap(&block).call(@value)
      end

      def rescue
        self
      end

      def unwrap(*)
        @value
      end
    end

    class Error
      def initialize(error)
        @error = error
      end

      def success?
        false
      end

      def error?
        true
      end

      def then
        self
      end

      def rescue(&block)
        Result.wrap(&block).call(@error)
      end

      def unwrap(*args, &block)
        raise ArgumentError, "expected either a fallback value or a block" unless args.one? ^ block
        block ? block.call(@error) : args.pop
      end
    end

    def self.wrap(*args, &block)
      raise ArgumentError, "expected either a value or a block" unless args.one? ^ block

      if args.one?
        args.pop.yield_self do |value|
          case value
          when Result::Success, Result::Error
            value
          when Exception
            Result::Error.new(value)
          else
            Result::Success.new(value)
          end
        end
      else
        ->(value = nil) do
          begin
            wrap(block.call(value))
          rescue => error
            wrap(error)
          end
        end
      end
    end
  end
end
