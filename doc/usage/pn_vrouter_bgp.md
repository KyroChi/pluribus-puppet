# pn_vrouter_bgp

Allows management of BGP interfaces.

| Option         | Valid Values                          | Default      |
|----------------|---------------------------------------|:------------:|
|ensure          |present or absent                      |**REQUIRED**  |
|vrouter         |vRouter that will use the BGP interface|**REQUIRED**  |
|ip              |The neighbor BGP ip address            |**REQUIRED**  |
|bgp_as          |The remote AS number                   |**REQUIRED**  |
|switch          |The switch where the vRouter is located|`'local'`     |

1. [Usage](#usage)
2. [Examples](#examples)
3. [Notes](#notes)

## Usage

BGP requires that both a [vRouter](doc/usage/pn_vrouter.md) and a [vRouter IP Interface](doc/usage/pn_vrouter_ip.md) have already been created before a BGP interface can be added. Make sure when creating your vRouter that you include the optional **bgp_as** paramter so that you BGP resource can use the AS number on the vRouter.

The namevar on BGP resources only exists so that the Puppet manifest files will compile. BGP interfaces are ensurable, however they are ensured by checking that a BGP instance exists on the vRouter you supply with the specified ip. Because of this the namevar can be anything as long as it is unique between instances of BGP interfaces.

```puppet
pn_vrouter { 'example-vrouter':
    ... ,
    bgp_as => <number>,
}

pn_vrouter_ip { '101':
    require => Pn_vrouter['example-vrouter'],
    ...
}

pn_vrouter_bgp { '':
    require => Pn_vrouter_ip['101']
    ensure => present,
    vrouter => 'example-vrouter',
    ip => <vrouter_ip ip>,
    bgp_as => <number>, # Same as number specified in pn_vrouter['example-vrouter']
    switch => <switch-name|local>,
}
```

## Examples

Set up a simple BGP connection between two switches.

```puppet
pn_vrouter { 'bgp-vrouter-1':
  ensure => present,
  switch => 'switch-1',
  vnet => 'bgp-vnet',
  hw_vrrp_id => '18',
  service => 'enable',
  bgp_as => '1',
}

pn_vrouter { 'bgp-vrouter-2':
  ensure => present,
  switch => 'switch-2',
  vnet => 'bgp-vnet',
  hw_vrrp_id => '18',
  service => 'enable',
  bgp_as => '2',
}

pn_vrouter_ip { '101':
  require => Pn_vrouter['bgp-vrouter-1'],
  ensure => present,
  switch => 'switch-1',
  vrouter => 'bgp-vrouter-1',
  ip => 'x.x.x.1',
  mask => '24',
}

pn_vrouter_ip { '102':
  require => Pn_vrouter['bgp-vrouter-2'],
  ensure => present,
  switch => 'switch-2',
  vrouter => 'bgp-vrouter-2',
  ip => 'x.x.x.2',
  mask => '24',
}

pn_vrouter_bgp { 'bgp-1':
  require => Pn_vrouter_ip['101'],
  ensure => present,
  switch => 'switch-1',
  vrouter => 'bgp-vrouter-1',
  ip => '101.101.101.1',
  bgp_as => '1',
}

pn_vrouter_bgp { 'bgp-2':
  require => Pn_vrouter_ip['102'],
  ensure => present,
  switch => 'switch-2',
  vrouter => 'bgp-vrouter-2',
  ip => '102.102.102.2',
  bgp_as => '2',
}
```

## Notes

* Declaring a BGP resource without declaring an interface or vRouter will result in errors being pushed to your master console.
* It is recommended that you use require statements so that Puppet does not try and create a BGP interface prior to creating a vRouter or vRouter interface.