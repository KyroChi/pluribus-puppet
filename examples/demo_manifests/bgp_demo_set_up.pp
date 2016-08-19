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

# Combine ip and vrrp interfaces and make it so that you can submit ranges
# to the interface

$spine1 = 'charmander'
$spine2 = 'squirtle'

$leaf1 = 'pikachu'
$leaf2 = 'gyarados'
$leaf3 = 'lapras'
$leaf4 = 'jigglypuff'

$vnet = 'no-fail-fab-global'

pn_vrouter { 'spine1-vrouter':
  ensure           => present,
  vnet             => $vnet,
  switch           => $spine1,
  bgp_as           => 65000,
  router_id        => '192.168.7.0',
  bgp_redistribute => connected,
  bgp_max_paths    => 16,
}

pn_vrouter { 'spine2-vrouter':
  ensure           => present,
  vnet             => $vnet,
  switch           => $spine2,
  bgp_as           => 65000,
  router_id        => '192.168.7.1',
  bgp_redistribute => connected,
  bgp_max_paths    => 16,
}

pn_vrouter { 'leaf1-vrouter':
  ensure           => present,
  vnet             => $vnet,
  switch           => $leaf1,
  bgp_as           => 65002,
  router_id        => '192.168.7.2',
  bgp_redistribute => connected,
  bgp_max_paths    => 16,
}

pn_vrouter { 'leaf2-vrouter':
  ensure           => present,
  vnet             => $vnet,
  switch           => $leaf2,
  bgp_as           => 65002,
  router_id        => '192.168.7.3',
  bgp_redistribute => connected,
  bgp_max_paths    => 16,
}

pn_vrouter { 'leaf3-vrouter':
  ensure           => present,
  vnet             => $vnet,
  switch           => $leaf3,
  bgp_as           => 65002,
  router_id        => '192.168.7.4',
  bgp_redistribute => connected,
  bgp_max_paths    => 16,
}

pn_vrouter { 'leaf4-vrouter':
  ensure           => present,
  vnet             => $vnet,
  switch           => $leaf4,
  bgp_as           => 65002,
  router_id        => '192.168.7.5',
  bgp_redistribute => connected,
  bgp_max_paths    => 16,
}

############################
# Spine 1 interfaces

pn_vrouter_if { 'spine1-vrouter 100.100.100.1/24':
  require => Pn_vrouter['spine1-vrouter'],
  ensure  => present,
  vlan => 100,
  l3_port => '41',
  switch  => $spine1,
}

pn_vrouter_if { 'spine1-vrouter 101.101.101.1/24':
  require => Pn_vrouter['spine1-vrouter'],
  ensure  => present,
  vlan => 101,
  l3_port => '43',
  switch  => $spine1,
}

pn_vrouter_if { 'spine1-vrouter 102.102.102.1/24':
  require => Pn_vrouter['spine1-vrouter'],
  ensure  => present,
  vlan => 102,
  l3_port => '45',
  switch  => $spine1,
}

pn_vrouter_if { 'spine1-vrouter 103.103.103.1/24':
  require => Pn_vrouter['spine1-vrouter'],
  ensure  => present,
  vlan => 103,
  l3_port => '47',
  switch  => $spine1,
}

pn_vrouter_if { 'spine2-vrouter 104.104.104.1/24':
  require => Pn_vrouter['spine1-vrouter'],
  ensure  => present,
  vlan => 104,
  l3_port => '39',
  switch  => $spine2,
}

pn_vrouter_if { 'spine2-vrouter 105.105.105.1/24':
  require => Pn_vrouter['spine2-vrouter'],
  ensure  => present,
  vlan => 105,
  l3_port => '43',
  switch  => $spine2,
}

pn_vrouter_if { 'spine2-vrouter 106.106.106.1/24':
  require => Pn_vrouter['spine2-vrouter'],
  ensure  => present,
  vlan => 106,
  l3_port => '45',
  switch  => $spine2,
}

pn_vrouter_if { 'spine2-vrouter 107.107.107.1/24':
  require => Pn_vrouter['spine2-vrouter'],
  ensure  => present,
  vlan => 107,
  l3_port => '47',
  switch  => $spine2,
}

pn_vrouter_if { 'leaf1-vrouter 108.108.108.1/24':
  require => Pn_vrouter['leaf1-vrouter'],
  ensure  => present,
  vlan => 108,
  l3_port => '1',
  switch  => $leaf1,
}

pn_vrouter_if { 'leaf1-vrouter 109.109.109.1/24':
  require => Pn_vrouter['leaf1-vrouter'],
  ensure  => present,
  vlan => 109,
  l3_port => '3',
  switch  => $leaf1,
}

pn_vrouter_if { 'leaf2-vrouter 110.110.110.1/24':
  require => Pn_vrouter['leaf2-vrouter'],
  ensure  => present,
  vlan => 110,
  l3_port => '1',
  switch  => $leaf2,
}

pn_vrouter_if { 'leaf2-vrouter 111.111.111.1/24':
  require => Pn_vrouter['leaf2-vrouter'],
  ensure  => present,
  vlan => 111,
  l3_port => '3',
  switch  => $leaf2,
}

pn_vrouter_if { 'leaf3-vrouter 112.112.112.1/24':
  require => Pn_vrouter['leaf3-vrouter'],
  ensure  => present,
  vlan => 112,
  l3_port => '1',
  switch  => $leaf3,
}

pn_vrouter_if { 'leaf3-vrouter 113.113.113.1/24':
  require => Pn_vrouter['leaf3-vrouter'],
  ensure  => present,
  vlan => 113,
  l3_port => '3',
  switch  => $leaf3,
}

pn_vrouter_if { 'leaf4-vrouter 114.114.114.1/24':
  require => Pn_vrouter['leaf4-vrouter'],
  ensure  => present,
  vlan => 114,
  l3_port => '1',
  switch  => $leaf4,
}

pn_vrouter_if { 'leaf4-vrouter 115.115.115.1/24':
  require => Pn_vrouter['leaf4-vrouter'],
  ensure  => present,
  vlan => 115,
  l3_port => '3',
  switch  => $leaf4,
}

pn_vrouter_loopback { 'spine1-vrouter 192.168.10.1':
  require => Pn_vrouter['spine1-vrouter'],
  ensure => present,
}

pn_vrouter_loopback { 'spine2-vrouter 192.168.10.2':
  require => Pn_vrouter['spine1-vrouter'],
  ensure => present,
}

pn_vrouter_loopback { 'leaf1-vrouter 192.168.10.3':
  require => Pn_vrouter['spine1-vrouter'],
  ensure => present,
}

pn_vrouter_loopback { 'leaf2-vrouter 192.168.10.4':
  require => Pn_vrouter['spine1-vrouter'],
  ensure => present,
}

pn_vrouter_loopback { 'leaf3-vrouter 192.168.10.5':
  require => Pn_vrouter['spine1-vrouter'],
  ensure => present,
}

pn_vrouter_loopback { 'leaf4-vrouter 192.168.10.6':
  require => Pn_vrouter['spine1-vrouter'],
  ensure => present,
}

pn_vrouter_bgp { 'spine1-vrouter 192.168.7.2':
  require => Pn_vrouter_loopback['spine1-vrouter 192.168.10.1'],
  ensure => present,
  bgp_as => 65000,
}

pn_vrouter_bgp { 'spine1-vrouter 192.168.7.3':
  require => Pn_vrouter_loopback['spine1-vrouter 192.168.10.1'],
  ensure => present,
  bgp_as => 65000,
}

pn_vrouter_bgp { 'spine1-vrouter 192.168.7.4':
  require => Pn_vrouter_loopback['spine1-vrouter 192.168.10.1'],
  ensure => present,
  bgp_as => 65000,
}

pn_vrouter_bgp { 'spine1-vrouter 192.168.7.5':
  require => Pn_vrouter_loopback['spine1-vrouter 192.168.10.1'],
  ensure => present,
  bgp_as => 65000,
}

pn_vrouter_bgp { 'spine2-vrouter 192.168.7.2':
  require => Pn_vrouter_loopback['spine2-vrouter 192.168.10.2'],
  ensure => present,
  bgp_as => 65001,
}

pn_vrouter_bgp { 'spine2-vrouter 192.168.7.3':
  require => Pn_vrouter_loopback['spine2-vrouter 192.168.10.2'],
  ensure => present,
  bgp_as => 65001,
}

pn_vrouter_bgp { 'spine2-vrouter 192.168.7.4':
  require => Pn_vrouter_loopback['spine2-vrouter 192.168.10.2'],
  ensure => present,
  bgp_as => 65001,
}

pn_vrouter_bgp { 'spine2-vrouter 192.168.7.5':
  require => Pn_vrouter_loopback['spine2-vrouter 192.168.10.2'],
  ensure => present,
  bgp_as => 65001,
}

pn_vrouter_bgp { 'leaf1-vrouter 192.168.7.0':
  require => Pn_vrouter_loopback['leaf1-vrouter 192.168.10.3'],
  ensure => present,
  bgp_as => 65002,
}

pn_vrouter_bgp { 'leaf1-vrouter 192.168.7.1':
  require => Pn_vrouter_loopback['leaf1-vrouter 192.168.10.3'],
  ensure => present,
  bgp_as => 65002,
}

pn_vrouter_bgp { 'leaf2-vrouter 192.168.7.0':
  require => Pn_vrouter_loopback['leaf2-vrouter 192.168.10.4'],
  ensure => present,
  bgp_as => 65003,
}

pn_vrouter_bgp { 'leaf2-vrouter 192.168.7.1':
  require => Pn_vrouter_loopback['leaf2-vrouter 192.168.10.4'],
  ensure => present,
  bgp_as => 65003,
}

pn_vrouter_bgp { 'leaf3-vrouter 192.168.7.0':
  require => Pn_vrouter_loopback['leaf3-vrouter 192.168.10.5'],
  ensure => present,
  bgp_as => 65003,
}

pn_vrouter_bgp { 'leaf3-vrouter 192.168.7.1':
  require => Pn_vrouter_loopback['leaf3-vrouter 192.168.10.5'],
  ensure => present,
  bgp_as => 65003,
}

pn_vrouter_bgp { 'leaf4-vrouter 192.168.7.0':
  require => Pn_vrouter_loopback['leaf4-vrouter 192.168.10.6'],
  ensure => present,
  bgp_as => 65003,
}

pn_vrouter_bgp { 'leaf4-vrouter 192.168.7.1':
  require => Pn_vrouter_loopback['leaf4-vrouter 192.168.10.6'],
  ensure => present,
  bgp_as => 65003,
}