#!/bin/bash

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
