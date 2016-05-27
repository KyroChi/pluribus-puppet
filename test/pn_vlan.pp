pn_vlan { '1000':
	ensure => present,
	scope => 'local',
	description => "Created_with_Puppet",
	ports => '0-104,128-129'
}

pn_vlan { '999':
	ensure => present,
	scope => 'fabric',
	description => "No_ports",
	ports => 'none'
}