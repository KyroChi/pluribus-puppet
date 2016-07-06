module PuppetX
  module Pluribus

    # Use PnHelper as a mixin module in your provider
    module MixHelper

      @resources = {}

      Q   = ['--quiet']
      # PDQ means no 'no-show-headers' is needed
      PDQ = ['parsable-delim', '%', Q]

      # Feed a range, returns an array.
      # accepts comma separated, with or without whitespace, and range operators
      # if the numbers are reversed it will add them in order as if they were in
      # the correct order.
      # all valid ranges: '1', '1,2,3', '1-3', '1-3, 4-7,8-19,    32-22, 88-88'
      def deconstruct_range (range)
        out = []
        return out if range.length == 0
        range.to_s.gsub(' ', '').split(',').each do |s|
          if s =~ /-/
            lo, hi = s.split('-')
            hi = hi.to_i; lo = lo.to_i
            hi, lo = lo, hi if hi < lo
            hi == lo ? out.push(hi.to_s) : (lo..hi).each { |i| out.push i.to_s }
          else
            out.push s.to_s
          end
        end
        out
      end

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
      # @param vlan: The associated vlan to the desired nic. Defaults to the
      #     vlan specified in the manifest file.
      # @return: A string containing the nic.
      #
      def get_nic(include_vlan=0, vrouter_name="#{resource[:vrouter]}",
                  ipin="#{resource[:ip]}", mask='24', vlan='101')
        out = cli(*splat_switch, "vrouter-interface-show", "vrouter-name",
               "#{vrouter_name}", "format", "nic,ip", *pdq)
        out.split("\n").each do |interface|
          vrouter, nic, ip = interface.split('%')
          if ip.strip == build_ip(0, ipin, mask, vlan)
            include_vlan != 0 ? (return nic) : (return nic.split('.')[0] + '.')
          end
        end
        ''
      end

    end

  end
end