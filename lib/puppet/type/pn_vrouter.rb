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

Puppet::Type.newtype(:pn_vrouter) do

  @doc = ""

  ensurable

  ##############################################################################
  # These properties are check-able under vrouter-show
  ##############################################################################

  # vRouter name, as a convention it should be named after the switch or
  # switches that the vRouter lives on. This parameter must be unique to your
  # fabric. name is not an optional parameter and has no defaults.
  #
  newparam(:name) do
    desc "The name of the vRouter to manage."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'vRouter name can only contain letters, ' +
            'numbers, _, ., :, and -'
      end
    end
  end

  newproperty(:switch) do
    defaultto('local')
  end

  #
  #
  newproperty(:vnet) do
    desc "vNET assigned to the service."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'vNET name can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  newproperty(:service) do
    desc ""
    defaultto(:enable)
    newvalues(:enable, :disable)
  end

  #
  #
  newproperty(:hw_vrrp_id) do

  end

  #
  #
  newproperty(:bgp_as) do
    defaultto('')
  end

end
