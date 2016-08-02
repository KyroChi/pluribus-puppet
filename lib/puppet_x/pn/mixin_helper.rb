module PuppetX
  module Pluribus

    # Use PnHelper as a mixin module in your provider
    module MixHelper

      @resources = {}

      Q   = ['--quiet']
      # PDQ means no 'no-show-headers' is needed
      PDQ = ['parsable-delim', '%', Q]

      # Sometimes you need a SPLAT!
      # This method does the same thing as current switch but the return value
      # from this method can be splatted into commands that use shell ordering
      # (:cli). Use with *splat_switch
      # @param switch: The switch who's cli accessor should be returned,
      #     defaults to the switch specified in a manifest.
      #
      def splat_switch(switch="#{resource[:switch]}")
        switch == 'local' ? ['switch-local'] : ['switch', switch]
      end

      # Helper method to find out what your vrouter-interface nic is. This
      # method causes a failure if it cannot find the interface that was
      # specified.
      # @param include_vlan: This value can be anything. If it is not included
      #     it will by default not include the vlan in the nic. If you set it to
      #     anything other than 0, your return value will be in the format
      #     'eth#.vlan#' instead of 'eth#.'.
      # @param vrouter_name: The name of the vrouter where the nic is being
      #     investigated. Defaults to the vrouter specified in the manifest.
      # @return: A string containing the nic.
      #
      def get_nic(include_vlan=0, vrouter_name="#{resource[:vrouter]}",
                  ipin="#{resource[:ip]}", mask='24')
        out = cli(*splat_switch, "vrouter-interface-show", "vrouter-name",
               "#{vrouter_name}", "format", "nic,ip", PDQ)
        out.split("\n").each do |interface|
          vrouter, nic, ip = interface.split('%')
          if ip.strip == build_ip(0, ipin, mask)
            include_vlan != 0 ? (return nic) : (return nic.split('.')[0] + '.')
          end
        end
        ''
      end

      # Helper method to build an ip address string
      # @param nomask: This value can be anything. If it is not included it will
      #     by default not append a netmask to the generated ip. If you pass
      #     this argument as 0 it will not append a mask, any other value for
      #     this argument will append the netmask to the ip.
      # @param ip: The base ip to be built, this can either be all numbers, or
      #     an 'x' can be substituted and will be replaced with the vlan
      #     parameter. For example 'x.x.x.0', '255.255.255.5' and '255.x.255.4'
      #     are all valid examples. Avoid passing the final number as an 'x'.
      #     For example '255.255.255.x' is not recommended, however it will not
      #     throw an error.
      # @param mask: The netmask to be appended to the ip, do not include a '/',
      #     just the actual number of the netmask. Netmask appending can be
      #     toggled with the 'nomask' parameter.
      # @return: A string containing the generated ipv4 ip.
      #
      def build_ip(nomask=0, ip="#{@resource[:ip]}", mask="#{@resource[:mask]}")
        k = ip.split('.')
        ip_out = ''
        for i in (0..3)
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

      # Returns the name of the current switch, use this if you need the actual
      # location but there is a possibility that switch is defined as local.
      # This is some really simple logic but I find myself using it a lot.
      # @param defined: The switch name, defaults to resource[:switch]
      # @return: A string containing the hostname of the system being managed
      #
      def switch_location(defined=resource[:switch])
        (defined == :local or defined == 'local') ? `hostname`.strip : defined
      end

    end

  end
end
