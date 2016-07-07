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

$a = 'charmander.pluribusnetworks.com'
$b = 'squirtle.pluribusnetworks.com'

pn_cluster { 'ab-cluster':
  ensure => present,
  nodes  => [$a, $b],
}

pn_lag { 'a-lag':
  require => Pn_cluster['ab-cluster'],
  ensure  => present,
  switch  => $a,
  ports   => '11-14',
}

pn_lag { 'b-lag':
  require => Pn_cluster['ab-cluster'],
  ensure  => present,
  switch  => $b,
  ports   => '11-14',
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
  vnet       => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.1',
  switch     => $a,
}

pn_vrouter { 'b-vrouter':
  require    => Pn_vlag['ab-vlag'],
  ensure     => present,
  vnet       => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.2',
  switch     => $b,
}

pn_vlan { '101-110, 198-202':
  require     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => present,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vrouter_if { '101-105 x.x.x.2/24':
  require => Pn_vlan['101-110, 198-202'],
  ensure  => present,
  vrouter => 'a-vrouter',
  switch  => $a,
}

pn_vrouter_if { '106-110 x.x.x.2/24':
  require       => Pn_vlan['101-110, 198-202'],
  ensure        => present,
  vrouter       => 'a-vrouter',
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => '110',
  switch        => $a,
}

pn_vrouter_if { '101-105 x.x.x.4/24':
  require => Pn_vlan['101-110, 198-202'],
  ensure  => present,
  vrouter => 'b-vrouter',
  switch  => $b,
}

pn_vrouter_if { '106-110 x.x.x.4/24':
  require       => Pn_vlan['101-110, 198-202'],
  ensure        => present,
  vrouter       => 'b-vrouter',
  vrrp_ip       => 'x.x.x.3/24',
  vrrp_priority => '110',
  switch        => $b,
}

pn_vrouter_bgp { 'a-vrouter 200.200.200.1':
  require => Pn_vlan['101-110, 198-202'],
  ensure  => present,
  bgp_as  => '65001'
}

pn_vrouter_bgp { 'b-vrouter 201.201.201.1':
  require => Pn_vlan['101-110, 198-202'],
  ensure  => present,
  bgp_as  => '65001'
}