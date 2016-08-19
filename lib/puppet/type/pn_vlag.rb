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

Puppet::Type.newtype(:pn_vlag) do

  # DON'T need to make twice for each cluster, switch and peer-switch
  # interchangeable.
  # Do serious error handling in the Provider instead so that the switch can be
  # queried during error checking.

  @doc = "Allow management of vLAGs. You must have LAGs/trunks in place on the
switches in a vLAG prior to declaring the vLAG.

Properties

name sets the vLAG name. This is the type's namevar and is required. This can
be any string as long as it only contains `letters`, `numbers`, `_`, `.`, `:`,
and `-`.

ensure tells Puppet how to manage the vLAG. Ensuring `present` will mean that
the vLAG will be created and present on the switch after a completed catalog run.
Setting this to `absent` will ensure that the vLAG is not present on the system
after the catalog run.

cluster tells Puppet which cluster the vLAG should be applied to.

port is the vLAG port on `switch`.

peer-port is the vLAG port on `peer-switch`.

mode the vLAG mode. Can either be set to `active` or `standby`, corresponding to
`active-active` and `active-standby` vLAG modes respectively. This property
defaults to `active`.

failover is how L2 failover will be handled by the vLAG. This can either be
specified as `move` or `ignore`. The default value for this property is `move`.

lacp_mode controls the link aggregation control protocol mode. This can be either
`active`, `passive` or `off`. The default value is `active`.

lacp_timeout sets the type of LACP timeout. This can be set to either `fast` or
`slow`. The default setting is `fast`.

lacp_fallback sets the fallback type of the LACP connection. This can be set to
either `bundle` or `individual`. By default, this value is set to `bundle`.

lacp_fallback_timeout sets the fallback timeout in seconds. This can be any
integer between `30` and `60`. By default the fallback timeout is set to `50`
seconds.

Example Implementation

The following example shows how to create trunks between two clusters. The
first cluster is called `spine-cluster` and contains the two nodes `spine-01`
and `spine-02`. The second cluster is called `leaf-cluster` and contains the two
nodes `leaf-01` and `leaf-02`. `spine-01` is connected to `leaf-01` on ports 11
and 12, and connected to `leaf-02` on 13 and 14. `spine-02` is connected to
`leaf-01` on ports 15 and 16, and connected to `leaf-02` on 17 and 18. The leaf
to spine ports are the same numbers for the leaves.

CLI:
```
CLI (...) > cluster-create name spine-cluster ...
CLI (...) > trunk-create name spine01-to-leaf ...
Created trunk spine02-to-leaf, id <#>
CLI (...) > trunk-create name spine02-to-leaf ...
Created trunk spine02-to-leaf, id <#>
CLI (...) > switch spine-01 vlag-create name spine-to-leaf port spine01-to-leaf
peer-switch spine02 peer-port leaf2-to-spine mode active-active
failover-ignore-L2 lacp-mode slow lacp-fallback bundle lacp-fallback-timeout 45
```

Puppet:
```puppet
pn_cluster { 'spine-cluster':
            ...
}

pn_lag { 'spine01-to-leaf':
            ...
    require => Pn_cluster['spine-cluster']
}

pn_lag { 'spine02-to-leaf':
            ...
    require => Pn_cluster['spine-cluster']
}

pn_vlag { 'spine-to-leafs':
    ensure                => present,
    cluster               => 'spine-cluster',
    port                  => 'spine01-to-leaf',
    peer-port             => 'spine02-to-leaf',
    mode                  => active,
    failover              => ignore,
    lacp_mode             => active,
    lacp_timeout          => slow,
    lacp_fallback         => bundle,
    lacp_fallback_timeout => 45,
    require               => Pn_lag['spine01-to-leaf',
                                    'spine02-to-leaf'],
}
````"

  ensurable
  switch()

  newparam(:name) do
    desc "vLAG name"
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'VLAG name can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  newproperty(:cluster) do
    desc "Name of the cluster whose two switches will be included in the vLAG"
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, "Invalid cluster name #{value}"
      end
    end
  end

  newproperty(:port) do
    desc "Name of the port where the VLAG will be created."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, "Invalid port name #{value}"
      end
    end
  end

  newproperty(:peer_port) do
    desc "Name of the port on the peer-switch where the VLAG will be created."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, "Invalid peer-port name #{value}"
      end
    end
  end

  newproperty(:mode) do
    desc "The VLAG mode, can be either active or standby."
    defaultto(:active)
    newvalues(:active, :standby)
  end

  newproperty(:failover) do
    desc "The L2 failover type, can either be move or ignore."
    defaultto(:move)
    newvalues(:move, :ignore)
  end

  newproperty(:lacp_mode) do
    desc "The VLAGs lacp mode, can be off, passive or active."
    defaultto(:active)
    newvalues(:off, :passive, :active)
  end

  newproperty(:lacp_timeout) do
    desc "The lacp timeout can either be fast or slow."
    defaultto(:fast)
    newvalues(:slow, :fast)
  end

  newproperty(:lacp_fallback) do
    desc "The lacp fallback, can be bundle or individual."
    defaultto(:bundle)
    newvalues(:bundle, :individual)
  end

  newproperty(:lacp_fallback_timeout) do
    desc "The lacp fallback timeout in seconds."
    defaultto('50')
    validate do |value|
      unless value.to_i.between?(30, 60)
        raise ArgumentError, "Timeout must be between 30 and 60 seconds"
      end
    end
  end

end
