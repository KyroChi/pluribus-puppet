# instantiate vlans 1000, 999, and 2
pn_vlan { '1000':
		ensure => present,
		description => "puppet-1000",
		scope => 'local',
		ports => 'none',
		untagged_ports => 'none',
		stats => disable
}

pn_vlan { '999':
    ensure => present,
    ports => '1-10,122-128',
    scope => 'fabric',
    description => 'puppet-999',
    untagged_ports => 'all',
    stats => enable
}

pn_vlan { '2':
    ports => 'none',
    ensure => present,
    scope => local,
    description => puppet-2
}