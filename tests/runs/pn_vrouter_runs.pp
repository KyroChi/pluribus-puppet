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

# START

# Should pass, creating a new vrouter
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should pass, already exists
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should pass, deleting vrouter
pn_vrouter { 'test-vrouter':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should pass, already deleted
pn_vrouter { 'test-vrouter':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# vRouters on multiple switches
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => present,
  switch     => 'dorado-tme-2',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# again, should do nothing
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => present,
  switch     => 'dorado-tme-2',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# delete vrouters on multiple switches
pn_vrouter { 'test-vrouter-1':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => absent,
  switch     => 'dorado-tme-2',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# delete vrouters on multiple switches again, nothing should happen
pn_vrouter { 'test-vrouter-1':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => absent,
  switch     => 'dorado-tme-2',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should fail, can't have two vrouters on the same switch
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# clean up last test
pn_vrouter { 'test-vrouter-1':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter { 'test-vrouter-2':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should fail, name is wrong
pn_vrouter { 'test vrouter 1':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should fail, switch doesn't exist
pn_vrouter { 'test-vrouter-fake':
  ensure     => present,
  switch     => 'dorado-tme-fake',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should fail, vnet doesn't exist
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global-fake',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should fail, hw_vrrp_id isn't a number
pn_vrouter { 'test-vrouter-1':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 'a',
}

# END