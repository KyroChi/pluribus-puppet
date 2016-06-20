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

node dorado03 {

  #
  # Clusters
  #
  pn_cluster { 'cluster-leaf':
    ensure => absent,
    nodes => ['dorado03', 'dorado04']
  }

  pn_cluster { 'cluster-spine':
    ensure => absent,
    nodes => ['draco07', 'draco08']
  }

  #
  # Trunks
  #
  pn_lag { 'dorado03-to-spine':
    ensure => absent,
    switch => 'dorado03',
    ports => '49,65',
    require => Pn_cluster['cluster-leaf']
  }

  pn_lag { 'dorado04-to-spine':
    ensure => absent,
    switch => 'dorado04',
    ports => '49,65',
    require => Pn_cluster['cluster-spine']
  }

  pn_lag { 'draco07-to-leaf':
    ensure => absent,
    switch => 'draco07',
    ports => '1,5',
    require => Pn_cluster['cluster-leaf']
  }

  pn_lag { 'draco08-to-leaf':
    ensure => absent,
    switch => 'draco08',
    ports => '1,5',
    require => Pn_cluster['cluster-leaf']
  }

  #
  # VLAGs
  #
  pn_vlag { 'leaf-to-spine':
    ensure => absent,
    switch => 'dorado03',
    peer_switch => 'dorado04',
    port => 'dorado03-to-spine',
    peer_port => 'dorado04-to-spine',
    mode => active,
    require => [Pn_lag['dorado03-to-spine'],Pn_lag['dorado04-to-spine']]
  }

  pn_vlag { 'spine-to-leaf':
    ensure => absent,
    switch => 'draco07',
    peer_switch => 'draco08',
    port => 'draco07-to-leaf',
    peer_port => 'draco08-to-leaf',
    mode => active,
    require => [Pn_lag['dorado03-to-spine'],Pn_lag['dorado04-to-spine']]
  }

  pn_vlag { 'leaf-to-host':
    ensure => absent,
    switch => 'dorado03',
    peer_switch => 'dorado04',
    port => '1',
    peer_port => '1',
    mode => active,
    require => Pn_cluster['cluster-leaf']
  }

  pn_vlag { 'spine-to-host':
    ensure => absent,
    switch => 'draco07',
    peer_switch => 'draco08',
    port => '11',
    peer_port => '11',
    mode => active,
    require => Pn_cluster['cluster-spine']
  }

  pn_vlan{ '101-109':
    ensure => absent,
    scope => fabric,
    description => 'vrouter-puppet-testing'
  }

  #
  # vRouters
  #
  pn_vrouter { 'sample-vrouter-dorado03':
    require => Pn_vlan['101-109'],
    ensure => absent,
    vnet => 'draco07-global',
    hw_vrrp_id => 18,
    service => enable,
    bgp_as => '1',
    switch => 'dorado03',
  }

  pn_vrouter{ 'sample-vrouter-dorado04':
    require => Pn_vlan['101-109'],
    ensure => absent,
    vnet => 'draco07-global',
    hw_vrrp_id => 18,
    service => enable,
    bgp_as => '1',
    switch => 'dorado04'
  }

  #
  # vRouter ip and VRRP
  #
  pn_vrouter_ip{ ['101', '102']:
    ensure => absent,
    vrouter => 'sample-vrouter-dorado03',
    ip => 'x.x.x.3',
    mask => '24',
    require => Pn_vrouter['sample-vrouter-dorado03']
  }

  pn_vrouter_vrrp{ ['101', '102']:
    ensure => absent,
    vrouter => 'sample-vrouter-dorado03',
    ip => 'x.x.x.1',
    mask => '24',
    vrrp_id => '18',
    primary_ip => 'x.x.x.3',
    vrrp_priority => '110',
    require => Pn_vrouter_ip['101', '102']
  }

  #
  # vRouter ip and VRRP
  #
  pn_vrouter_ip{ ['103', '104']:
    ensure => absent,
    vrouter => 'sample-vrouter-dorado03',
    ip => 'x.x.x.3',
    mask => '24',
    require => Pn_vrouter['sample-vrouter-dorado03']
  }

  pn_vrouter_vrrp{ ['103', '104']:
    ensure => absent,
    vrouter => 'sample-vrouter-dorado04',
    ip => 'x.x.x.1',
    mask => '24',
    vrrp_id => '18',
    primary_ip => 'x.x.x.3',
    vrrp_priority => '110',
    require => Pn_vrouter_ip['103', '104']
  }

  #
  # vRouter ip and BGP
  #
  pn_vrouter_ip{ '105':
    ensure => absent,
    vrouter => 'sample-vrouter-dorado03',
    ip => 'x.x.x.1',
    mask => '24',
    require => Pn_vrouter['sample-vrouter-dorado03']
  }

  pn_vrouter_bgp { '1':
    require => Pn_vrouter_ip['105'],
    ensure => absent,
    switch => 'dorado03',
    vrouter => 'sample-vrouter-dorado03',
    ip => '105.105.105.1',
    bgp_as => '1',
  }

  #
  # vRouter ip and BGP
  #
  pn_vrouter_ip{ '106':
    ensure => absent,
    vrouter => 'sample-vrouter-dorado04',
    ip => 'x.x.x.1',
    mask => '24',
    require => Pn_vrouter['sample-vrouter-dorado04']
  }

  pn_vrouter_bgp { '2':
    require => Pn_vrouter_ip['106'],
    ensure => absent,
    switch => 'dorado04',
    vrouter => 'sample-vrouter-dorado04',
    ip => '106.106.106.1',
    bgp_as => '1',
  }

}
