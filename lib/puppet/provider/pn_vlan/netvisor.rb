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

  def deconstruct_range(namevar="#{resource[:name]}")
    range = []
    if namevar =~ /-/
      start, stop = namevar.split('-', 2)
      if start > stop
        start, stop = stop, start
      elsif start == stop
        range.push(start)
      end
      (start..stop).each { |i| range.push(i) }
    else
      range.push(namevar)
    end
    range
  end

  # Checks that the resource is present on the queried system. If the resource
  # is not on the switch, Netvisor will return '' which can be checked for by
  # exists?
  # @return: true if resource is present, false otherwise
  #
  def exists?
    @ids = deconstruct_range
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
