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

Create vlan 101
PASS
pn_vlan { '101':
  ensure      => present,
  scope       => fabric,
  description => 'desc',
  ports       => 'none',
}

# Should do nothing
# PASS
pn_vlan { '101':
  ensure      => present,
  scope       => fabric,
  description => 'desc',
  ports       => 'none',
}

# delete vlan 101
# PASS
pn_vlan { '101':
  ensure      => absent,
  scope       => fabric,
  description => 'desc',
  ports       => 'none',
}

# Should do nothing
# PASS
pn_vlan { '101':
  ensure      => absent,
  scope       => fabric,
  description => 'desc',
  ports       => 'none',
}

# Should create a range of vlans
# PASS
pn_vlan { '101-110':
  ensure      => present,
  scope       => fabric,
  description => 'desc',
}

# Should do nothing
# PASS
pn_vlan { '101-110':
  ensure      => present,
  scope       => fabric,
  description => 'desc',
}

# Should delete a range of vlans
# PASS
pn_vlan { '101-110':
  ensure      => absent,
  scope       => fabric,
  description => 'desc',
}

# Should do nothing
# PASS
pn_vlan { '101-110':
  ensure      => absent,
  scope       => fabric,
  description => 'desc',
}

# Shouldn't compile
# FAIL
pn_vlan { 'a, 65-98777 18-b4':
  ensure => absent,
}

# should compile
# PASS
pn_vlan { '101':
  ensure => present,
  scope  => 'Local'
}

# should compile
# PASS
pn_vlan { '101':
  ensure => present,
  scope  => 'Fabric'
}

# shouldn't compile
# FAIL
pn_vlan { '101':
  ensure => present,
  scope  => 'lokal'
}

# shouldn't compile
# FAIL
pn_vlan { '101':
  ensure => present,
  scope  => 'fabrik'
}

# Overlapping Tests
# PASS
pn_vlan { '101-103':
  ensure => present,
  scope  => fabric,
}

# PASS
pn_vlan { '101-110':
  ensure => present,
  scope  => fabric,
}

# PASS
pn_vlan { '108-115':
  ensure => present,
  scope  => fabric,
}

# Overlapping Tests Over
# PASS
pn_vlan { '101-103':
  ensure => absent,
  scope  => fabric,
}

# PASS
pn_vlan { '101-110':
  ensure => absent,
  scope  => fabric,
}

# PASS
pn_vlan { '108-115':
  ensure => absent,
  scope  => fabric,
}

# TEAR-DOWN

# Test a vlan gets deleted if its part of an interface
# SETUP
pn_vlan { '103':
  ensure => present,
  scope => fabric,
}

pn_vrouter { 'test-vrouter':
  require => Pn_vlan['103'],
  ensure => present,
  vnet => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => 18,
}

pn_vrouter_ip { '103':
  require => Pn_vrouter['test-vrouter'],
  ensure => present,
  vrouter => 'test-vrouter',
  ip => 'x.x.x.1',
  mask => '24',
}

# Make sure it is deleted
pn_vlan { '103':
  ensure => absent,
}

# TEAR-DOWN
pn_vlan { '103':
  ensure => absent,
  scope => fabric,
}

pn_vrouter { 'test-vrouter':
  before => Pn_vlan['103'],
  ensure => absent,
  vnet => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => 18,
}

pn_vrouter_ip { '103':
  before => Pn_vrouter['test-vrouter'],
  ensure => absent,
  vrouter => 'test-vrouter',
  ip => 'x.x.x.1',
  mask => '24',
}

# END