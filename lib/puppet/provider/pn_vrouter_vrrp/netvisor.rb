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

Puppet::Type.type(:pn_vrouter_vrrp).provide(:netvisor) do

  # no path so only one provider for Solaris and Linux
  #  both platforms have cli in /usr/bin/cli
  #
  commands :cli => 'cli'

  #
  #
  def get_vrrp_info(format)
    cli('--quiet', 'vrouter-interface-show', 'vrouter-name', resource[:vrouter],
        'nic', @v_h.get_nic(1), 'format', format, 'no-show-headers',
        'parsable-delim', '%').split('%')[1].strip
  end

  #
  #
  def build_vrrp_primary(interface="#{resource[:primary_ip]}")
    # if interface == 'x.x'
    #   return @v_h.get_nic(1)
    # elsif interface =~ /^\D{3}\d{1,}\.x$/
    #   return interface.split('.')[0] + vlan
    # elsif interface =~ /^x\.\S(\d*)$/
    #   return @v_h.get_nic(0) + '1' + interface.split('.')[1]
    # else
    #   return interface
    # end
    out = cli('--quiet', 'vrouter-interface-show', 'ip',
              @v_h.build_ip(0, interface), 'format', 'nic',
              'parsable-delim', '%').split('%')
    unless out[1].nil?
      return out[1].strip
    end
    fail('no primary interface')
  end

  def vrrp_modify(value)
    cli('--quiet', 'vrouter-interface-modify', 'vrouter-name',
        resource[:vrouter], 'nic',
        @v_h.get_nic(1), 'vrrp-priority', value)
  end

  # Checks vrouter name than check that the vlan matches 'eth#.<vlan>'
  #
  def exists?
    # Create a new PnHelper and PnVrouterHelper
    @v_h = PuppetX::Pluribus::PnVrouterHelper.new(resource)
    vrouters = cli('--quiet', *@v_h.splat_switch, 'vrouter-interface-show',
                   'vrouter-name', resource[:vrouter], 'format', 'ip',
                   'no-show-headers', 'parsable-delim', '%').split("\n")
    vrouters.each do |v|
      i = v.split('%')
      if i[1].strip == @v_h.build_ip and
          i[0] == resource[:vrouter]
        return true
      end
    end
    false
  end

  def create
    cli('--quiet', *@v_h.splat_switch, 'vrouter-interface-add',
        'vrouter-name', resource[:vrouter], 'ip', @v_h.build_ip(1),
        'vlan', resource[:vlan], 'if', 'data', 'vrrp-id', resource[:vrrp_id],
        'vrrp-primary', build_vrrp_primary,
        'vrrp-priority', resource[:vrrp_priority])
  end

  def destroy
    cli('--quiet', 'vrouter-interface-remove', 'vrouter-name',
        resource[:vrouter], 'nic',
        @v_h.get_nic(1))
  end

  # Never called if vrouter returns true
  def vrouter
    return resource[:vrouter]
  end

  def switch
    return resource[:switch]
  end

  def ip
    @v_h.get_ip
  end

  def ip=(value)
    destroy
    create
  end

  def mask
    @v_h.get_mask_value
  end

  def mask=(value)
    destroy
    create
  end

  def if_type
    resource[:if_type]
  end

  def vrrp_id
    get_vrrp_info('vrrp-id')
  end

  def vrrp_id=(value)
    destroy
    create
  end

  def primary_ip
    # get_vrrp_info('vrrp-primary')
    resource[:primary_ip]
  end

  def primary_ip=(value)
    vrrp_modify(value)
  end

  def vrrp_priority
    get_vrrp_info('vrrp-priority')
  end

  def vrrp_priority=(value)
    vrrp_modify(value)
  end

end

