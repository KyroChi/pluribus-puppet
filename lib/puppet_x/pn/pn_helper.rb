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
    class PnHelper

      # Global variable to store the resource hash pulled from the provider
      @resource

      #
      #
      def initialize(resources)
        @resource = resources
      end

      # Helper message to push messages to the master during manifest uploads.
      # Can be useful for debugging helper methods. This method will issue a
      # warning message if an incorrect type is given but execution will
      # continue
      # Supported Puppet message types:
      #     - debug
      #     - fail
      #     - warn (warning)
      #     - alert
      # @param message: The message to be displayed.
      # @param type: A string that is the type of message to be displayed.
      #
      def message(message, type='debug')
        case type
          when 'debug'
            Puppet.debug(message)
          when 'fail'
            Puppet.fail(message)
          when 'warn', 'warning'
            Puppet.warning(message)
          when 'alert'
            Puppet.alert(message)
          else
            Puppet.warning('WARNING: no valid message type given! ' + message)
        end
      end

      # Helper method to build an ip address string
      # @param nomask: This value can be anything. If it is not included it will
      #     by default not append a netmask to the generated ip. If you pass this
      #     argument as 0 it will not append a mask, any other value for this
      #     argument will append the netmask to the ip.
      # @param ip: The base ip to be built, this can either be all numbers, or an
      #     'x' can be substituted and will be replaced with the vlan parameter. For
      #     example 'x.x.x.0', '255.255.255.5' and '255.x.255.4' are all valid
      #     examples. Avoid passing the final number as an 'x'. For example
      #     '255.255.255.x' is not recommended, however it will not throw an error.
      # @param mask: The netmask to be appended to the ip, do not include a '/',
      #     just the actual number of the netmask. Netmask appending can be toggled
      #     with the 'nomask' parameter.
      # @param vlan: The vlan id. This value will replace any instance of 'x' in the
      #     submitted ip parameter. This parameter's default value is 0.
      # @return: A string containing the generated ipv4 ip.
      #
      def build_ip(nomask=0, ip="#{@resource[:ip]}", mask="#{@resource[:mask]}",
                   vlan="#{@resource[:vlan]}")
        k = ip.split('.')
        ip_out = ''
        for i in (0..3)
          if k[i] == 'x'
            k[i] = "#{vlan}"
          end
          if i == 3
            ip_out += "#{k[i]}"
          else
            ip_out += "#{k[i]}."
          end
        end
        unless nomask == 0
          ip_out += "/#{mask}"
        end
        ip_out
      end

      # Helper method to find out what your vrouter-interface nic is. This method
      # causes a failure if it cannot find the interface that was specified.
      # @param include_vlan: This value can be anything. If it is not included it
      #     will by default not include the vlan in the nic. If you set it to
      #     anything other than 0, your return value will be in the format
      #     'eth#.vlan#' instead of 'eth#.'.
      # @param vrouter_name: The name of the vrouter where the nic is being
      #     investigated. Defaults to the vrouter specified in the manifest.
      # @param vlan: The associated vlan to the desired nic. Defaults to the vlan
      #     specified in the manifest file.
      # @return: A string containing the nic.
      #
      def get_nic(include_vlan=0, vrouter_name="#{@resource[:vrouter]}")
        cmd = "/usr/bin/cli --quiet #{current_switch} vrouter-interface-show " +
            "vrouter-name #{vrouter_name} format nic,ip " +
            "parsable-delim % no-show-headers"
        message("Executing '" + cmd + "'")
        out = `#{cmd}`
        out.split("\n").each do |interface|
          vrouter, nic, ip = interface.split('%')
          if ip.strip == build_ip
            if include_vlan != 0
              return nic
            else
              return nic.split('.')[0] + '.'
            end
          end
          # if interface.split('%')[1].split('.')[1].strip == vlan
          #   if include_vlan != 0
          #     return interface.split('%')[1]
          #   else
          #     return interface.split('%')[1].split('.')[0] + '.'
          #   end
          # end
        end
        message("Couldn't find the specified vRouter interface.", 'fail')
      end

      # Returns the cli switch accessor as a string.
      # @param switch: The switch who's cli accessor should be returned,
      #     defaults to the switch specified in a manifest.
      #
      def current_switch(switch="#{@resource[:switch]}")
        if switch == 'local'
          'switch-local'
        else
          "switch #{switch}"
        end
      end

      # Sometimes you need a SPLAT!
      # This method does the same thing as current switch but the return value
      # from this method can be splatted into commands that use shell ordering
      # (:cli). Use with *PuppetX::Pluribus::PnHelper.new(resource).splat_switch
      # @param switch: The switch who's cli accessor should be returned,
      #     defaults to the switch specified in a manifest.
      #
      def splat_switch(switch="#{@resource[:switch]}")
        if switch == 'local'
          ['switch-local']
        else
          ['switch', switch]
        end
      end

    end
  end
end
