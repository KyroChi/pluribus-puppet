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
pn_vlan { '1000':
	ensure => absent,
	description => "puppet-1000",
	scope => 'local'
	ports => 'none'
}

pn_vlan { '999':
	ensure => absent,
	ports => 'none',
	scope => 'fabric',
	description => 'puppet-999'
}

pn_vlan { '2':
	ports => 'none',
	ensure => absent,
	scope => local,
	description => puppet-2
}
