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

node default { }

# Demo setup of two switches in a cluster and a vRouter.
# @nodes: dorado-tme-1, dorado-tme-2
# @connections:
# dorado-tme-1 port 1 <-> dorado-tme-2 port 1
# dorado-tme-1 port 2 <-> dorado-tme-2 port 2
# @setup:
# - a cluster called tme-cluster between dorado-tme-1 and dorado-tme-2
# - a LAG(trunk) on dorado-tme-1 called tme-link-ag on ports 11, 12, 13 and 14
# - a LAG(trunk) on dorado-tme-2 called tme-link-ag-2 on ports 11, 12, 13 and 14
# - a vLAG called tme-to-tme between dorado-tme-1 and dorado-tme-2 using the
#    previously created trunks
# - 5 vLANS in a range from 101-105 with scope fabric
# - 5 vRouter ip interfaces in a range from 101-105
# - 5 vRouter VRRP interfaces in a range from 101-105
#
node dorado-tme-2 {
  pn_cluster { 'tme-cluster':
    ensure => present,
    nodes => ['dorado-tme-2', 'dorado-tme-1'],
  }
  pn_lag { 'tme-link-ag': # Must be the same as pn_vlag port
    ensure => present,
    switch => 'dorado-tme-1',
    ports => '11,12,13,14',
    require => Pn_cluster['tme-cluster']
  }
  pn_lag { 'tme-link-ag-2': # Must be the same as the peer port
    ensure => present,
    switch => 'dorado-tme-2',
    ports => '11,12,13,14',
    require => Pn_cluster['tme-cluster']
  }
  pn_vlag { 'tme-to-tme':
    ensure => present,
    switch => 'dorado-tme-1',
    peer_switch => 'dorado-tme-2',
    port => 'tme-link-ag',
    peer_port => 'tme-link-ag-2',
    mode => active,
    require => [Pn_lag['tme-link-ag'], Pn_lag['tme-link-ag-2']]
  }
  pn_vlan { ['101', '102', '103', '104', '105']:
    ensure => present,
    description => 'desc',
    scope => 'fabric',
    ports => 'none',
  }
  pn_vrouter { 'demo-vrouter':
    ensure => present,
    vnet => 'puppet-ansible-chef-fab-global',
    hw_vrrp_id => 18,
    service => enable,
  }
  # ip interface
  pn_vrouter_ip{ ['101', '102', '103', '104', '105']:
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.3',
    mask => '24',
    require => Pn_vrouter['demo-vrouter']
  }
  # vrrp interface
  pn_vrouter_vrrp{ ['101', '102', '103', '104', '105']:
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.1',
    mask => '24',
    vrrp_id => '18',
    primary_ip => 'x.x.x.3',
    vrrp_priority => '110',
    require => Pn_vrouter_ip['101', '102', '103', '104', '105']
  }
}