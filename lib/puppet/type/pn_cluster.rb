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

  # The provider for pn_cluster does a lot of the error handling as it can
  # access the CLI to verify connectivity. The type can handle basic error
  # checking but most of the work is done in the provider.

  ensurable

  # @pn-docs ignore

  # Name of cluster, either existing or want to create.
  #
  newparam(:name) do
    desc 'The name of the cluster'
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'Description can only contain letters, numbers,' +
            ' _, ., :, and -'
      end
    end
  end

  # Array of two nodes to be put into a cluster
  #
  newproperty(:nodes, :array_matching => :all) do
    desc 'An array of nodes that will be present in the specified cluster'
  end

  # **Force Clustering**
  # /Dangerous/
  # This command forces the specified clustering, this may be an intentional
  # behavior, however forcing clustering usually means that there is something
  # wrong with the topology. It is recommended that you investigate why the
  # nodes are configured in a cluster already and disable that cluster by name
  # prior to setting up a new cluster in Puppet. This command will erase any
  # configured clusters that may be present, which can disrupt network
  # communications, especially on VLAN connections that are dependent on
  # existing clusters.
  #
  # CURRENTLY NOT IMPLEMENTED
  #
  newproperty(:force_clustering) do
    desc 'Forces the specified nodes to be put into a cluster'
    defaultto(:no)
    newvalues(:yes, :no)
  end

end
