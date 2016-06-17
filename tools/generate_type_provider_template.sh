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

# Generates a markdown documentation page, a new provider
#  a new type and a directory in the test folder.


# Usage: run ./tools/generate_type_provider_template.sh new_feature_name

# ├── doc
# │   ├─+ new_feauture.md
# │   └── ...
# ├── lib
# │   └── puppet
# │       ├── provider
# │       │   ├─+ new_feature
# │       │   │   └─+ netvisor.rb
# │       │   └── ...
# │       └── type
# │           ├─+ new_feature.rb
# │           └── ...
# ├── examples
# │   ├─+ new_feature
# │   │   └─+ new_feature_test_manifest_01.pp
# │   └── ...
# └── ...

if [ $# -eq 0 ]
  then
    exit 5
fi

cd /etc/puppetlabs/code/environments/production/modules/pn-puppet-module
touch "doc/$1.md"
mkdir "lib/puppet/provider/$1/"
touch "lib/puppet/provider/$1/netvisor.rb"
touch "lib/puppet/type/$1.rb"
mkdir "examples/$1"
touch "examples/$1/$1_test_manifest_01.pp"

cat > "lib/puppet/provider/$1/netvisor.rb" <<EOF
Puppet::Type.type(:$1).provide(:netvisor) do

end
EOF

cat > "lib/puppet/type/$1.rb" <<EOF
Puppet::Type.newtype(:$1) do

end
EOF

echo "created skeleton for $1"

