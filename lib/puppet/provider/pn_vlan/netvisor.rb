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

Puppet::Type.type(:pn_vlan).provide(:netvisor) do

  commands :cli => 'cli'

  def get_vlan_info(id, format)
      info = cli(Q, 'vlan-show', 'id', id, 'format', format,
                 'no-show-headers').split("\n")
    if info[0]
      return info[0].strip
    end
    return nil
  end

  def self.instances
    get_vlans.collect do |vlan|
      vlan_props = get_vlan_props(vlan)
      new(vlan_props)
    end
  end

  def self.get_vlans
    cli('vlan-show', 'format',
        'id,scope,description,ports,untagged-ports,stats', PDQ).split("\n")
  end

  def self.get_vlan_props(vlan)
    vlan_props = {}
    vlan = vlan.split('%')
    vlan_props[:ensure]         = :present
    vlan_props[:provipder]      = :netvisor
    vlan_props[:name]           = vlan[0]
    vlan_props[:scope]          = vlan[1]
    vlan_props[:description]    = vlan[2]
    vlan_props[:ports]          = vlan[3]
    vlan_props[:untagged_ports] = vlan[4]
    vlan_props[:stats]          = vlan[5]
    vlan_props
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
    cli(*splat_switch, 'vlan-create', 'id', resource[:name], 'scope',
        resource[:scope], 'ports', resource[:ports], 'description',
        resource[:description])
  end

  def destroy
    if get_vlan_info(resource[:name], 'id')
      switch = get_vlan_info(resource[:name], 'switch')

      nics = cli('vrouter-interface-show', 'vlan',
                resource[:name], 'format', 'nic', PDQ).split("\n")

      nics.sort.reverse.each do |nic|
        nic = nic.split('%')
        location = cli('vrouter-show', 'name', nic[0], 'format', 'location',
                       PDQ).strip
        out = cli('switch', location, 'vrouter-interface-remove',
                  'vrouter-name', nic[0], 'nic', nic[1].strip)
      end
      cli(*splat_switch(switch), 'vlan-delete', 'id', resource[:name])
    end
  end

  def scope
    @property_hash[:scope]
  end

  def scope=(value)
    destroy
    create
  end

  def description
    @property_hash[:description]
  end

  def description=(value)
    if get_vlan_info(resource[:name], 'switch') != resource[:switch]
      cli(*splat_switch(get_vlan_info(resource[:name], 'switch')), 'vlan-modify',
          'id', resource[:name], 'description', value)
    else
      cli(*splat_switch, 'vlan-modify', 'id', resource[:name], 'description',
          value)
    end
  end

  def ports
    actual_ports = @property_hash[:ports]
    if actual_ports == '0'
      if resource[:ports] == 'none'
        return resource[:ports]
      end
    else
      if actual_ports == resource[:ports] or
        "0,#{resource[:ports]}" == actual_ports
        return resource[:ports]
      end
    end
    actual_ports
  end

  def ports=(value)
    destroy
    create
  end

  def untagged_ports
    u_ports = @property_hash[:untagged_ports]
    if u_ports == 'none' or u_ports == ''
      if resource[:untagged_ports] == :none
        return resource[:untagged_ports]
      end
    else
      if resource[:untagged_ports] == u_ports or
        "0, #{resource[:untagged_ports]}" == u_ports
        return resource[:untagged_ports]
      end
    end
    u_ports
  end

  def untagged_ports=(value)
    destroy
    create
  end

  def switch
    resource[:switch]
  end

end

