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

# PASS |post-clean=False| Create a new vrouter.
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# PASS Delete a vrouter.
pn_vrouter { 'test-vrouter':
  ensure     => absent,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# PASS Create vRouters on multiple switches.
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => present,
  switch     => $switch2,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# PASS Delete vrouters on multiple switches.
pn_vrouter { 'test-vrouter-1':
  ensure     => absent,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => absent,
  switch     => $switch2,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# FAIL |idempotency=False| Can't have two vrouters on the same switch.
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => $switch1',
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => present,
  switch     => $switch2,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# FAIL |idempotency=False| vRouter name is wrong.
pn_vrouter { 'test vrouter 1':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# FAIL |idempotency=False| vRouter; switch doesn't exist.
pn_vrouter { 'test-vrouter-fake':
  ensure     => present,
  switch     => 'dorado-tme-fake',
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# FAIL |idempotency=False| vRouter; vnet doesn't exist. 
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global-fake',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# FAIL |idempotency=False| vRouter; vrrp id is not a number.
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 'a',
}

# PASS Create another, more complex vRouter.
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
  router_id  => '198.175.5.10',
}
 
# PASS |post-clean=False, matchers=Pn_vrouter[test-vrouter]/router_id: router_id changed| Change the router-id.
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
  router_id  => '198.175.5.6',
}

# PASS |pre-clean=False| Overwrite the old vRouter.
pn_vrouter { 'test-vrouter-overwrite':
  ensure     => present,
  switch     => $switch1,
  vnet       => 'no-fail-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
  bgp_as     => 65000,
  router_id  => '198.175.5.6',
}