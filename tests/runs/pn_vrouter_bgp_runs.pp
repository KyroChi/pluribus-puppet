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

# SET-UP

pn_vrouter { 'bgp-test-vrouter-1':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
  router_id  => '172.168.10.6',
}

pn_vrouter_loopback { 'bgp-test-vrouter-1 172.16.1.1':
  require => Pn_vrouter['bgp-test-vrouter-1'],
  ensure => present,
  switch => 'dorado-tme-1',
}

pn_vrouter { 'bgp-test-vrouter-2':
  ensure     => present,
  switch     => 'dorado-tme-2',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
  router_id  => '172.168.10.10',
}

pn_vrouter_loopback { 'bgp-test-vrouter-2 172.16.1.2':
  require => Pn_vrouter['bgp-test-vrouter-2'],
  ensure => present,
  switch => 'dorado-tme-2',
}

# create a BGP on switch 1
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6':
  ensure => present,
  bgp_as => 65000,
}

# do nothing already created
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6':
  ensure => present,
  bgp_as => 65000,
}

# create a BGP on switch 2
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => present,
  bgp_as => 65000,
}

# do nothing already created
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => present,
  bgp_as => 65000,
}

# remove bgp on switch1
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6':
  ensure => absent,
  bgp_as => 65000,
}

# do nothing already removed
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6':
  ensure => absent,
  bgp_as => 65000,
}

# remove BGP from switch 2
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => absent,
  bgp_as => 65000,
}

# do nothing already removed
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => absent,
  bgp_as => 65000,
}

# should fail, bad name
pn_vrouter_bgp { 'bgp test vrouter 1 172.168.10.10':
  ensure => present,
  bgp_as => 65000,
}

# should fail, bad ip
pn_vrouter_bgp { 'bgp-test-vrouter-1 256.1b8.c0.x0':
  ensure => present,
  bgp_as => 65000,
}

# should fail, bad BGP AS
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => present,
  bgp_as => 0,
}

# should fail, bad BGP AS
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => present,
  bgp_as => 4294967296,
}

# create a BGP range on switch 1
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6-10':
  ensure => present,
  bgp_as => 65000,
  increment => 4,
}

# do nothing, already there
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6-10':
  ensure => present,
  bgp_as => 65000,
  increment => 4,
}

# delete a BGP range on switch 1
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6-10':
  ensure => absent,
  bgp_as => 65000,
  increment => 4,
}

# do nothing, already gone
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6-10':
  ensure => absent,
  bgp_as => 65000,
  increment => 4,
}

# TEAR-DOWN

pn_vrouter { 'bgp-test-vrouter-1':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
}

pn_vrouter_loopback { 'bgp-test-vrouter-1 172.16.1.1':
  before => Pn_vrouter['bgp-test-vrouter-1'],
  ensure => absent,
  switch => 'dorado-tme-1',
}

pn_vrouter { 'bgp-test-vrouter-2':
  ensure     => absent,
  switch     => 'dorado-tme-2',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
}

pn_vrouter_loopback { 'bgp-test-vrouter-2 172.16.1.2':
  before => Pn_vrouter['bgp-test-vrouter-2'],
  ensure => absent,
  switch => 'dorado-tme-2',
}

#END