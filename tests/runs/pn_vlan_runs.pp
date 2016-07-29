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

# PASS create vlan 101
pn_vlan { '101':
  ensure      => present,
  scope       => fabric,
  description => 'desc',
  ports       => 'none',
}

# PASS delete vlan 101
pn_vlan { '101':
  ensure      => absent,
  scope       => fabric,
  description => 'desc',
  ports       => 'none',
}

# FAIL |idempotency=False| Shouldn't compile
pn_vlan { 'a, 65-98777 18-b4':
  ensure => absent,
}

# PASS |idempotency=False| should compile
pn_vlan { '101':
  ensure => present,
  scope  => 'local'
}

# FAIL |idempotency=False| shouldn't compile
pn_vlan { '101':
  ensure => present,
  scope  => 'lokal'
}

# FAIL |idempotency=False| shouldn't compile
pn_vlan { '101':
  ensure => present,
  scope  => 'fabrik'
}

# PASS |pre-clean=True, post-clean=False, idempotency=False| Test a vlan gets deleted if its part of an interface
pn_vlan { '103':
  ensure => present,
  scope => fabric,
}

pn_vrouter { 'test-vrouter':
  require => Pn_vlan['103'],
  ensure => present,
  vnet => 'puppet-ansible-fab-global',
  hw_vrrp_id => 18,
}

pn_vrouter_if { '103 103.103.103.2/24':
  require => Pn_vrouter['test-vrouter'],
  ensure => present,
  vlan   => '103',
}

# PASS |pre-clean=False| Make sure it is deleted
pn_vlan { '103':
  ensure => absent,
}