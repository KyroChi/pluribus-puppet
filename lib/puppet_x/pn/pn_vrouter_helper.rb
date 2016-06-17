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
    class PnVrouterHelper < PnHelper

      Puppet::Provider.commands :cli => 'cli'

      #
      #
      def get_ip()
        cmd = "/usr/bin/cli --quiet #{current_switch} vrouter-interface-show " +
            "vrouter-name #{@resource[:vrouter]} nic #{get_nic(1)} format " +
            "ip parsable-delim %"
        message('Executing ' + "'#{cmd}'")
        out = `#{cmd}`.split('%')
        unless out[1].nil?
          if out[1].strip == build_ip
            return @resource[:ip]
          end
          return out[1].strip
        end
        out
      end

      #
      #
      def get_mask_value()
        cmd = "/usr/bin/cli --quiet #{current_switch} vrouter-interface-show " +
            "vrouter-name #{@resource[:vrouter]} nic #{get_nic(1)} " +
            "format ip,netmask parsable-delim %"
        message('Executing ' + "'#{cmd}'")
        out = `#{cmd}`
        out.split('%')[2].strip
      end

    end
  end
end
