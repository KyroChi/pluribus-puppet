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
              '..', '..', '..', 'puppet_x', 'pn', 'pn_helper.rb'))
require File.expand_path(
    File.join(File.dirname(__FILE__),
              '..', '..', '..', 'puppet_x', 'pn', 'pn_vrouter_helper.rb'))

Puppet::Type.type(:pn_vrouter_ip).provide(:netvisor) do

  # no path so only one provider for Solaris and Linux
  #  both platforms have cli in /usr/bin/cli
  #
  commands :cli => 'cli'

  # Checks vrouter name than check that the vlan matches 'eth#.<vlan>'
  #
  def exists?
    # Create a new PnHelper and PnVrouterHelper
    @v_h = PuppetX::Pluribus::PnVrouterHelper.new(resource)
    vrouters = cli('--quiet', *@v_h.splat_switch, 'vrouter-interface-show',
                   'vrouter-name', resource[:vrouter], 'format', 'nic',
                   'no-show-headers', 'parsable-delim', '%').split("\n")
    vrouters.each do |v|
      i = v.split('%')
      if i[1].strip.split(".")[1] == resource[:vlan] and
          i[0] == resource[:vrouter]
        return true
      end
    end
    false
  end

  def create
    ip = @v_h.build_ip(1)
    cli('--quiet', *@v_h.splat_switch, 'vrouter-interface-add', 'vrouter-name',
        resource[:vrouter], 'ip', ip, 'vlan', resource[:vlan], 'if', 'data')
  end

  def destroy
    cli('--quiet', *@v_h.splat_switch, 'vrouter-interface-remove',
        'vrouter-name', resource[:vrouter], 'nic', @v_h.get_nic(1))
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

end
