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

pn_vlan { '101-102':
  require => Pn_vrouter['bgp-vrouter-1', 'bgp-vrouter-2'],
  ensure => absent,
  scope => fabric,
  description => 'bgp',
}

pn_vrouter { 'bgp-vrouter-1':
  ensure => absent,
  switch => 'dorado-tme-1',
  vnet => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => '18',
  service => 'enable',
  bgp_as => '1',
}

pn_vrouter { 'bgp-vrouter-2':
  ensure => absent,
  switch => 'dorado-tme-2',
  vnet => 'puppet-ansible-chef-fab-global',
  hw_vrrp_id => '18',
  service => 'enable',
  bgp_as => '2',
}

pn_vrouter_ip { '101':
  before => Pn_vrouter['bgp-vrouter-1'],
  ensure => absent,
  switch => 'dorado-tme-1',
  vrouter => 'bgp-vrouter-1',
  ip => 'x.x.x.1',
  mask => '24',
}

pn_vrouter_ip { '102':
  before => Pn_vrouter['bgp-vrouter-2'],
  ensure => absent,
  switch => 'dorado-tme-2',
  vrouter => 'bgp-vrouter-2',
  ip => 'x.x.x.2',
  mask => '24',
}

pn_vrouter_bgp { 'bgp-vrouter-1 101.101.101.1':
  before => Pn_vrouter_ip['101'],
  ensure => absent,
  switch => 'dorado-tme-1',
  bgp_as => '1',
}

pn_vrouter_bgp { 'bgp-vrouter-2 102.102.102.2':
  before => Pn_vrouter_ip['102'],
  ensure => absent,
  switch => 'dorado-tme-2',
  bgp_as => '2',
}