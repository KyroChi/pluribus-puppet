#!/bin/bash

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
# ├── test
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
mkdir "test/$1"
touch "test/$1/$1_test_manifest_01.pp"

cat > "lib/puppet/provider/$1/netvisor.rb" <<EOF
Puppet::Type.type(:$1).provide(:netvisor) do

end
EOF

cat > "lib/puppet/type/$1.rb" <<EOF
Puppet::Type.newtype(:$1)do

end
EOF

echo "created skeleton for $1"
