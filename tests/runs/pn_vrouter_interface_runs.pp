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
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => $SWITCH1,
  vnet       => 'puppet-ansible-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vlan { '101':
  ensure => present,
  scope  => fabric,
}

# PASS |setup=False| Create a vRouter interface
pn_vrouter_if { '101 101.101.101.3/24':
  ensure  => present,
}

# PASS Create a VRRP interface
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => present,
  vrrp_ip       => '101.101.101.1/24',
  vrrp_priority => 110
}

# PASS |setup=False| Delete a VRRP interface
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => absent,
}

# FAIL |setup=False, idempotency=False| vRouter interface bad namevar
pn_vrouter_if { '101 101.101.101.2':
  ensure  => present,
}

# FAIL |setup=False, idempotency=False| vRouter interface bad vrrp ip
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => present,
  vrrp_ip       => '101.101.101.2/24',
  vrrp_priority => 110
}

# PASS Create a VRRP interface
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => present,
  vrrp_ip       => '101.101.101.1/24',
  vrrp_priority => 110
}

# PASS |matchers=if[101 101.101.101.2/24]/vrrp_ip: vrrp_ip changed, setup=False| Change VRRP ip
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => present,
  vrrp_ip       => '101.101.101.4/24',
  vrrp_priority => 110
}

# PASS |setup=False, matchers=if[101 101.101.101.2/24]/vrrp_ip: vrrp_ip changed '101.101.101.4/24' to '101.101.101.1/24'| Change x.x.x.2/24 to a VRRP interface
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => present,
  vrrp_ip       => '101.101.101.1/24',
  vrrp_priority => 110
}

# PASS |setup=False, matchers=if[101 101.101.101.2/24]/vrrp_priority: vrrp_priority changed| vrouter interface change priority
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => present,
  vrrp_ip       => '101.101.101.1/24',
  vrrp_priority => 118
}

# PASS |setup=False, matchers=if[101 101.101.101.2/24]/vrrp_ip: vrrp_ip changed| vrouter interface change vrrp ip
pn_vrouter_if { '101 101.101.101.2/24':
  ensure        => present,
  vrrp_ip       => '101.101.101.4/24',
  vrrp_priority => 118
}