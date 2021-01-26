module ShopifyCli
  module MethodObject
    module AutoCreateResultObject
      def call(*)
        Result.wrap { super }.call
      end
    end

    module ClassMethods
      def call(*args, **kwargs)
        property_names = properties.keys
        property_kwargs = kwargs.slice(*property_names)
        remaining_kwargs = kwargs.slice(*(kwargs.keys - property_names))
        args = remaining_kwargs.any? ? args.push(remaining_kwargs) : args

        new(**property_kwargs).call(*args)
      end

      def to_proc
        method(:call).to_proc
      end
    end

    def self.included(method_object_implementation)
      method_object_implementation.prepend(AutoCreateResultObject)
      method_object_implementation.include(SmartProperties)
      method_object_implementation.extend(ClassMethods)
    end

    def to_proc
      method(:call).to_proc
    end
  end
end
