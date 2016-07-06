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

# Setup

# Should pass, create new trunk
pn_lag { 'charmander-trunk':
  ensure => present,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

# Should pass, already created
pn_lag { 'charmander-trunk':
  ensure => present,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

# shoud pass, delete trunk
pn_lag { 'charmander-trunk':
  ensure => absent,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

# shoud pass, already deleted
pn_lag { 'charmander-trunk':
  ensure => absent,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

# Should pass, create new trunks
pn_lag { 'charmander-trunk':
  ensure => present,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

pn_lag { 'squirtle-trunk':
  ensure => present,
  switch => 'squirtle.pluribusnetworks.com',
  ports => '11-14'
}

# Should pass, already created
pn_lag { 'charmander-trunk':
  ensure => present,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

pn_lag { 'squirtle-trunk':
  ensure => present,
  switch => 'squirtle.pluribusnetworks.com',
  ports => '11-14'
}

# change ports, should pass
pn_lag { 'charmander-trunk':
  ensure => present,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-15'
}

# shoud pass, delete trunk
pn_lag { 'charmander-trunk':
  ensure => absent,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

pn_lag { 'squirtle-trunk':
  ensure => absent,
  switch => 'squirtle.pluribusnetworks.com',
  ports => '11-14'
}

# shoud pass, already deleted
pn_lag { 'charmander-trunk':
  ensure => absent,
  switch => 'charmander.pluribusnetworks.com',
  ports => '11-14'
}

pn_lag { 'squirtle-trunk':
  ensure => absent,
  switch => 'squirtle.pluribusnetworks.com',
  ports => '11-14'
}

# Teardown

#END