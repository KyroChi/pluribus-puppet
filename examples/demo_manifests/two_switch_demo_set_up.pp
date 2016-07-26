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

$switch1 = 'charmander'
$switch2 = 'squirtle'

# PASS |post-clean=False| set up the two-switch demo

pn_cluster { 'ab-cluster':
  ensure => present,
  nodes  => [$switch1, $switch2],
}

pn_lag { 'a-lag':
  require => Pn_cluster['ab-cluster'],
  ensure  => present,
  switch  => $switch1,
  ports   => '41-42',
}

pn_lag { 'b-lag':
  require => Pn_cluster['ab-cluster'],
  ensure  => present,
  switch  => $switch2,
  ports   => '41-42',
}

pn_vlag { 'ab-vlag':
  require   => Pn_lag['a-lag', 'b-lag'],
  ensure    => present,
  cluster   => 'ab-cluster',
  port      => 'b-lag',
  peer_port => 'a-lag',
  mode      => active,
}

pn_vrouter { 'a-vrouter':
  require    => Pn_vlag['ab-vlag'],
  ensure     => present,
  vnet       => 'puppet-ansible-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.1',
  switch     => $switch1,
}

pn_vrouter { 'b-vrouter':
  require    => Pn_vlag['ab-vlag'],
  ensure     => present,
  vnet       => 'puppet-ansible-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.2',
  switch     => $switch2,
}

pn_vlan { '105':
  require     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => present,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vlan { '106':
  require     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => present,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vlan { '200':
  require     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => present,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vlan { '201':
  require     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => present,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vrouter_if { '105 105.105.105.2/24':
  require => Pn_vlan['105'],
  ensure  => present,
  switch  => $switch1,
}

pn_vrouter_if { '106 106.106.106.2/24':
  require       => Pn_vlan['106'],
  ensure        => present,
  vrrp_ip       => '106.106.106.1/24',
  vrrp_priority => '110',
  switch        => $switch1,
}

pn_vrouter_if { '105 105.105.105.4/24':
  require => Pn_vlan['105'],
  ensure  => present,
  switch  => $switch2,
}

pn_vrouter_bgp { 'a-vrouter 200.200.200.1':
  require => Pn_vlan['200'],
  ensure  => present,
  bgp_as  => '65001'
}

pn_vrouter_bgp { 'b-vrouter 201.201.201.1':
  require => Pn_vlan['201'],
  ensure  => present,
  bgp_as  => '65001'
}