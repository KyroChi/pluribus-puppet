node default {
     pn_vrouter_ospf { 'vrouter-name 172.26.1.0':
           ensure => absent,
           netmask => '255.255.255.0',
           ospf_area => 0,
    }
}