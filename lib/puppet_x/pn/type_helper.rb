# Copyright 2016 Pluribus Networks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

      def switch
        newproperty(:switch) do
          defaultto('local')
          validate do |value|
            unless Facter.value('reachable_switches').include? value
              raise ArgumentError, "Switch #{value} was not found on the fabric"
            end
          end
        end
      end

    end

  end
end
