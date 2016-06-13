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

Puppet::Type.newtype(:pn_vrouter_vrrp) do

  desc ''

  ensurable

  newparam(:vlan) do
    isnamevar
  end

  newproperty(:switch) do
    defaultto(:local)
  end

  newproperty(:vrouter) do

  end

  newproperty(:ip) do

  end

  newproperty(:mask) do

  end

  newproperty(:if_type) do
    defaultto(:data)
    newvalues(:mgmt, :data, :span)
  end

  newproperty(:vrrp_id) do
    # number between 0..255
    defaultto('none')
  end

  newproperty(:primary_ip) do
    # vrrp-primary | vrrp-primary-string
    defaultto('none')
  end

  newproperty(:vrrp_priority) do
    # number between 0..254
    defaultto('none')
  end

end