default {

	pn_vlan { '1000':
		ensure => present,
		scope => 'local',
		}		    	

	}