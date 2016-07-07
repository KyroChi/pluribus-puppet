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

Puppet::Type.type(:pn_vlag).provide(:netvisor) do

  desc 'Provider: Netvisor'

  # no path so only one provider for Solaris and Linux
  #  both platforms have cli in /usr/bin/cli

  commands :cli => 'cli'

  def self.instances
    get_vlags.collect do |vlag|
      vlag_props = get_vlag_props(vlag)
      new(vlag_props)
    end
  end

  def self.get_vlags
    out = cli('vlag-show', 'format', 'all', PDQ).split("\n")
    out.sort
  end

  def self.get_vlag_props(vlag)
    vlag_props = {}
    vlag_props[:ensure]                = :present
    vlag_props[:provider]              = :netvisor
    vlag_props[:name]                  = vlag.split('%')[1]
    vlag_props[:cluster]               = vlag.split('%')[2]
    vlag_props[:mode]                  = vlag.split('%')[3] == 'active-active' \
                                          ? :active : :standby
    vlag_props[:port]                  = vlag.split('%')[5]
    vlag_props[:peer_port]             = vlag.split('%')[7]
    vlag_props[:failover]              = vlag.split('%')[8] == 'no' \
                                          ? :ignore : :move
    vlag_props[:lacp_mode]             = vlag.split('%')[11]
    vlag_props[:lacp_timeout]          = vlag.split('%')[12]
    vlag_props[:lacp_fallback]         = vlag.split('%')[15]
    vlag_props[:lacp_fallback_timeout] = vlag.split('%')[16]
    vlag_props
  end

  def self.prefetch(resources)
    instances.each do |provider|
      if resource = resources[provider.name]
        resource.provider = provider
      end
    end
  end

  def exists?
    @switch1, @switch2 = cli('cluster-show', 'name', resource[:cluster],
                             'format', 'cluster-node-1,cluster-node-2',
                             PDQ).split('%')
    @switch2 ? @switch2.strip! : @switch2
    @property_hash[:ensure] == :present
  end

  def create
    # switch port and peer-port positions if try 1 errors, need to replace with
    # something other than a try-catch
    begin
      cli('switch', @switch1, 'vlag-create',
          'name', resource[:name],
          'port', resource[:port],
          'peer-port', resource[:peer_port],
          'mode', "active-#{resource[:mode]}",
          'peer-switch', @switch2,
          "failover-#{resource[:failover]}-L2",
          'lacp-mode', resource[:lacp_mode],
          'lacp-timeout', resource[:lacp_timeout],
          'lacp-fallback', resource[:lacp_fallback],
          'lacp-fallback-timeout', resource[:lacp_fallback_timeout])
    rescue
      cli('switch', @switch1, 'vlag-create',
          'name', resource[:name],
          'port', resource[:peer_port],
          'peer-port', resource[:port],
          'mode', "active-#{resource[:mode]}",
          'peer-switch', @switch2,
          "failover-#{resource[:failover]}-L2",
          'lacp-mode', resource[:lacp_mode],
          'lacp-timeout', resource[:lacp_timeout],
          'lacp-fallback', resource[:lacp_fallback],
          'lacp-fallback-timeout', resource[:lacp_fallback_timeout])
    end
  end

  mk_resource_methods

  def destroy
    cli('vlag-delete', 'name', resource[:name])
  end

  def cluster=(value)
    destroy
    create
  end

  def port=(value)
    destroy
    create
  end

  def peer_port=(value)
    destroy
    create
  end

  def mode=(value)
    destroy
    create
  end

  def failover=(value)
    cli('vlag-modify', 'name', resource[:name],
        "failover-#{value}-L2")
  end

  def lacp_mode=(value)
    destroy
    create
  end

  def lacp_timeout=(value)
    cli('vlag-modify', 'name', resource[:name], "lacp-timeout", value)
  end

  def lacp_fallback=(value)
    cli('vlag-modify', 'name', resource[:name], 'lacp-fallback', value)
  end

  def lacp_fallback_timeout=(value)
    cli('vlag-modify', 'name', resource[:name], 'lacp-fallback-timeout', value)
  end

end