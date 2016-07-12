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

define pn_auto_vlag(

  $node1,
  $node2,
  $node3,
  $node4,

) {

  pn_cluster { "${node1}-${node2}-cluster":
    ensure => present,
    nodes  => [$node1, $node2]
  }

  pn_cluster { "${node2}-${node3}-cluster":
    ensure => present,
    nodes  => [$node3, $node4]
  }

  pn_lag { "${node1}-trunk":
    ensure => present,
    switch => $node1,
    ports  => '11,12'
  }

  pn_lag { "${node2}-trunk":
    ensure => present,
    switch => $node2,
    ports  => '13,14'
  }

  pn_lag { "${node3}-trunk":
    ensure => present,
    switch => $node3,
    ports  => '11,12'
  }

  pn_lag { "${node4}-trunk":
    ensure => present,
    switch => $node4,
    ports  => '13,14'
  }

  pn_vlag { "${node1}-${node2}-vlag":
    ensure    => present,
    cluster   => '$node1-$node2-cluster',
    port      => '$node1-trunk',
    peer_port => '$node2-trunk',
  }

  pn_vlag { "${node2}-${node3}-vlag":
    ensure    => present,
    cluster   => '$node3-$node4-cluster',
    port      => '$node3-trunk',
    peer_port => '$node4-trunk',
  }

}