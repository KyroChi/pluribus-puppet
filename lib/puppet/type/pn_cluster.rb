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

Puppet::Type.newtype(:pn_cluster) do

  # Heavy error checking done by provider

  @doc = "Allows for the management of clustered node. This type can create and
destroy and manage node clusters.

Properties

name sets the cluster name. This is the type's namevar and is required. This can
be any string as long as it only contains letters, numbers, _, ., :, and -.

ensure tells Puppet how to manage the cluster. Ensuring present will mean that
the cluster will be created and on the switch after a completed catalog run.
Setting this to absent will ensure that the cluster is not present on the system
after the catalog run.

nodes specifies the two nodes which will be clustered together. This property
takes an array of nodes that are present on the fabric. If the nodes are not
present Puppet will throw an error and not complete the catalog run. If you pass
more than two valid switches in the array only the first two will be used.

force_clustering forces a cluster between the specified nodes. It is not
recommended you use this but an example use case would be if two switches were
previously clustered incorrectly you could use force clustering to force the
correct switches into the desired cluster. The default value for this property
is no.

Example Implementation

This example implementation creates a simple cluster between two switches,
creatively named switch-01 and switch-02. Their cluster name, also creatively
named, is switch-cluster.

The following shows both the traditional CLI implementation and below it the
same command created in a Puppet manifest file.

CLI:
```
CLI (...) > cluster-create name switch-cluster cluster-node-1 switch-01
cluster-node-2 switch-02
```

Puppet:
```puppet
node your-pluribus-switch {

    pn_cluster { 'switch-cluster':
        ensure => present,
        nodes  => ['switch-01', 'switch-02']
    }

}
```"

  ensurable

  newparam(:name) do
    desc 'The name of the cluster'
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'Description can only contain letters, numbers,' +
            ' _, ., :, and -'
      end
    end
  end

  newproperty(:nodes, :array_matching => :all) do
    desc 'An array of nodes that will be present in the specified cluster'
  end

  newproperty(:force_clustering) do
    desc 'Forces the specified nodes to be put into a cluster'
    defaultto(:no)
    newvalues(:yes, :no)
  end

end
