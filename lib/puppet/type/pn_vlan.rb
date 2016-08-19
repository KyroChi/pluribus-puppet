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

Puppet::Type.newtype(:pn_vlan) do

  desc "Manage vLANs.

Properties

id is the vLAN id, this can be any number between 2 and 4092.

ensure tells Puppet how to manage the vLAN. Ensuring `present` will mean that the
vLAN will be created and present on the switch after a completed catalog run.
Setting this to `absent` will ensure that the vLAN is not present on the system
after the catalog run.

scope is the name of the vNET assigned to the vRouter.

description is the description of the vLAN. Can only contain `letters`,
`numbers`, `_`, `.`, `:`, and `-`. The default value is `'-'`.

ports is a comma separated list of ports that the vLAN will use. There cannot be
any whitespace separating the ports, ranges are allowed. The default value is
`'none'`

untagged_ports is a comma separated list of untagged ports that the vLAN will
use. There cannot be any whitespace separating the ports, ranges are allowed. The
default value is `'none'`

switch the switch where the vRouter will live, this can be the name of any switch
on the fabric. By default this value is set to `local` and creates a vRouter on
whatever node is specified in the manifest.

Example Implementation

CLI:
```
CLI (...) > vlan-create id 101 scope fabric description puppet-vlan ports none
untagged-ports none
```

Puppet:
```puppet
pn_vlan { '101':
    ensure         => present,
    scope          => fabric,
    description    => 'puppet-vlan',
    ports          => 'none',
    untagged_ports => 'none',
}
```"

  ensurable
  switch()

  newparam(:id) do
    desc "The id of the vLAN to be managed."
    isnamevar
    validate do |value|
      if value !~ /\d*/
        raise ArgumentError, 'ID must be a number'
      end
      unless value.to_i.between?(2, 4092)
        raise ArgumentError, 'ID must be between 2 and 4092'
      end
    end
  end

  newproperty(:scope) do
    desc "Set the scope of the specified fabric. Must be 'local' or 'fabric'"
    newvalues(:local, :fabric)
  end

  newproperty(:description) do
    desc 'Description of the specified fabric'
    defaultto('-')
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'Description can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  newproperty(:ports) do
    desc 'no whitespace comma seperated ports and port ranges'
    defaultto('none')
    validate do |value|
      unless value =~ /^((\d{1,4}-\d{1,4})|(\d{1,4})[,\s$]*){1,}$|^(\d{1,4})$/ \
                      or :none
        raise ArgumentError, 'Ports must be a number or range of numbers'
      end
    end
  end

  newproperty(:untagged_ports) do
    desc 'no whitespace comma seperated ports and port ranges'
    defaultto('none')
    validate do |value|
      unless value =~ /^((\d{1,4}-\d{1,4})|(\d{1,4})[,\s$]*){1,}$|^(\d{1,4})$/ \
                      or :none
        raise ArgumentError, 'Untagged ports must be a number or range of numbers'
      end
    end
  end

end

