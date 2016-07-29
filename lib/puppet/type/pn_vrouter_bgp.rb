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
                    '..', '..', 'puppet_x', 'pn', 'type_helper.rb'))

include PuppetX::Pluribus::TypeHelper

Puppet::Type.newtype(:pn_vrouter_bgp) do

  desc "Manage vRouter BGP interfaces. To create a BGP interface you must first
create a [`pn_vrouter_ip`](#pn_vrouter_ip) so that the BGP interface has an
established ip interface to live on.

#### Properties

**`name`** is a combination of the vRouter name and the BGP neighbor IP address,
separated by a space.

**`ensure`** tells Puppet how to manage the BGP interface. Ensuring `present`
will mean that the BGP interface will be created and present on the switch after
a completed catalog run. Setting this to `absent` will ensure that the BGP
interface is not present on the system after the catalog run.

**`bgp_as`** is the AS ID for the BGP interface.

**_`increment`_** is how much the address will be incremented by in a range.

**_`switch`_** is the name of the switch where the vRouter BGP interface will
be hosted. This can be any switch on the fabric. The default value is `local`
which creates a BGP interface on the node where the resource was declared.

#### Example Implementation

CLI:
```
CLI (...) > vrouter-create name demo-vrouter vnet demo-vnet-global hw-vrrp-id 18
enable bgp-as 65001
CLI (...) > vlan-create id 101 scope fabric
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 101.101.101.2/24
vlan 101 if data
CLI (...) > vrouter-bgp-add vrouter-name demo-vrouter neighbor 101.101.101.1
remote_as 65001 bfd
```

Puppet:
```puppet
pn_vrouter { 'demo-vrouter':
    ensure => present,
    vnet => 'demo-vnet-global',
    hw-vrrp-id => 18,
    service => enable,
    bgp_as => '65001',
}

pn_vlan { '101':
    require => Pn_vrouter['demo-vrouter'],
    ensure => present,
    scope => 'fabric',
    description => 'bgp',
}

pn_vrouter_ip { '101':
    require => Pn_vlan['101'],
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.2',
    mask => '24',
}

pn_vrouter_bgp { 'demo-vrouter 101.101.101.1':
    require => Pn_vrouter_ip['101'],
    ensure => present,
    bgp_as => '65001',
}
```"

  ensurable
  switch()

  newparam(:name) do
    validate do |d|
      vrouter, ip, overflow = d.split ' '
      if vrouter =~ /[^\w.:-]/
        raise ArgumentError, 'vRouter name can only contain letters, numbers,' +
            ' _, ., :, and -'
      end
      if ip !~ /^((?:[0-9]{1,3}\.){3}([0-9]{1,3})(,|\z))*$/
        raise ArgumentError, 'Name must include an IP or BGP pattern'
      end
      raise ArgumentError, 'Too many arguments' if overflow
    end
  end

  newproperty(:bgp_as) do
    desc "The BGP AS number as specified by the vRouter."
    validate do |value|
      unless (1..4294967295) === value.to_i
        raise ArgumentError, 'BGP AS must be between 1 and 4294967295'
      end
    end
  end

end

