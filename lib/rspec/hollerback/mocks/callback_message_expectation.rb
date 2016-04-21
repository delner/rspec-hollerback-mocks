module RSpec
  module Hollerback
    module Mocks
      module CallbackMessageExpectation
        def and_callback(callback_name, *callback_args, &callback_block)
          # Lookup callback class
          target_class = @method_double.object.is_a?(Module) ? @method_double.object : @method_double.object.class
          raise ArgumentError.new("Target class #{target_class.name.to_s} does not implement Hollerback!") if !(target_class < ::Hollerback)
          callback_class = target_class.const_get("Callbacks")

          # Add callback action
          self.callback_implementation_action(RSpec::Hollerback::Mocks::AndCallbackImplementation.new(callback_class, callback_name, *callback_args, &callback_block))

          self
        end

        def callback_implementation_action(action)
          return unless action
          (implementation.callback_actions ||= []).push(action)
        end
      end
    end
  end
end

# Inject into RSpec
RSpec::Mocks::MessageExpectation.include RSpec::Hollerback::Mocks::CallbackMessageExpectation