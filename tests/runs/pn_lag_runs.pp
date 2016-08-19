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
pn_cluster { 'char-squirt-cluster':
    ensure => present,
    nodes  => [$SWITCH1, $SWITCH2]
}

# PASS create new trunk
pn_lag { 'charmander-trunk':
  ensure => present,
  switch => $SWITCH1,
  ports => '11-14'
}

# PASS delete trunk
pn_lag { 'charmander-trunk':
  ensure => absent,
  switch => $SWITCH1,
  ports => '11-14'
}

# PASS create new trunks
pn_lag { 'charmander-trunk':
  ensure => present,
  switch => $SWITCH1,
  ports => '11-14'
}

pn_lag { 'squirtle-trunk':
  ensure => present,
  switch => $SWITCH2,
  ports => '11-14'
}

# PASS delete trunks
pn_lag { 'charmander-trunk':
  ensure => absent,
  switch => $SWITCH1,
  ports => '11-14'
}

pn_lag { 'squirtle-trunk':
  ensure => absent,
  switch => $SWITCH2,
  ports => '11-14'
}