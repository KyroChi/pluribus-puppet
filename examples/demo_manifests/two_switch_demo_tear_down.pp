# Copyright 2016 Pluribus Networks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless before d by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$SWITCH1 = 'charmander.pluribusnetworks.com'
$SWITCH2 = 'squirtle.pluribusnetworks.com'

# PASS |pre-clean=False, post-clean=False| tear down the two-switch demo

pn_cluster { 'ab-cluster':
  ensure => absent,
  nodes  => [$SWITCH1, $SWITCH2],
}

pn_lag { 'a-lag':
  before  => Pn_cluster['ab-cluster'],
  ensure  => absent,
  switch  => $SWITCH1,
  ports   => '11-14',
}

pn_lag { 'b-lag':
  before  => Pn_cluster['ab-cluster'],
  ensure  => absent,
  switch  => $SWITCH2,
  ports   => '11-14',
}

pn_vlag { 'ab-vlag':
  before    => Pn_lag['a-lag', 'b-lag'],
  ensure    => absent,
  cluster   => 'ab-cluster',
  port      => 'a-lag',
  peer_port => 'b-lag',
  mode      => active,
}

pn_vrouter { 'a-vrouter':
  before     => Pn_vlag['ab-vlag'],
  ensure     => absent,
  vnet       => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.1',
  switch     => $SWITCH1,
}

pn_vrouter { 'b-vrouter':
  before     => Pn_vlag['ab-vlag'],
  ensure     => absent,
  vnet       => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => 18,
  service    => 'enable',
  bgp_as     => 65001,
  router_id  => '192.168.50.2',
  switch     => $SWITCH2,
}

pn_vlan { '101-110, 198-202':
  before      => Pn_vrouter['a-vrouter', 'b-vrouter'],
  ensure      => absent,
  scope       => fabric,
  description => 'created-with-puppet',
}

pn_vrouter_if { '101-105 x.x.x.2/24':
  before  => Pn_vlan['101-110, 198-202'],
  ensure  => absent,
  switch  => $SWITCH1,
}

pn_vrouter_if { '106-110 x.x.x.2/24':
  before        => Pn_vlan['101-110, 198-202'],
  ensure        => absent,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => '110',
  switch        => $SWITCH1,
}

pn_vrouter_if { '101-105 x.x.x.4/24':
  before  => Pn_vlan['101-110, 198-202'],
  ensure  => absent,
  switch  => $SWITCH2,
}

pn_vrouter_if { '106-110 x.x.x.4/24':
  before        => Pn_vlan['101-110, 198-202'],
  ensure        => absent,
  vrrp_ip       => 'x.x.x.3/24',
  vrrp_priority => '110',
  switch        => $SWITCH2,
}

pn_vrouter_bgp { 'a-vrouter 200.200.200.1':
  before  => Pn_vlan['101-110, 198-202'],
  ensure  => absent,
  bgp_as  => '65001'
}

pn_vrouter_bgp { 'b-vrouter 201.201.201.1':
  before  => Pn_vlan['101-110, 198-202'],
  ensure  => absent,
  bgp_as  => '65001'
}