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

Puppet::Type.type(:pn_lag).provide(:netvisor) do

  desc 'Provider: Netvisor'

  commands :cli => 'cli'

  def self.instances
    get_lags.collect do |lag|
      lag_props = get_lag_props(lag)
      new(lag_props)
    end
  end

  def self.get_lags
    out = cli('trunk-show', 'parsable-delim', '%',
              '--quiet').split("\n")
    out.sort
  end

  def self.get_lag_props(lag)
    lag_props = {}
    lag_props[:ensure] = :present
    lag_props[:provider] = :netvisor
    lag_props[:name] = lag.split('%')[2]
    lag_props[:ports] = lag.split('%')[3]
    lag_props
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
    cli(*splat_switch, 'trunk-create', 'name', resource[:name],
        'ports', resource[:ports])
  end

  def destroy
    ports = cli(*splat_switch, 'vlag-show', 'format', 'name,port,peer-port',
               'no-show-headers', PDQ).split("\n")
    debug(ports)
    ports.each do |p|
      name, port, peer_port = p.split("%", 3)
      if port == resource[:name] or peer_port == resource[:name]
        cli(*splat_switch, 'vlag-delete', 'name', name)
      end
    end
    cli(*splat_switch, 'trunk-delete', 'name', resource[:name])
  end

  def switch
    if cli(*splat_switch, Q) =~ /switch:/
      fail("Could not establish a connection to #{resource[:switch]}")
    else
      resource[:switch]
    end
  end

  def ports
    if deconstruct_range(resource[:ports]) ==
        deconstruct_range(@property_hash[:ports])
      return resource[:ports]
    else
      return @property_hash[:ports]
    end
  end

  def ports=(value)
    destroy
    create
  end

end