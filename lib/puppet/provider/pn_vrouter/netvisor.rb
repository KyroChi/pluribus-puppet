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

require File.expand_path(
    File.join(File.dirname(__FILE__),
              '..', '..', '..', 'puppet_x', 'pn', 'mixin_helper.rb'))

include PuppetX::Pluribus::MixHelper

Puppet::Type.type(:pn_vrouter).provide(:netvisor) do

  desc 'Provider: Netvisor'

  commands :cli => 'cli'

  def self.instances
    get_vrouters.collect do |vrouter|
      vrouter_props = get_vrouter_props(vrouter)
      new(vrouter_props)
    end
  end

  def self.get_vrouters
    cli('vrouter-show', 'format',
        'name,vnet,hw-vrrp-id,bgp-as,router-id,location,state,' +
        'bgp-redistribute,bgp-max-paths', PDQ).split("\n")
  end

  def self.get_vrouter_props(vrouter)
    vrouter_props = {}
    vrouter = vrouter.split('%')
    vrouter_props[:ensure]           = :present
    vrouter_props[:provider]         = :netvisor
    vrouter_props[:name]             = vrouter[0]
    vrouter_props[:vnet]             = vrouter[1]
    vrouter_props[:hw_vrrp_id]       = vrouter[2]
    vrouter_props[:bgp_as]           = vrouter[3]
    vrouter_props[:router_id]        = vrouter[4]
    vrouter_props[:location]         = vrouter[5]
    vrouter_props[:service]          = vrouter[6] == 'enabled' ? :enable : :disable
    vrouter_props[:bgp_redistribute] = vrouter[7]
    vrouter_props[:bgp_max_paths]    = vrouter[8]
    vrouter_props
  end

  def self.prefetch(resources)
    instances.each do |provider|
      if resource = resources[provider.name]
        resource.provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create

    vrouter = resource[:name]

    vrouters = cli('vrouter-show', 'format', 'name', PDQ).split("\n")
    locations = cli('vrouter-show', 'format', 'location', PDQ).split("\n")

    unless vrouters.include? vrouter
      if locations.include? switch_location
        vrouter = cli('vrouter-show', 'location', switch_location, 'format',
                      'name', PDQ).strip
        cli(*splat_switch, 'vrouter-delete', 'name', vrouter)
      end
    end

    out = cli('--quiet', *splat_switch, 'vrouter-create',
              'name', resource[:name], 'vnet', resource[:vnet],
              'hw-vrrp-id', resource[:hw_vrrp_id],
              resource[:service])

    if out =~ /not the name of a switch/
      # Can't belive I have to do this check
      fail('Switch does not exist')
    end

    if resource[:bgp_as] != :none
      cli('vrouter-modify', 'name', resource[:name], 'bgp-as', resource[:bgp_as])
    end

    if resource[:router_id] != :none
      cli('vrouter-modify', 'name', resource[:name],
          'router-id', resource[:router_id])
    end

  end

  def destroy
    cli(*splat_switch, 'vrouter-delete', 'name', resource[:name])
  end

  def switch
    resource[:switch]
  end

  def vnet
    @property_hash[:vnet]
  end

  def vnet=(value)
    destroy
    create
  end

  def hw_vrrp_id
    @property_hash[:hw_vrrp_id]
  end

  def hw_vrrp_id=(value)
    destroy
    create
  end

  def service
    @property_hash[:service]
  end

  def service=(value)
    cli(*splat_switch, 'vrouter-modify',
        'name', resource[:name], value, Q)
  end

  def bgp_as
    if resource[:bgp_as] == :none
      return resource[:bgp_as]
    end
    @property_hash[:bgp_as]
  end

  def bgp_as=(value)
    cli(*splat_switch, 'vrouter-modify',
        'name', resource[:name], 'bgp-as', value, Q)
  end

  def router_id;
    if resource[:router_id] == :none
      return resource[:router_id]
    end
    @property_hash[:router_id]
  end

  def router_id=(value)
    cli('--quiet', *splat_switch, 'vrouter-modify',
        'name', resource[:name], 'router-id', value)
  end

  def bgp_redistribute
    @property_hash[:bgp_redistribute]
  end

  def bgp_redistribute=(value)
    cli(*splat_switch, 'vrouter-modify', resource[:name],
        'bgp-redistribute', value)
  end

  def bgp_max_paths
    @property_hash[:bgp_max_paths]
  end

  def bgp_max_paths=(value)
    cli(*splat_switch, 'vrouter-modify', resource[:name],
       'bgp-max-paths', value)
  end

end

