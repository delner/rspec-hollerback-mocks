module RSpec
  module Hollerback
    module Mocks
      module CallbackActions
        attr_accessor :callback_actions
        def actions
          actions_array = super
          actions_array.insert(actions_array.size - 1, callback_actions).flatten.compact
        end
      end
    end
  end
end

# Inject into RSpec
RSpec::Mocks::Implementation.prepend RSpec::Hollerback::Mocks::CallbackActions