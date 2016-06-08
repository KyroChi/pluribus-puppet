# Copyright (C) 2016 Pluribus Networks
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

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
    if get_vlan_info(resource[:name], 'id')
      return true
    end
    false
  end

  #
  #
  #
  def create
    cli('vlan-create', 'id', resource[:name], 'scope', resource[:scope],
        'ports', resource[:ports], 'description', resource[:description])
  end

  #
  #
  #
  def destroy
    cli('vlan-delete', 'id', resource[:name])
  end

  # Checks for the scope on the queried system.
  # @return: the current state of the queried VLAN's scope
  #
  def scope
    get_vlan_info(resource[:name], 'scope')
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
    get_vlan_info(resource[:name], 'description')
  end

  # Sets the desired description for the VLAN that has been specified. Because
  # we can change the description from the cli, there is no reason to destroy
  # and recreate description when we need to change the value.
  # @param value: The value of the new description, this will be filled in by
  #    Puppet.
  #
  def description=(value)
    cli('vlan-modify', 'id', resource[:name], 'description', value)
  end

  # Checks if the VLANs statistics are enabled.
  # @return: :enable if stats are enabled, :disable otherwise.
  #
  def stats
    if get_vlan_info(resource[:name], 'stats') == 'yes'
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
    if get_vlan_info(resource[:name], 'ports') == '0'
      'none'
    else
      get_vlan_info(resource[:name], 'ports')
    end
  end

  #
  #
  #
  def ports=(value)
    # use port-add and port-remove
    scope=(value)
  end

  #
  #
  #
  def untagged_ports
    # does Netvisor return an array or an arg
    u_ports = get_vlan_info(resource[:name], 'untagged-ports')
    if u_ports == 'none' or ''
      :none
    else
      u_ports
    end
  end

  #
  #
  #
  def untagged_ports=(value)
    # use port-add and port-remove
    scope=(value)
  end

end
