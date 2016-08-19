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

# SETUP

$vnet = 'no-fail-fab-global'

pn_vrouter { 'bgp-test-vrouter-1':
  ensure     => present,
  switch     => $switch1,
  vnet       => $vnet,
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
  router_id  => '172.168.10.6',
}

pn_vrouter_loopback { 'bgp-test-vrouter-1 172.16.1.1':
  require => Pn_vrouter['bgp-test-vrouter-1'],
  ensure => present,
  switch => $switch1,
}

pn_vrouter { 'bgp-test-vrouter-2':
  ensure     => present,
  switch     => $SWITCH2,
  vnet       => $vnet,
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
  router_id  => '172.168.10.10',
}

pn_vrouter_loopback { 'bgp-test-vrouter-2 172.16.1.2':
  require => Pn_vrouter['bgp-test-vrouter-2'],
  ensure => present,
  switch => $SWITCH2,
}

# PASS |pre-clean=False, post-clean=False| Create BGP interface on switch1
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6':
  ensure => present,
  bgp_as => 65000,
}

# PASS |pre-clean=False, post-clean=False| Create BGP interface on SWITCH2
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => present,
  bgp_as => 65000,
}

# PASS |pre-clean=False, post-clean=False| Remove BGP interface from switch1
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.6':
  ensure => absent,
  bgp_as => 65000,
}

# PASS |pre-clean=False, post-clean=False| Remove BGP interface from SWITCH2
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => absent,
  bgp_as => 65000,
}

# FAIL |idempotency=False, setup=False| BGP interface has bad name
pn_vrouter_bgp { 'bgp test vrouter 1 172.168.10.10':
  ensure => present,
  bgp_as => 65000,
}

# FAIL |idempotency=False, setup=False| BGP interface bad IP
pn_vrouter_bgp { 'bgp-test-vrouter-1 256.1b8.c0.x0':
  ensure => present,
  bgp_as => 65000,
}

# FAIL |idempotency=False, setup=False| BGP interface BGP_AS too small
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => present,
  bgp_as => 0,
}

# FAIL |idempotency=False, setup=False| BGP interface BGP_AS too large
pn_vrouter_bgp { 'bgp-test-vrouter-1 172.168.10.10':
  ensure => present,
  bgp_as => 4294967296,
}

# TEAR-x-DOWN

$vnet = 'puppet-ansible-fab-global'

pn_vrouter { 'bgp-test-vrouter-1':
  ensure     => absent,
  switch     => $switch1,
  vnet       => $vnet',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
}

pn_vrouter_loopback { 'bgp-test-vrouter-1 172.16.1.1':
  before => Pn_vrouter['bgp-test-vrouter-1'],
  ensure => absent,
  switch => $switch1,
}

pn_vrouter { 'bgp-test-vrouter-2':
  ensure     => absent,
  switch     => $switch2,
  vnet       => $vnet,
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
}

pn_vrouter_loopback { 'bgp-test-vrouter-2 172.16.1.2':
  before => Pn_vrouter['bgp-test-vrouter-2'],
  ensure => absent,
  switch => $switch2,
}

#END