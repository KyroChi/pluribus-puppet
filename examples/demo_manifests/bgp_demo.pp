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

$spine1 = 'charmander'
$spine2 = 'squirtle'
$leaf1 = 'pikachu'
$leaf2 = 'gyarados'
$leaf3 = 'lapras'
$leaf4 = 'jigglypuff'
$vnet = 'puppet-ansible-fab-global'

pn_vrouter { 'S74POCLF1-bgp':
  ensure           => present,
  vnet             => $vnet,
  switch           => $leaf1,
  bgp_as           => 65001,
  router_id        => '10.96.243.245',
  bgp_redistribute => connected,
  bgp_max_paths    => 16,
}

pn_vrouter_if { 'S74POCLF1-bgp 10.96.243.146/30':
  require => Pn_vrouter['S74POCLF1-bgp'],
  ensure  => present,
  l3_port => 1,
}

pn_vrouter_if { 'S74POCLF1-bgp 10.96.243.162/30':
  require => Pn_vrouter['S74POCLF1-bgp'],
  ensure  => present,
  l3_port => 3,
}

pn_vrouter_if { 'S74POCLF1-bgp 10.96.242.65/26':
  require => [Pn_vrouter['S74POCLF1-bgp'], Pn_vlan['100']],
  ensure  => present,
  vlan    => '100',
}

pn_vrouter_bgp { 'S74POCLF1-bgp 10.96.243.146/30':
  require => Pn_vrouter_if['S74POCLF1-bgp 10.96.243.146/30'],
  ensure  => present,
  bgp_as  => 65001,
}

pn_vrouter_bgp { 'S74POCLF1-bgp 10.96.243.162/30':
  require => Pn_vrouter_if['S74POCLF1-bgp 10.96.243.162/30'],
  ensure  => present,
  bgp_as  => 65001,
}

pn_vlan { '100':
  require        => Pn_vrouter_bgp['S74POCLF1-bgp 10.96.243.146/30',
                                   'S74POCLF1-bgp 10.96.243.162/30'],
  ensure         => present,
  scope          => local,
  untagged_ports => '1-44',
}

#################################################################################

pn_vrouter { 'S74POCLF2-bgp':
  ensure => present,
  vnet   => $vnet,
  switch => $leaf2,
}

pn_vrouter { 'S74POCLF3-bgp':
  ensure => present,
  vnet   => $vnet,
  switch => $leaf3,
}

pn_vrouter { 'S74POCLF4-bgp':
  ensure => present,
  vnet   => $vnet,
  switch => $leaf4,
}