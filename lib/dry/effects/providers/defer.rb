# frozen_string_literal: true

require 'concurrent/promise'
require 'dry/effects/provider'

module Dry
  module Effects
    module Providers
      class Defer < Provider[:defer]
        option :executor, default: -> { :io }

        attr_reader :stack

        def defer(block)
          stack = self.stack.dup
          ::Concurrent::Promise.execute(executor: executor) do
            Handler.spawn_fiber(stack, &block)
          end
        end

        def wait(promises)
          if promises.is_a?(::Array)
            ::Concurrent::Promise.zip(*promises).value!
          else
            promises.value!
          end
        end

        def call(stack, _)
          @stack = stack
          super
        end
      end
    end
  end
end