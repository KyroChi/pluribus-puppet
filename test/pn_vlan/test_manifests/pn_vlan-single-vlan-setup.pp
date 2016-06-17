node default {
  pn_vlan { '101':
    ensure => present,
    scope => 'fabric',
    description => 'puppet-test'
  }
}