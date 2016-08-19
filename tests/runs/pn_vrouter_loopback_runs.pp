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

# SET-UP
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# should pass with flying colors
pn_vrouter_loopback { 'test-vrouter 168.98.5.2':
  ensure => present,
}

# do nothing, already created
pn_vrouter_loopback { 'test-vrouter 168.98.5.2':
  ensure => present,
}

# delete loopback
pn_vrouter_loopback { 'test-vrouter 168.98.5.2':
  ensure => absent,
}

# do nothing, already deleted
pn_vrouter_loopback { 'test-vrouter 168.98.5.2':
  ensure => absent,
}

# should fail, vrouter doesn't exist
pn_vrouter_loopback { 'test-vrouter-fake 168.98.5.2':
  ensure => present,
}

# should fail, too many arguments
pn_vrouter_loopback { 'test-vrouter 168.98.5.2 extra-arg':
  ensure => present,
}

# should fail, bad name
pn_vrouter_loopback {'test vrouter 168.98.5.2':
  ensure => present,
}

# should fail, bad ip
pn_vrouter_loopback {'test vrouter 168.98.a.b':
  ensure => present,
}

# TEAR-DOWN
pn_vrouter { 'test-vrouter':
  ensure     => absent,
  switch     => 'dorado-tme-1',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

# END