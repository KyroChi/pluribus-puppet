pn_vlag { 'vlag-to-aqr0708':
	ensure => present,
	switch => 'draco12',
	peer_switch => 'ara04',
	port => 'trunk-to-aqr0708',
	peer_port => 'trunk-to-aqr0708',
	mode => active,
	failover => ignore,
	lacp_mode => active,
	lacp_timeout => slow,
	lacp_fallback => bundle,
	lacp_fallback_timeout => 50
}