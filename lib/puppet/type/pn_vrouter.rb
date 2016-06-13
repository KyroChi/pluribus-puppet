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

Puppet::Type.newtype(:pn_vrouter) do

  @doc = ""

  ensurable

  ##############################################################################
  # These properties are check-able under vrouter-show
  ##############################################################################

  # vRouter name, as a convention it should be named after the switch or
  # switches that the vRouter lives on. This parameter must be unique to your
  # fabric. name is not an optional parameter and has no defaults.
  #
  newparam(:name) do
    desc "The name of the vRouter to manage."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'vRouter name can only contain letters, ' +
            'numbers, _, ., :, and -'
      end
    end
  end

  # #
  # newproperty(:type) do
  #
  # end

  # newproperty(:scope) do
  #
  # end

  #
  #
  newproperty(:vnet) do
    desc "vNET assigned to the service."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'vNET name can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  newproperty(:service) do
    desc ""
    defaultto(:enable)
    newvalues(:enable, :disable)
  end

  # #
  # #
  # newproperty(:is_global) do
  #   desc ""
  #   defaultto(:false)
  #   newvalues(:true, :false)
  # end

  # #
  # #
  # newproperty(:vnet_service) do
  #   desc "Service as dedicated or shared."
  #   defaultto(:dedicated)
  #   newvalues(:dedicated, :shared)
  # end
  #
  # #
  # #
  # newproperty(:state) do
  #   desc "State of the vRouter service."
  #   defaultto(:enable)
  #   newvalues(:enable, :disable)
  # end

  # newproperty(:router_type) do
  #
  # end
  #
  # newproperty(:hw_router_mac) do
  #
  # end
  #

  #
  #
  newproperty(:hw_vrrp_id) do

  end

  # newproperty(:proto_multi) do
  #
  # end
  #
  # newproperty(:bgp_scantime) do
  #
  # end
  #
  # #
  # #
  # newproperty(:bgp_keepalive_interval) do
  #   desc "BGP Keepalive interval (seconds) - default 60."
  #   default('60')
  #   validate do |value|
  #     unless value.to_i.between?(0, 65535)
  #       raise ArgumentError, "BGP Keepalive interval must be between 0 and " +
  #           "65535 seconds."
  #     end
  #   end
  # end
  #
  # newproperty(:bgp_holdtime) do
  #
  # end
  #
  # ##############################################################################
  # # These properties are check-able under vrouter-show format all
  # ##############################################################################
  #
  # newproperty(:id) do
  #
  # end
  #
  # newproperty(:location) do
  #
  # end
  #
  # newproperty(:zone_id) do
  #
  # end
  #
  # newproperty(:template) do
  #
  # end
  #
  # newproperty(:failover_action) do
  #
  # end
  #
  # newproperty(:bgp_redist_static_metric) do
  #
  # end
  #
  # newproperty(:bgp_redist_connected_metric) do
  #
  # end
  #
  # newproperty(:bgp_redist_rip_metric) do
  #
  # end
  #
  # newproperty(:bgp_redist_ospf_metric) do
  #
  # end
  #
  # #
  # #
  # newproperty(:bgp_dampening) do
  #   desc "Dampening for BGP routes."
  #   defaultto(:false)
  #   newvalues(:true, :false)
  # end
  #
  # #
  # #
  # newproperty(:bgp_graceful_restart) do
  #   desc "Restart BGP gracefully."
  #   defaultto(:false)
  #   newvalues(:true, :false)
  # end
  #
  # newproperty(:bgp_ipv4_unicast) do
  #
  # end
  #
  # newproperty(:ospf_redist_static_metric) do
  #
  # end
  #
  # newproperty(:ospf_redist_static_metric_type) do
  #
  # end
  #
  # newproperty(:ospf_redist_connected_metric) do
  #
  # end
  #
  # newproperty(:ospf_redist_connected_metric_type) do
  #
  # end
  #
  # newproperty(:ospf_redist_rip_metric) do
  #
  # end
  #
  # newproperty(:ospf_redist_rip_metric_type) do
  #
  # end
  #
  # newproperty(:ospf_redist_bgp_metric) do
  #
  # end
  #
  # newproperty(:ospf_redist_bgp_metric_type) do
  #
  # end
  #
  # newproperty(:ospf_stup_router_on_startup) do
  #
  # end
  #
  # newproperty(:ospf6_redist_static_metric) do
  #
  # end
  #
  # newproperty(:ospf6_redist_static_metric_type) do
  #
  # end
  #
  # newproperty(:ospf6_redist_connected_metric) do
  #
  # end
  #
  # newproperty(:ospf6_redist_connected_metric_type) do
  #
  # end

end