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

# should pass
pn_cluster { 'spine-cluster':
  ensure => present,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# should also pass
pn_cluster { 'spine-cluster':
  ensure => absent,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# should pass
pn_cluster { 'spine-cluster-2':
  ensure => present,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# should change name
pn_cluster { 'spine-cluster-2':
  ensure => absent,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# should pass
pn_cluster { 'spine-cluster':
  ensure => present,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# should do nothing, already declared
pn_cluster { 'spine-cluster':
  ensure => present,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# should also pass
pn_cluster { 'spine-cluster':
  ensure => absent,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# should do nothing, already deleted
pn_cluster { 'spine-cluster':
  ensure => absent,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# shouldn't pass
pn_cluster { 'spine cluster':
  ensure => present,
  nodes => ['dorado-tme-1', 'dorado-tme-2']
}

# shouldn't pass
pn_cluster { 'spine-cluster':
  ensure => present,
  nodes => ['dorado-tme-fake', 'dorado-tme-also-fake']
}

# END