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

  @doc = "Manage vRouters.

Properties

name is the name of the vRouter to be managed. Name can be any string as long as
it only contains letters, numbers, _, ., :, and -.

ensure tells Puppet how to manage the vRouter. Ensuring present will mean that
the vRouter will be created and present on the switch after a completed catalog
run. Setting this to absent will ensure that the vRouter is not present on the
system after the catalog run.

vnet is the name of the vNET assigned to the vRouter.

hw_vrrp_id is a hardware id for VRRP interfaces that may live on this vRouter.

service simply enables or diables the vRouter. This can be set to either enable
or disable. By default this is set to enable.

bgp_as is the AS number for any BGP interfaces that you will create later. Can
be any integer. By default this property is set to '' and tells Puppet not to
set up BGP on the vRouter. (This can always be changed in the manifest later.)

switch the switch where the vRouter will live, this can be the name of any
switch on the fabric. By deafult this value is set to local and creates a
vRouter on whatever node is specified in the manifest.

Example Implementation

CLI:
```
CLI (...) > vrouter-create name demo-vrouter vnet demo-vnet-global hw-vrrp-id
18 enable
```

Puppet:
```
pn_vrouter { 'demo-vrouter':
    ensure     => present,
    vnet       => 'demo-vnet-global',
    hw_vrrp_id => 18,
    service    => enable,
}
```
"

  ensurable

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
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'vRouter name can only contain letters, ' +
            'numbers, _, ., :, and -'
      end
    end
  end

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

  newproperty(:hw_vrrp_id) do
    validate do |value|
      if value =~ /[^\d*$]/
        raise ArgumentError, 'hw_vrrp_id must be a number'
      end
    end
  end

  newproperty(:bgp_as) do
    defaultto('')
    validate do |value|
      if value =~ /[^\d*$]/ and value != ''
        raise ArgumentError, 'bgp_as must be a number'
      end
    end
  end

end
