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
  # 1000s of VLANs this will be prohibitively bloated

  commands :cli => 'cli'

  # Query Netvisor for information about a specific VLAN. This is a helper
  # method that can be called instead of using Puppet pre-fetching to generate a
  # property_hash.
  # @param id: The id of the VLAN you are requesting information from.
  # @param format: The format string to be passed to the cli.
  # @return: A string containing the response from Netvisor. Returns nothing if
  #    no values where found.
  #
  def get_vlan_info(id, format)
    info = cli('--quiet', 'vlan-show', 'id', id, 'format', format,
               'no-show-headers').split("\n")
    if info[0]
      info[0].strip!
    end
  end

  # Checks that the resource is present on the queried system. If the resource
  # is not on the switch, Netvisor will return '' which can be checked for by
  # exists?
  # @return: true if resource is present, false otherwise
  #
  def exists?
    @H = PuppetX::Pluribus::PnHelper.new(resource)
    @ids = @H.deconstruct_range
    for id in @ids do
      unless get_vlan_info(id, 'id')
        return false
      end
    end
    true
  end

  #
  #
  #
  def create
    for id in @ids do
      cli('vlan-create', 'id', id, 'scope', resource[:scope],
          'ports', resource[:ports], 'description', resource[:description])
    end
  end

  #
  #
  #
  def destroy
    for id in @ids do
      cli('vlan-delete', 'id', id)
    end
  end

  def scope
    for id in @ids do
      if get_vlan_info(id, 'scope') != resource[:scope]
        return "Incorrect Scope"
      end
    end
    resource[:scope]
  end

  # Sets the scope of the queried resource. Since scope is not modifiable by the
  # CLI, we must destroy the VLAN and re-create it. This gives the end-user the
  # ability to easily change VLAN scope without manually re-creating the VLANs
  # @param value: un-used, can be ignored but not removed.
  #
  def scope=(value)
    destroy
    create
  end

  # Checks the current state of the VLAN description on the switch.
  # @return: The current state of the VLAN's description.
  #
  def description
    for id in @ids do
      if get_vlan_info(id, 'description') != resource[:description]
        return "Incorrect Description"
      end
    end
    resource[:description]
  end

  # Sets the desired description for the VLAN that has been specified. Because
  # we can change the description from the cli, there is no reason to destroy
  # and recreate description when we need to change the value.
  # @param value: The value of the new description, this will be filled in by
  #    Puppet.
  #
  def description=(value)
    for id in @ids do
      cli('vlan-modify', 'id', id, 'description', value)
    end
  end

  # Checks if the VLANs statistics are enabled.
  # @return: :enable if stats are enabled, :disable otherwise.
  #
  def stats
    if get_vlan_info(@ids[0], 'stats') == 'yes'
      :enable
    else
      :disable
    end
  end

  #
  #
  #
  def stats=(value)
    cli('--quiet', 'vlan-stats-settings-modify', value)
  end

  #
  #
  #
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

  #
  #
  #
  def ports=(value)
    destroy
    create
  end

  #
  #
  #
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

  #
  #
  #
  def untagged_ports=(value)
    destroy
    create
  end

end

