`puppet apply test_manifests/pn_vlan-single-vlan-setup.pp`
`puppet apply test_manifests/pn_vlan-single-vlan-setup.pp`

output = `cli --quiet vlan-show id 101`

puts output