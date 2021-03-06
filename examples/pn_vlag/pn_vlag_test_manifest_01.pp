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
pn_vlag { 'vlag-to-aqr0708':
	ensure => present,
	switch => 'draco12',
	peer_switch => 'ara04',
	port => 'trunk-to-aqr0708',
	peer_port => 'trunk-to-aqr0708',
	mode => active,
	failover => ignore,
	lacp_mode => active,
	lacp_timeout => slow,
	lacp_fallback => bundle,
	lacp_fallback_timeout => 50
}
