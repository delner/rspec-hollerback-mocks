module RSpec
  module Hollerback
    module Mocks
      class AndCallbackImplementation
        def initialize(callback_class, callback_name, *callback_args, &callback_block)
          @callback_class = callback_class
          @callback_name = callback_name
          @callback_args = callback_args
          @callback_block = callback_block if callback_block
        end

        def call(*args, &block)
          callback_instance = @callback_class.new(block)
          if @callback_block
            callback_instance.respond_with(@callback_name, *@callback_args, &@callback_block)
          else
            callback_instance.respond_with(@callback_name, *@callback_args)
          end
        end
      end
    end
  end
end