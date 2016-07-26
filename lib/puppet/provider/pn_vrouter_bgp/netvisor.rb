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

Puppet::Type.type(:pn_vrouter_bgp).provide(:netvisor) do

  commands :cli => 'cli'

  def self.instances
    get_bgp.collect do |bgp|
      bgp_props = get_bgp_props(bgp)
      new(bgp_props)
    end
  end

  def self.get_bgp
    cli('vrouter-bgp-show', 'format', 'neighbor,remote-as', PDQ).split("\n")
  end

  def self.get_bgp_props(bgp)
    bgp_props = {}
    bgp = bgp.split('%')
    bgp_props[:ensure]   = :present
    bgp_props[:provider] = :netvisor
    bgp_props[:name]     = bgp[0] + ' ' + bgp[1]
    bgp_props[:bgp_as]   = bgp[2]
    bgp_props
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
    vrouter, neighbor = resource[:name].split(' ')
    cli(Q, *splat_switch, 'vrouter-bgp-add', 'vrouter-name', vrouter,
        'neighbor', neighbor, 'remote-as', resource[:bgp_as])
  end

  def destroy
    vrouter, neighbor = resource[:name].split(' ')
    cli(Q, *splat_switch, 'vrouter-bgp-remove', 'vrouter-name', vrouter,
        'neighbor', neighbor)
  end

  def switch
    resource[:switch]
  end

  def bgp_as
    @property_hash[:bgp_as]
  end

  def bgp_as=(value)
    vrouter, neighbor = resource[:name].split(' ')
    cli(Q,  *splat_switch, 'vrouter-bgp-modify', 'vrouter-name', vrouter,
        'neighbor', neighbor, 'remote-as', value)
  end

end
