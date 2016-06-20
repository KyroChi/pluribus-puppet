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

node default { }

# Demo tear-down of the clustering between two switches and their vRouters.
# @nodes: dorado-tme-1, dorado-tme-2
# @connections:
# dorado-tme-1 port 1 <-> dorado-tme-2 port 1
# dorado-tme-1 port 2 <-> dorado-tme-2 port 2
# @tear-down:
# - destroy cluster called tme-cluster between dorado-tme-1 and dorado-tme-2
# - destroy LAG(trunk) on dorado-tme-1 called tme-link-ag
# - destroy LAG(trunk) on dorado-tme-2 called tme-link-ag-2
# - destriy vLAG called tme-to-tme between dorado-tme-1 and dorado-tme-2
# - destroy 5 vLANS in a range from 101-105
# - destroy 5 vRouter ip interfaces in a range from 101-105
# - destroy 5 vRouter VRRP interfaces in a range from 101-105
#
node dorado-tme-2 {
  pn_cluster { 'tme-cluster':
    ensure => absent,
    nodes => ['dorado-tme-2', 'dorado-tme-1'],
  }
  pn_lag { 'tme-link-ag': # Must be the same as pn_vlag port
    ensure => absent,
    switch => 'dorado-tme-1',
    ports => '11,12,13,14',
    require => Pn_cluster['tme-cluster']
  }
  pn_lag { 'tme-link-ag-2': # Must be the same as the peer port
    ensure => absent,
    switch => 'dorado-tme-2',
    ports => '11,12,13,14',
    require => Pn_cluster['tme-cluster']
  }
  pn_vlag { 'tme-to-tme':
    ensure => absent,
    switch => 'dorado-tme-1',
    peer_switch => 'dorado-tme-2',
    port => 'tme-link-ag',
    peer_port => 'tme-link-ag-2',
    mode => active,
    require => [Pn_lag['tme-link-ag'], Pn_lag['tme-link-ag-2']]
  }
  pn_vlan { ['101', '102', '103', '104', '105']:
    ensure => absent,
    description => 'desc',
    scope => 'fabric',
    ports => 'none',
    require => Pn_vrouter['demo-vrouter'],
  }
  pn_vrouter { 'demo-vrouter':
    ensure => absent,
    vnet => 'puppet-ansible-chef-fab-global',
    hw_vrrp_id => 18,
    service => enable,
  }
}
