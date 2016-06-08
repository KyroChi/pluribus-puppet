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

Puppet::Type.newtype(:pn_lag) do

  # Handle serious error checking with provider instead of type.

  @doc = "Manage LAGs/Trunks

~~~puppet
pn_lag { '<name>':
    switch => <switch-name>,
    ensure => <:present|:absent,
    ports => <ports>
}
~~~

name: The name of the LAG to manage
switch: The name of the Switch where the LAG will live
ensure: Present or Absent, does LAG exist
ports: none, all, or a comma separated list of ports with no whitespace.

See examples in doc/pn_lag"

  ensurable

  # LAG name must follow the naming conventions set forth by the cli. Since
  # LAG names are not unique the system cannot use self.prefetch and
  # self.instances to gather resources. The switch resource is enough to develop
  # individuality between the LAGs.
  # @return: nil
  #
  newparam(:name, :namevar => true) do
    desc "Name of the LAG to create"
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'LAG name can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  # Since on a fabric level LAG names do not need to be unique, the switch is a
  # required parameter that will tell the provider where the LAG should be
  # created on a fabric wide level.
  # @return: nil
  #
  newproperty(:switch) do
    # Add support for passing arrays to this property
    desc "Name of the switch where the LAG will be created. Must be on the" +
             " same fabric as the Puppet Agent"
    validate do |value|
      if value =~ /\s/
        raise ArgumentError, "Invalid switch name #{value}"
      end
    end
  end

  # Ports for the LAG to aggregate. Since the cli accepts a comma-separated list
  # the easiest way to pass the ports as a parameter to the provider is to pass
  # them as a comma separated list.
  # @return: nil
  #
  newproperty(:ports) do
    desc "Comma separated list, no whitespace, all, or none. (ie. '1,2,3,4')"
    defaultto('none')
    validate do |value|
      if value =~ /\s/
        raise ArgumentError, 'Ports cannot be separated by whitespace'
      end
    end
  end

end