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

# PASS create a new clusters
pn_cluster { 'spine-cluster':
  ensure => present,
  nodes => [$SWITCH1, $SWITCH2]
}

# PASS |matchers=None| should change cluster name
pn_cluster { 'spine-cluster-2':
  ensure => present,
  nodes => [$SWITCH1, $SWITCH2]
}

# PASS should delete cluster
pn_cluster { 'spine-cluster-2':
  ensure => absent,
  nodes => [$SWITCH1, $SWITCH2]
}

# PASS create a cluster
pn_cluster { 'spine-cluster':
  ensure => present,
  nodes => [$SWITCH1, $SWITCH2]
}

# PASS delete cluster
pn_cluster { 'spine-cluster':
  ensure => absent,
  nodes => [$SWITCH1, $SWITCH2]
}

# FAIL |idempotency=False| cluster with bad name
pn_cluster { 'spine cluster':
  ensure => present,
  nodes => [$SWITCH1, $SWITCH2]
}

# FAIL |idempotency=False, matchers=None| cluster with fake switches
pn_cluster { 'spine-cluster':
  ensure => present,
  nodes => ['dorado-tme-fake', 'dorado-tme-also-fake']
}