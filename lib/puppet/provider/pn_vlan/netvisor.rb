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

Puppet::Type.type(:pn_vlan).provide(:netvisor) do

  # Don't pre-fetch instances, on systems with established VLAN networks this
  # will cause puppet to spend ~2 seconds per VLAN and on systems with 100s or
  # 1000s of VLANs this will be prohibitively time-consuming

  commands :cli => 'cli'

  def get_vlan_info(id, format)
    info = cli('--quiet', 'vlan-show', 'id', id, 'format', format,
               'no-show-headers').split("\n")
    if info[0]
      info[0].strip!
    end
  end

  def exists?
    @H = PuppetX::Pluribus::PnHelper.new(resource)
    @ids = @H.deconstruct_range
    for id in @ids do
      unless get_vlan_info(id, 'id')
        create
      end
    end
    true
  end

  def create
    for id in @ids do
      unless get_vlan_info(id, 'id')
        cli('vlan-create', 'id', id, 'scope', resource[:scope],
            'ports', resource[:ports], 'description', resource[:description])
      end
    end
  end

  def destroy
    for id in @ids do
      if get_vlan_info(id, 'id')
        begin
          cli('vlan-delete', 'id', id)
        rescue => detail
          if detail =~ /router interface/
            nic = cli('vrouter-interface-show', 'vlan', id, 'format', 'nic',
                      @H.pdq).split '%'
            cli('vrouter-interface-remove', 'vrouter-name', nic[0],
                'nic', nic[1].strip)
          end
        end
      end
    end
  end

  def scope
    for id in @ids do
      if get_vlan_info(id, 'scope') != resource[:scope].to_s
        puts get_vlan_info(id, 'scope')
        return "Incorrect Scope"
      end
    end
    resource[:scope]
  end

  def scope=(value)
    destroy
    create
  end

  def description
    for id in @ids do
      if get_vlan_info(id, 'description') != resource[:description]
        return "Incorrect Description"
      end
    end
    resource[:description]
  end

  def description=(value)
    for id in @ids do
      cli('vlan-modify', 'id', id, 'description', value)
    end
  end

  def stats
    if get_vlan_info(@ids[0], 'stats') == 'yes'
      :enable
    else
      :disable
    end
  end

  def stats=(value)
    cli('--quiet', 'vlan-stats-settings-modify', value)
  end

  def ports
    for id in @ids do
      if get_vlan_info(id, 'ports') == '0'
        if resource[:ports] != 'none'
          return "Incorrect Ports"
        end
      else
        if get_vlan_info(id, 'ports') != resource[:ports]
          return "Incorrect Ports"
        end
      end
    end
    resource[:ports]
  end

  def ports=(value)
    destroy
    create
  end

  def untagged_ports
    for id in @ids do
      u_ports = get_vlan_info(id, 'untagged-ports')
      if u_ports == 'none' or u_ports == ''
        if resource[:untagged_ports] != :none
          "Incorrect Untagged Ports"
        end
      else
        if resource[:untagged_ports] != u_ports
          "Incorrect Untagged Ports"
        end
      end
    end
    resource[:untagged_ports]
  end

  def untagged_ports=(value)
    destroy
    create
  end

end

