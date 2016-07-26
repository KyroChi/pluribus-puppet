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

Puppet::Type.type(:pn_vrouter_ospf).provide(:netvisor) do

  commands :cli => 'cli'

  def self.instances
    get_ospf.collect do |ospf|
      ospf_props = get_ospf_props(ospf)
      new(ospf_props)
    end
  end

  def self.get_ospf
    cli('vrouter-ospf-show', PDQ).split("\n")
  end

  def self.get_ospf_props(ospf)
    ospf_props = {}
    ospf = ospf.split('%')
    ospf_props[:ensure]    = :present
    ospf_props[:provider]  = :netvisor
    ospf_props[:name]      = ospf[1] + ' ' + ospf[2] + '/' + ospf[3]
    ospf_props[:ospf_area] = ospf[4]
    ospf_props
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
    # If the vrouter doesn't exist we check for a vrouter on the current switch
    # if one exists it will be removed and the named one in the OSPF decleration
    # will be used

    vrouter = resource[:name].split(' ')[0]

    vrouters = cli('vrouter-show', 'format', 'name', PDQ).split("\n")
    locations = cli('vrouter-show', 'format', 'location', PDQ).split("\n")

    unless vrouters.include? vrouter
      if locations.include? `hostname`.strip
        vrouter = cli('vrouter-show', 'location', `hostname`.strip, 'format', 'name', PDQ).strip
        cli('vrouter-delete', 'name', vrouter)
      end
      cli('vrouter-create', 'name', "#{vrouter}", 'vnet',
          'puppet-ansible-fab-global', 'hw-vrrp-id', '18', 'router-id',
          '192.168.10.1')
      vrouter = "#{vrouter}"
    end

    cli(*splat_switch, 'vrouter-ospf-add', 'vrouter-name',
        vrouter, 'network', resource[:name].split(' ')[1],
        'ospf-area', resource[:ospf_area])
  end

  def destroy
    vrouter = resource[:name].split(' ')[0]

    cli(*splat_switch, 'vrouter-ospf-remove', 'vrouter-name',
        vrouter, 'network', resource[:name].split(' ')[1].split('/')[0])
  end

  def ospf_area
    @property_hash[:ospf_area]
  end

  def ospf_area=(value)
    destroy
    create
  end

  def switch
    resource[:switch]
  end

end
