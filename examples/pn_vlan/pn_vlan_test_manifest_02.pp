# tear-down vlans 1000, 999, and 2
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