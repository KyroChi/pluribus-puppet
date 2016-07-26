# Copyright 2016 Pluribus Networks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless requiredd by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$switch1 = 'charmander'
$switch2 = 'squirtle'

# PASS |post-clean=False| tear down the two-switch demo

pn_cluster { 'ab-cluster':
  ensure => absent,
  nodes  => [$switch1, $switch2],
}

pn_lag { 'a-lag':
  before => Pn_cluster['ab-cluster'],
  ensure  => absent,
  switch  => $switch1,
  ports   => '41-42',
}

pn_lag { 'b-lag':
  before => Pn_cluster['ab-cluster'],
  ensure  => absent,
  switch  => $switch2,
  ports   => '41-42',
}

pn_vlag { 'ab-vlag':
  before   => Pn_lag['a-lag', 'b-lag'],
  ensure    => absent,
  cluster   => 'ab-cluster',
  port      => 'b-lag',
  peer_port => 'a-lag',
  mode      => active,
}

pn_vrouter { 'a-vrouter':
  before    => Pn_vlag['ab-vlag'],
  ensure     => absent,
  vnet       => 'puppet-ansible-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.1',
  switch     => $switch1,
}

pn_vrouter { 'b-vrouter':
  before    => Pn_vlag['ab-vlag'],
  ensure     => absent,
  vnet       => 'puppet-ansible-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.2',
  switch     => $switch2,
}

pn_vlan { '105':
  before     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => absent,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vlan { '106':
  before     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => absent,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vlan { '200':
  before     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => absent,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vlan { '201':
  before     => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => absent,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vrouter_if { '105 105.105.105.2/24':
  before => Pn_vlan['105'],
  ensure  => absent,
  switch  => $switch1,
}

pn_vrouter_if { '106 106.106.106.2/24':
  before       => Pn_vlan['106'],
  ensure        => absent,
  vrrp_ip       => '106.106.106.1/24',
  vrrp_priority => '110',
  switch        => $switch1,
}

pn_vrouter_if { '105 105.105.105.4/24':
  before => Pn_vlan['105'],
  ensure  => absent,
  switch  => $switch2,
}

pn_vrouter_bgp { 'a-vrouter 200.200.200.1':
  before => Pn_vlan['200'],
  ensure  => absent,
  bgp_as  => '65001'
}

pn_vrouter_bgp { 'b-vrouter 201.201.201.1':
  before => Pn_vlan['201'],
  ensure  => absent,
  bgp_as  => '65001'
}