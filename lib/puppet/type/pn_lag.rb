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
