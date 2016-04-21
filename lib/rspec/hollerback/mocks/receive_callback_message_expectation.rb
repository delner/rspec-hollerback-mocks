module RSpec
  module Hollerback
    module Mocks
      module ReceiveCallbackMessageExpectation
        def self.included(mod)
          RSpec::Hollerback::Mocks::CallbackMessageExpectation.public_instance_methods(false).each do |method|
            next if method_defined?(method)

            define_method(method) do |*args, &block|
              @recorded_customizations << RSpec::Mocks::Matchers::ExpectationCustomization.new(method, args, block)
              self
            end
          end
        end
      end
    end
  end
end

# Inject into RSpec
RSpec::Mocks::Matchers::Receive.include RSpec::Hollerback::Mocks::ReceiveCallbackMessageExpectation