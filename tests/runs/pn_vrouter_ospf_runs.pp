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

pn_vrouter { 'test-vrouter':
  ensure     => present,
  vnet       => 'puppet-ansible-fab-global',
  service    => enable,
  hw_vrrp_id => 22,
  router_id  => '173.168.87.9'
}
 
pn_vrouter_ospf { 'test-vrouter 172.168.10.9/24':
  ensure    => present,
  ospf_area => 0,
}
 
pn_vrouter_ospf { 'test-vrouter 168.54.10.18/0':
  ensure    => present,
  ospf_area => 0,
}
 
pn_vrouter_ospf { 'test-vrouter 174.168.10.0/24':
  ensure    => present,
  ospf_area => 2,
}
 
pn_vrouter_ospf { 'test-vrouter 183.49.5.0/24':
  ensure    => present,
  ospf_area => 0,
}