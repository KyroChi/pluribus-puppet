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

  commands :cli => 'cli'

  def get_vlan_info(id, format)
    info = cli('vlan-show', 'id', id, 'parsable-delim', '%', 'format', format,
               'no-show-headers').split("\n")
  end
  
  def exists?
    get_vlan_info(resource[:name], 'id').length != 0
  end

  def scope
    get_vlan_info(resource[:name], 'scope')[0]
  end

  def scope=(value)
    destroy
    create
  end

  def description
    get_vlan_info(resource[:name], 'description')[0]
  end

  def description=(value)
    cli('vlan-modify', 'id', resource[:name], 'description', value)
  end

  def stats
    if get_vlan_info(resource[:name], 'stats')[0] == 'yes'
      :enable
    else
      :disable
    end
  end
    
  def stats=(value)
    cli('vlan-stats-settings-modify', value)[0]
  end

  def ports
    if get_vlan_info(resource[:name], 'ports')[0] == '0'
      'none'
    else
      get_vlan_info(resource[:name], 'ports')[0]
    end
  end

  def ports=(value)
    # use port-add and port-remove
    scope=(value)
  end

  def untagged_ports
    # does Netvisor return an array or an arg
    get_vlan_info(resource[:name], 'untagged-ports')[0]
  end

  def untagged_ports=(value)
    # use port-add and port-remove
    scope=(value)
  end

  def create
    cli('vlan-create', 'id', resource[:name], 'scope', resource[:scope],
        'ports', resource[:ports])
  end

  def destroy
    cli('vlan-delete', 'id', resource[:name])
  end

end
