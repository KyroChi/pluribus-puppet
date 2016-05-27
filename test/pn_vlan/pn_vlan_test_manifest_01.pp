# instantiate vlans 1000, 999, and 2
pn_vlan { '1000':
	ensure => present,
	description => "puppet-1000",
	scope => 'local'
	ports => 'none'
}

pn_vlan { '999':
	ensure => present,
	ports => 'none',
	scope => 'fabric',
	description => 'puppet-999'
}

pn_vlan { '2':
	ports => 'none',
	ensure => present,
	scope => local,
	description => puppet-2
}