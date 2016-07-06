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

# should pass
pn_vlag { 'charmander-squirtle-vlag':
  ensure => present,
  cluster => 'tme-cluster',
  port => 55,
  peer_port => 55,
  mode => active,
}

# should pass, already created
pn_vlag { 'charmander-squirtle-vlag':
  ensure => present,
  cluster => 'tme-cluster',
  port => 55,
  peer_port => 55,
  mode => active,
}

# should delete
pn_vlag { 'charmander-squirtle-vlag':
  ensure => absent,
  cluster => 'tme-cluster',
  port => 55,
  peer_port => 55,
  mode => active,
}

# should pass, already deleted
pn_vlag { 'charmander-squirtle-vlag':
  ensure => absent,
  cluster => 'tme-cluster',
  port => 55,
  peer_port => 55,
  mode => active,
}

# END