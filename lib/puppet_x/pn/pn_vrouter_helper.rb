# Copyright (C) 2016 Pluribus Networks
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

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