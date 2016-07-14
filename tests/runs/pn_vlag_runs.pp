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
pn_cluster { 'vlag-test-cluster':
  ensure => present,
  nodes  => [$SWITCH1, $SWITCH2]
}

pn_lag { 'S1-lag':
  ensure => present,
  switch => $SWITCH1,
  ports  => '11,12'
}

pn_lag { 'S2-lag':
  ensure => present,
  switch => $SWITCH2,
  ports  => '13,14'
}

# PASS Bringing up a vLAG
pn_vlag { 'S1-VLAG':
  ensure => present,
  cluster => 'vlag-test-cluster',
  port => 'S1-lag',
  peer_port => 'S2-lag',
  mode => active,
}

# PASS Taking a vLAG down
pn_vlag { 'S1-VLAG':
  ensure => absent,
  cluster => 'vlag-test-cluster',
  port => 'S1-lag',
  peer_port => 'S2-lag',
  mode => active,
}

# FAIL |idempotency=False| vLAG: Bad name
pn_vlag { 'Bad name':
  ensure => absent,
  cluster => 'vlag-test-cluster',
  port => 'S1-lag',
  peer_port => 'S2-lag',
  mode => active,
}

# END