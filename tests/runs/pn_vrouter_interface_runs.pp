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
pn_vrouter { 'test-vrouter':
  ensure     => present,
  switch     => 'charmander.pluribusnetworks.com',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vlan { '101':
  ensure => present,
  scope  => fabric,
}

# create an interface
pn_vrouter_if { '101 x.x.x.3/24':
  ensure  => present,
}

# should do nothing, already exists
pn_vrouter_if { '101 x.x.x.3/24':
  ensure  => present,
}

# should create a range
pn_vlan { '102-105':
  ensure => present,
  scope  => fabric,
}
pn_vrouter_if { '102-105 x.x.x.3/24':
  require => Pn_vlan['102-105'],
  ensure  => present,
}

# should do nothing
pn_vrouter_if { '102-105 x.x.x.3/24':
  ensure  => present,
}

# should delete range
pn_vlan { '102-105':
  ensure => absent,
  scope  => fabric,
}
pn_vrouter_if { '102-105 x.x.x.3/24':
  before  => Pn_vlan['102-105'],
  ensure  => absent,
}

# should do nothing, already deleted
pn_vrouter_if { '102-105 x.x.x.3/24':
  ensure  => absent,
}

# create a vrrp interface
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# should do nothing, already created
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# delete a vrrp interface
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => absent,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# should do nothing already deleted
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => absent,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# should fail, incorrect namevar, no netmask
pn_vrouter_if { '101 x.x.x.2':
  ensure  => present,
}

# should fail, vrrp_ip matches interface ip
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.2/24',
  vrrp_priority => 110
}

# should fail, vrouter doesn't exist
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# create a vrrp interface
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# change vrrp_id
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# create an interface
pn_vrouter_if { '101 x.x.x.2/24':
  ensure  => present,
}

# make it vrrp
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 110
}

# change priority
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.1/24',
  vrrp_priority => 118
}

# change vrrp ip
pn_vrouter_if { '101 x.x.x.2/24':
  ensure        => present,
  vrrp_ip       => 'x.x.x.4/24',
  vrrp_priority => 118
}

# should pass
pn_vrouter { 'test-vrouter':
  ensure     => absent,
  switch     => 'charmander.pluribusnetworks.com',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vrouter_if { '101 x.x.x.2/24':
  ensure  => present,
  require => Pn_vrouter['test-vrouter'],
}


# TEAR-DOWN
pn_vrouter { 'test-vrouter':
  ensure     => absent,
  switch     => 'charmander.pluribusnetworks.com',
  vnet       => 'puppet-ansible-chef-fab-global',
  service    => 'enable',
  hw_vrrp_id => 18,
}

pn_vlan { '101':
  ensure => absent,
  scope  => fabric,
}

#END