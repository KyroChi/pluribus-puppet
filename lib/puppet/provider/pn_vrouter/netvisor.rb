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

  # Don't pre-fetch as there are too many instances to query and they are not
  # guaranteed to have unique identifiers across nodes.

  desc 'Provider: Netvisor'

  commands :cli => 'cli'

  def get_vrouter_info(format, name="#{resource[:name]}")
    cli(Q, *splat_switch, 'vrouter-show', 'name', name, 'format', format,
        'no-show-headers').strip
  end

  def exists?
    @BGP = (resource[:bgp_as] != '' and resource[:router_id] != 'none') ?
        true : false
    unless cli(*splat_switch, Q) == ''
      fail("Switch #{resource[:switch]} could not be found on the fabric.")
    end
    if cli('vnet-show', 'name', resource[:vnet], Q) == ''
      fail("vNET #{resource[:vnet]} could not be found.")
    end
    if get_vrouter_info('name') != ''
      return true
    end
    false
  end

  def create
    cli('--quiet', *splat_switch, 'vrouter-create',
        'name', resource[:name], 'vnet', resource[:vnet],
        'hw-vrrp-id', resource[:hw_vrrp_id],
        resource[:service])
    if @BGP
      cli('--quiet', *splat_switch, 'vrouter-modify',
          'name', resource[:name], 'bgp-as', resource[:bgp_as],
          'router-id', resource[:router_id])
    elsif resource[:bgp_as] != '' and resource[:router_id] == 'none' or
        resource[:bgp_as] == '' and resource[:router_id] != 'none'
      warn('All BGP parameters must be supplied to enable BGP on this vRouter')
    end
  end

  def destroy
    cli(*splat_switch, 'vrouter-delete', 'name', resource[:name])
  end

  def switch
    resource[:switch]
  end

  def vnet
    get_vrouter_info('vnet')
  end

  def vnet=(value)
    destroy
    create
  end

  def hw_vrrp_id
    get_vrouter_info('hw-vrrp-id')
  end

  def hw_vrrp_id=(value)
    destroy
    create
  end

  def service
    if get_vrouter_info('state') == 'enabled'
      return :enable
    end
    return :disable
  end

  def service=(value)
    cli(*splat_switch, 'vrouter-modify',
        'name', resource[:name], value, Q)
  end

  def bgp_as
    if @BGP
      get_vrouter_info('bgp-as')
    end
    resource[:bgp_as]
  end

  def bgp_as=(value)
    cli(*splat_switch, 'vrouter-modify',
        'name', resource[:name], 'bgp-as', value, Q)
  end

  def router_id;
    if @BGP
      id = get_vrouter_info('router-id')
      if id == '' and resource[:router_id] == 'none'
        return resource[:router_id]
      end
      return id
    end
    resource[:router_id]
  end

  def router_id=(value)
    cli('--quiet', *splat_switch, 'vrouter-modify',
        'name', resource[:name], 'router-id', value)
  end

end

