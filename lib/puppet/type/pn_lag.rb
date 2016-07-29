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

Puppet::Type.newtype(:pn_lag) do

  # Handle serious error checking with provider instead of type.

  @doc = "Allows for the management of trunks or LAGs.

Properties

name sets the trunk name. This is the type's namevar and is required. This can
be any string as long as it only contains letters, numbers, _, ., :, and -.

ensure tells Puppet how to manage the trunk. Ensuring present will mean that the
trunk will be created and present on the switch after a completed catalog run.
Setting this to absent will ensure that the trunk is not present on the system
after the catalog run.

switch is the name of the switch where the link aggregation will occur. This
should be a switch that is both on the same network as the Puppet agent and the
same fabric. If Puppet cannot find the specified switch it will throw an error
during the catalog run.

ports are the ports to be aggregated. This should be passed as a comma separated
list, no whitespace, and port ranges are allowed.

Example Implementation

The following example shows how to create trunks between two clusters. The first
cluster is called spine-cluster and contains the two nodes spine-01 and
spine-02. The second cluster is called leaf-cluster and contains the two nodes
leaf-01 and leaf-02. spine-01 is connected to leaf-01 on ports 11 and 12, and
connected to leaf-02 on 13 and 14. spine-02 is connected to leaf-01 on ports
15 and 16, and connected to leaf-02 on 17 and 18. The leaf to spine ports are
the same numbers for the leaves.

CLI:

CLI (...) > switch spine-01 trunk-create name spine01-to-leaf ports 11,12,13,14
Created trunk spine01-to-leaf, id <id>
CLI (...) > switch spine-02 trunk-create name spine02-to-leaf ports 15,16,17,18
Created trunk spine02-to-leaf, id <id>
CLI (...) > switch leaf-01 trunk-create name leaf01-to-spine ports 11,12,15,16
Created trunk leaf01-to-spine, id <id>
CLI (...) > switch leaf-02 trunk-create name leaf02-to-spine ports 13,14,17,18
Created trunk leaf02-to-spine, id <id>
Puppet:

node your-pluribus-switch {

    pn_lag { 'spine01-to-leaf':
        ensure => present,
        switch => 'spine-01',
        ports  => '11-14',
    }

    pn_lag { 'spine02-to-leaf':
        ensure => present,
        switch => 'spine-02',
        ports  => '15-18',
    }

    pn_lag { 'leaf01-to-spine':
        ensure => present,
        switch => 'leaf-01',
        ports  => '11,12,15,16',
    }

    pn_lag { 'leaf02-to-spine':
        ensure => present,
        switch => 'leaf-02',
        ports  => '13,14,17,18',
    }

}"

  ensurable
  switch()

  newparam(:name, :namevar => true) do
    desc "Name of the LAG to create"
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'LAG name can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  newproperty(:ports) do
    desc "Comma separated list, 'all', or 'none'. (ie. '1,2,3,4')"
    defaultto('none')
    validate do |value|
      unless value =~ /^((\d{1,4}-\d{1,4})|(\d{1,4})[,\s$]*){1,}$|^(\d{1,4})$/ \
      or :none
        raise ArgumentError, 'Ports must be a number or range of numbers'
      end
    end
  end

end
