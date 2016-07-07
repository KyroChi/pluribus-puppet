module PuppetX
  module Pluribus

    # Use TypeHelper as a mixin module in your provider
    module TypeHelper

      def check_naming(value)
        if value =~ /[^\w.:-]/
          raise ArgumentError, 'Description can only contain letters, ' +
              'numbers, _, ., :, and -'
        end
      end

    end

  end
end