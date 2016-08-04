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

$switch1 = 'charmander' # spine 1
$switch2 = 'squirtle'   # spine 2
$switch3 = 'pikachu'    # leaf 1
$switch4 = 'gyarados'   # leaf 2
$switch5 = 'lapras'     # leaf 3
$switch6 = 'jigglypuff' # leaf 4

$vnet = 'no-fail-fab-global'

# HARD CODED PORTS, CHANGE THEM IF ON A DIFF SETUP!!!!!!!!!

# HAHA This won't pass... don't try
# PASS |pre-clean=True, post-clean=False| set up the two-switch demo

################################################################################
#                                                                              #
#                            C L U S T E R S                                   #
#                                                                              #
################################################################################

pn_cluster { 'spinecluster':
    ensure => present,
    nodes  => [$switch1, $switch2]
}

pn_cluster { 'leafcluster':
    ensure => present,
    nodes  => [$switch3, $switch4]
}

################################################################################
#                                                                              #
#                              T R U N K S                                     #
#                                                                              #
################################################################################

pn_lag { 'spine1-to-leaf':
  require => Pn_cluster['spinecluster', 'leafcluster'],
  ensure  => present,
  switch  => $switch1,
  ports   => '41,42,43,44'
}

pn_lag { 'spine2-to-leaf':
  require => Pn_cluster['spinecluster', 'leafcluster'],
  ensure  => present,
  switch  => $switch2,
  ports   => '41,42,43,44'
}

pn_lag { 'leaf1-to-spine':
  require => Pn_cluster['spinecluster', 'leafcluster'],
  ensure  => present,
  switch  => $switch3,
  ports   => '1,2,3,4',
}

pn_lag { 'leaf2-to-spine':
  require => Pn_cluster['spinecluster', 'leafcluster'],
  ensure  => present,
  switch  => $switch4,
  ports   => '1,2,3,4',
}

pn_lag { 'spine1-to-leaf3':
  require => Pn_cluster['spinecluster'],
  ensure  => present,
  switch  => $switch1,
  ports   => '45,46',
}

pn_lag { 'spine1-to-leaf4':
  require => Pn_cluster['spinecluster'],
  ensure  => present,
  switch  => $switch1,
  ports   => '47,48',
}

pn_lag { 'spine2-to-leaf3':
  require => Pn_cluster['spinecluster'],
  ensure  => present,
  switch  => $switch2,
  ports   => '45,46',
}

pn_lag { 'spine2-to-leaf4':
  require => Pn_cluster['spinecluster'],
  ensure  => present,
  switch  => $switch2,
  ports   => '47,48',
}

################################################################################
#                                                                              #
#                               V L A G S                                      #
#                                                                              #
################################################################################

pn_vlag { 'spine-to-leaf':
  require   => Pn_lag['spine1-to-leaf', 'spine2-to-leaf'],
  ensure    => present,
  cluster   => 'spinecluster',
  port      => 'spine1-to-leaf',
  peer_port => 'spine2-to-leaf',
  mode      => active,
}

pn_vlag { 'leafcluster-to-spinecluster':
  require   => Pn_lag['leaf1-to-spine', 'leaf2-to-spine'],
  ensure    => present,
  cluster   => 'leafcluster',
  port      => 'leaf1-to-spine',
  peer_port => 'leaf2-to-spine',
  mode      => active,
  switch    => 'pikachu',
}

pn_vlag { 'spine-to-leaf3':
  require   => Pn_lag['spine1-to-leaf3', 'spine2-to-leaf3'],
  ensure    => present,
  cluster   => 'spinecluster',
  port      => 'spine1-to-leaf3',
  peer_port => 'spine2-to-leaf3',
  mode      => 'active',
}

pn_vlag { 'spine-to-leaf4':
  require   => Pn_lag['spine1-to-leaf4', 'spine2-to-leaf4'],
  ensure    => present,
  cluster   => 'spinecluster',
  port      => 'spine1-to-leaf4',
  peer_port => 'spine2-to-leaf4',
  mode      => 'active',
}

################################################################################
#                                                                              #
#                                 V L A N S                                    #
#                                                                              #
################################################################################

Integer[101, 105].each | $i | {
  pn_vlan { "${i}":
    ensure         => present,
    scope          => fabric,
    description    => 'made-w-puppet',
    ports          => 'none',
    untagged_ports => 'none'
  }
}

################################################################################
#                                                                              #
#                             V R O U T E R S                                  #
#                                                                              #
################################################################################

pn_vrouter { 'spine1vrouter':
  ensure     => present,
  vnet       => $vnet,
  hw_vrrp_id => 18,
  service    => enable,
  switch     => $switch1,
}

pn_vrouter { 'spine2vrouter':
  ensure     => present,
  vnet       => $vnet,
  hw_vrrp_id => 18,
  service    => enable,
  switch     => $switch2,
}

################################################################################
#                                                                              #
#                    V R O U T E R   I N T E R F A C E S                       #
#                                                                              #
################################################################################

# Creates vrrp interfces for vlans 101 - 105

Integer[101, 105].each | $i | {

  pn_vrouter_if { "spine1vrouter ${i}.${i}.${i}.2/24":
    require       => Pn_vrouter['spine1vrouter'],
    vlan          => "${i}",
    ensure        => present,
    vrrp_ip       => "${i}.${i}.${i}.1/24",
    vrrp_priority => 110,
    switch        => $switch1,
  }

}

Integer[101, 105].each | $i | {

  pn_vrouter_if { "spine2vrouter ${i}.${i}.${i}.4/24":
    require       => Pn_vrouter['spine2vrouter'],
    vlan          => "${i}",
    ensure        => present,
    vrrp_ip       => "${i}.${i}.${i}.3/24",
    vrrp_priority => 100,
    switch        => $switch2,
  }

}

################################################################################
#                                                                              #
#                                   O S P F                                    #
#                                                                              #
################################################################################

pn_vrouter_ospf { 'spine1vrouter 172.26.1.0/24':
    ensure    => present,
    ospf_area => 0,
}

pn_vrouter_ospf { 'spine2vrouter 172.26.2.0/24':
    ensure    => present,
    ospf_area => 0,
}

################################################################################
#                                                                              #
#                              L O O P B A C K S                               #
#                                                                              #
################################################################################



################################################################################
#                                                                              #
#                                    B G P                                     #
#                                                                              #
################################################################################

