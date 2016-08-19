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

require 'ipaddr'

Puppet::Type.newtype(:pn_vrouter_ospf) do

  @doc = "Manage vrouter OSPF interfaces.

Properties

name is a netmasked ip address where the OSPF interface will be created.

ensure tells Puppet how to manage the cluster. Ensuring `present` will
mean that the cluster will be created and on the switch after a completed catalog
run. Setting this to `absent` will ensure that the cluster is not present on the
system after the catalog run.

ospf_area is the OSPF area where the vrouter interface will live.

switch is the name of the switch where the IP interface will be created.
This can be any switch on the fabric. The default value is `local`, which creates
an IP interface on the node where the resource was declared.

Example Implementation

CLI:
```
CLI (...) > vrouter-ospf-add vrouter vrouter-name network 192.168.0.9 netmask 24
ospf-area 0
```

Puppet:
```puppet
node your-pluribus-switch {
  pn_vrouter_ospf { '192.168.0.9/24':
    ensure    => present,
    ospf_area => 0,
  }
}
```"

  ensurable
  switch()

  newparam(:name) do
    desc 'A netmasked ip address'
    munge do |value|
      # *Rolls eyes* convert an ip to its netmasked ip
      vrouter, ip = value.split(' ')
      mask = /\/(.*)/.match(ip).to_s
      ip = IPAddr.new(ip).to_s
      value = vrouter + ' ' + ip + mask
    end
  end

  newproperty(:ospf_area) do
    desc 'The ospf area where the ospf interface will be created.'
    validate do |value|
      if value =~ /[^\d*$]/ and value != ''
        raise ArgumentError, 'ospf area must be a number'
      end
    end
  end

end
