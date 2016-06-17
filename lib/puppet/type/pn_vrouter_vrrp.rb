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
