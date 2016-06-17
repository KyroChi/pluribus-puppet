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

# pn_vlan { ['2', '999', '1000']:
#   ensure => present,
#   scope => local,
#   description => 'made_with_puppet',
# }
#
# pn_vlan { '765-785':
#   ensure => present,
#   scope => local,
#   description => 'new-range-operations'
# }
#
# pn_vlan { '258-234, 428-458':
#   ensure => present,
#   scope => local,
#   description => 'multi-range',
#   require => Pn_vlan['765-785']
# }

pn_vlan { ['2', '999', '1000']:
  ensure => absent,
  scope => local,
  description => 'made_with_puppet',
}

pn_vlan { '765-785':
  ensure => absent,
  scope => local,
  description => 'new-range-operations'
}

pn_vlan { '258-234, 428-458':
  ensure => absent,
  scope => local,
  description => 'multi-range',
  require => Pn_vlan['765-785']
}


