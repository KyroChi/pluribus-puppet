# Copyright (C) 2016 Pluribus Networks
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Puppet::Type.newtype(:pn_cluster) do

  # The provider for pn_cluster does a lot of the error handling as it can access
  # the CLI to verify connectivity. The type can handle basic error checking but
  # most of the work is done in the provider.

  ensurable

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