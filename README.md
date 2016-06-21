# pn-puppet

### Releases

| Forge/Official | Development |
|:--------------:|:-----------:|
|![Forge](https://img.shields.io/badge/forge-na-red.svg)|![Dev](https://img.shields.io/badge/dev-na-red.svg)

### Table of Contents

1. [Introduction](#introduction)
1. [Module Description](#module-description)
1. [Setup](#setup)
1. [Usage](#usage)
1. [Resource Reference](#resource-reference)
    * [Type Catalog](#type-catalog)
1. [Limitations](#limitations)
1. [Additional Resources](#additional-resources)

## Introduction

The Pluribus Puppet module allows network administrators using Pluribus switches to easily configure and manage Pluribus and Netvisor specific resources. By implementing Puppet, the workflow for creating a new setup is streamlined, and tasks that previously may have taken days or weeks can be accomplished in a few hours. With Puppet, configurations can be re-used, or applied to many different setups. 

If you are familiar with the Puppet master-agent setup, you may be weary to setup Puppet on a full size deployment, but with Pluribus' fabric capabilities, only one switch in your network needs to host a Puppet agent. From that one switch you can control the entire configuration of any switch on your fabric, without having to keep track of node groups and individual switches. Pluribus Puppet also supports hosting agents on all or some of the switches in your network, and can be configured to meet your specific needs as a system administrator.

If you are a Pluribus employee needing to quickly configure large networks for testing or demos, Puppet offers a quick and repeatable way to create network configurations. The nature of Puppet allows us to completely build, tear-down, and re-build the same setup over and over without worrying about missing a step or debugging a script.
 
 If you are a developer looking to contribute, or a new development team member, please visit the [developer page]().

## Module Description

This module allows for the management of Pluribus switches through the Puppet DSL and Puppet manifest files by adding new Types and Providers to support Netvisor functionality.

## Setup

To use Pluribus Puppet you must first install and configure a Puppet master server and a Pupept agent on one, all, or some of the switches in your fabric. A guide for installing the [Puppet Master](https://docs.puppet.com/puppetserver/2.4/install_from_packages.html) and one for installing the [Puppet Agent](https://docs.puppet.com/puppet/latest/reference/install_linux.html).

After installing the master and agent and getting them configured install the Pluribus Puppet module from [Forge]().

## Usage

Puppet utilized manifest file declerations to manage resources. If you have used the Netvisor CLI before, puppet essentially automates the CLI commands and allows you to quickly manage resources.

For examples, creating vLANs on the cli is done with the following command: 
```
CLI (...) > vlan-create id 101 scope fabric ports none
```

With Puppet, this same vlan can be not created, but managed with the following deceleration:
```puppet
pn_vlan { '101':
    ensure => present,
    scope  => 'fabric
}
```

This may seem complicated and contain more typing than the traditional commands, especially taking into account compiling the Puppet catalog and pushing it to the agents, but the real power comes from the management capabilities and range namevars.

On the CLI, to delete the vLAN, you need to type the following:
```
CLI (...) > vlan-delete id 101
```

With Puppet, you change one line:
~~~diff
pn_vlan { '101':
-   ensure => present,
+   ensure => absent,
    scope  => 'fabric
}
~~~

The other powerful thing you can do with Puppet is using ranged namevars. If we want to create 5 vLANS from the CLI we must issue 5 separate commands like this:
```
CLI (...) > vlan-create id 101 scope fabric ports none
Vlan 101 created
CLI (...) > vlan-create id 102 scope fabric ports none
Vlan 102 created
CLI (...) > vlan-create id 103 scope fabric ports none
Vlan 103 created
CLI (...) > vlan-create id 104 scope fabric ports none
Vlan 104 created
CLI (...) > vlan-create id 105 scope fabric ports none
Vlan 105 created
```

With Puppet we can accomplish the same thing with the following manifest declaration:
```puppet
pn_vlan { '101-105':
    ensure => present,
    scope  => fabric,
}
```

And instead of deleting one by one, we can once again change only one line:
~~~diff
pn_vlan { '101-105':
-   ensure => present,
+   ensure => absent,
    scope  => 'fabric
}
~~~

Hopefully this example has convinced you that Puppet is a powerful tool and can be used to streamline CLI setups. Keep in mind too that once you have written a manifest you can apply it to any number of switch setups and obtain the same end setup every time.

## Resource Reference

The following is a reference guide for using the various types provided by pn-puppet. These types are provided by the `pn-puppet`.

### Type Catalog

1. [pn_cluster](#pn_cluster)
1. [pn_lag](#pn_lag)
1. [pn_vlag](#pn_vlag)
1. [pn_vlan](#pn_vlan)
1. [pn_vrouter](#pn_vrouter)
1. [pn_vrouter_bgp](#pn_vrouter_bgp)
1. [pn_vrouter_ip](#pn_vrouter_ip)
1. [pn_vrouter_vrrp](#pn_vrouter_vrrp)

---
### pn_cluster

Allows for the management of clustered node. This type can create and destroy and manage node clusters.

#### Properties

**`name`** sets the cluster name. This is the type's namevar and is required. This can be any string as long as it only contains `letters`, `numbers`, `_`, `.`, `:`, and `-`. 

**`ensure`** tells Puppet how to manage the cluster. Ensuring `present` will mean that the cluster will be created and on the switch after a completed catalog run. Setting this to `absent` will ensure that the cluster is not present on the system after the catalog run.

**`nodes`** specifies the two nodes which will be clustered together. This property takes an array of nodes that are present on the fabric. If the nodes are not present Puppet will throw an error and not complete the catalog run. If you pass more than two valid switches in the array only the first two will be used.

**_`force_clustering`_** forces a cluster between the specified nodes. It is not recommended you use this but an example use case would be if two switches were previously clustered incorrectly you could use force clustering to force the correct switches into the desired cluster. The default value for this property is `no`.

#### Example Implementation

This example implementation creates a simple cluster between two switches, creatively named `switch-01` and `switch-02`. Their cluster name, also creatively named, is `switch-cluster`.

The following shows both the traditional CLI implementation and below it the same command created in a Puppet manifest file.

CLI:
```
CLI (...) > cluster-create name switch-cluster cluster-node-1 switch-01 cluster-node-2 switch-02
```

Puppet:
```puppet
node your-pluribus-switch {

    pn_cluster { 'switch-cluster':
        ensure => present,
        nodes  => ['switch-01', 'switch-02']
    }

}
```

---
### pn_lag

Allows for the management of trunks or LAGs. 

#### Properties

**`name`** sets the trunk name. This is the type's namevar and is required. This can be any string as long as it only contains `letters`, `numbers`, `_`, `.`, `:`, and `-`. 

**`ensure`** tells Puppet how to manage the trunk. Ensuring `present` will mean that the trunk will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the trunk is not present on the system after the catalog run.

**`switch`** is the name of the switch where the link aggregation will occur. This should be a switch that is both on the same network as the Puppet agent and the same fabric. If Puppet cannot find the specified switch it will throw an error during the catalog run.

**`ports`** are the ports to be aggregated. This should be passed as a comma separated list, no whitespace, and port ranges are allowed.

#### Example Implementation

The following example shows how to create trunks between two clusters. The first cluster is called `spine-cluster` and contains the two nodes `spine-01` and `spine-02`. The second cluster is called `leaf-cluster` and contains the two nodes `leaf-01` and `leaf-02`. `spine-01` is connected to `leaf-01` on ports 11 and 12, and connected to `leaf-02` on 13 and 14. `spine-02` is connected to `leaf-01` on ports 15 and 16, and connected to `leaf-02` on 17 and 18. The leaf to spine ports are the same numbers for the leaves.

CLI:
```
CLI (...) > switch spine-01 trunk-create name spine01-to-leaf ports 11,12,13,14
Created trunk spine01-to-leaf, id <id>
CLI (...) > switch spine-02 trunk-create name spine02-to-leaf ports 15,16,17,18
Created trunk spine02-to-leaf, id <id>
CLI (...) > switch leaf-01 trunk-create name leaf01-to-spine ports 11,12,15,16
Created trunk leaf01-to-spine, id <id>
CLI (...) > switch leaf-02 trunk-create name leaf02-to-spine ports 13,14,17,18
Created trunk leaf02-to-spine, id <id>
```

Puppet:
```puppet
node your-pluribus-switch {

    pn_lag { 'spine01-to-leaf':
        ensure => present,
        switch => 'spine-01',
        ports  => '11-14',
    }
    
    pn_lag { 'spine02-to-leaf':
        ensure => present,
        switch => 'spine-02',
        ports  => '15-18',
    }
    
    pn_lag { 'leaf01-to-spine':
        ensure => present,
        switch => 'leaf-01',
        ports  => '11,12,15,16',
    }
    
    pn_lag { 'leaf02-to-spine':
        ensure => present,
        switch => 'leaf-02',
        ports  => '13,14,17,18',
    }

}
```

---
### pn_vlag

Allow management of vLAGs. You must have LAGs/trunks in place on the switches in a vLAG prior to declaring the vLAG.

#### Properties

**`name`** sets the vLAG name. This is the type's namevar and is required. This can be any string as long as it only contains `letters`, `numbers`, `_`, `.`, `:`, and `-`. 

**`ensure`** tells Puppet how to manage the vLAG. Ensuring `present` will mean that the vLAG will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the vLAG is not present on the system after the catalog run.

**`switch`** is the name of the first switch of the vLAG. switch and peer-switch are interchangeable, however their respective ports must match.

**`peer-switch`** is the second switch in the vLAG.

**`port`** is the vLAG port on `switch`. 

**`peer-port`** is the vLAG port on `peer-switch`.

**_`mode`_** the vLAG mode. Can either be set to `active` or `standby`, corresponding to `active-active` and `active-standby` vLAG modes respectively. This property defaults to `active`.

**_`failover`_** is how L2 failover will be handled by the vLAG. This can either be specified as `move` or `ignore`. The default value for this property is `move`.

**_`lacp_mode`_** controls the link aggregation control protocol mode. This can be either `active`, `passive` or `off`. The default value is `active`.

**_`lacp_timeout`_** sets the type of LACP timeout. This can be set to either `fast` or `slow`. The default setting is `fast`.

**_`lacp_fallback`_** sets the fallback type of the LACP connection. This can be set to either `bundle` or `individual`. By default, this value is set to `bundle`.

**_`lacp_fallback_timeout`_** sets the fallback timeout in seconds. This can be any integer between `30` and `60`. By default the fallback timeout is set to `50` seconds.

#### Example Implementation

The following example shows how to create trunks between two clusters. The first cluster is called `spine-cluster` and contains the two nodes `spine-01` and `spine-02`. The second cluster is called `leaf-cluster` and contains the two nodes `leaf-01` and `leaf-02`. `spine-01` is connected to `leaf-01` on ports 11 and 12, and connected to `leaf-02` on 13 and 14. `spine-02` is connected to `leaf-01` on ports 15 and 16, and connected to `leaf-02` on 17 and 18. The leaf to spine ports are the same numbers for the leaves.

CLI:
```
CLI (...) > cluster-create name spine-cluster ...
CLI (...) > trunk-create name spine01-to-leaf ...
Created trunk spine02-to-leaf, id <#>
CLI (...) > trunk-create name spine02-to-leaf ...
Created trunk spine02-to-leaf, id <#>
CLI (...) > switch spine-01 vlag-create name spine-to-leaf port spine01-to-leaf peer-switch spine02 peer-port leaf2-to-spine mode active-active failover-ignore-L2 lacp-mode slow lacp-fallback bundle lacp-fallback-timeout 45
```

Puppet:
```puppet
pn_cluster { 'spine-cluster':
            ...
}

pn_lag { 'spine01-to-leaf':
            ...
    require => Pn_cluster['spine-cluster']
}

pn_lag { 'spine02-to-leaf':
            ...
    require => Pn_cluster['spine-cluster']
}

pn_vlag { 'spine-to-leafs':
    ensure                => present,
    switch                => 'spine-01',
    peer_switch           => 'spine-02',
    port                  => 'spine01-to-leaf',
    peer-port             => 'spine02-to-leaf',
    mode                  => active,
    failover              => ignore,
    lacp_mode             => active,
    lacp_timeout          => slow,
    lacp_fallback         => bundle,
    lacp_fallback_timeout => 45,
    require               => Pn_lag['spine01-to-leaf', 
                                    'spine02-to-leaf'],
}
```

---
### pn_vlan

Manage vLANs.

#### Properties

**`id`** is the vLAN id, this can be any number between 2 and 4092. Comma separated or whitespace separated is allowed. Ranges are allowed.

**`ensure`** tells Puppet how to manage the vLAN. Ensuring `present` will mean that the vLAN will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the vLAN is not present on the system after the catalog run.

**`scope`** is the name of the vNET assigned to the vRouter.

**_`description`_** is the description of the vLAN. Can only contain `letters`, `numbers`, `_`, `.`, `:`, and `-`. The default value is `''`.

**_`stats`_** enables or disables vLAN statistics. This can either be `enable` or `disable`. The default value is `enable`.

**_`ports`_** is a comma seperated list of ports that the vLAN will use. There cannot be any whitespace seperating the ports, ranges are allowed. The default value is `'none'`

**_`untagged_ports`_** is a comma seperated list of untagged ports that the vLAN will use. There cannot be any whitespace seperating the ports, ranges are allowed. The default value is `'none'`

#### Example Implementation

CLI:
```
CLI (...) > vlan-create id 101 scope fabric description puppet-vlan ports none untagged-ports none
```

Puppet:
```puppet
pn_vlan { '101':
    ensure         => present,
    scope          => fabric,
    description    => 'puppet-vlan',
    ports          => 'none',
    untagged_ports => 'none',
}
```

---
### pn_vrouter

Manage vRouters.

#### Properties

**`name`** is the name of the vRouter to be managed. Name can be any string as long as it only contains `letters`, `numbers`, `_`, `.`, `:`, and `-`. 

**`ensure`** tells Puppet how to manage the vRouter. Ensuring `present` will mean that the vRouter will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the vRouter is not present on the system after the catalog run.

**`vnet`** is the name of the vNET assigned to the vRouter.

**`hw_vrrp_id`** is a hardware id for VRRP interfaces that may live on this vRouter.

**_`service`_** simply enables or diables the vRouter. This can be set to either `enable` or `disable`. By default this is set to `enable`.

**_`bgp_as`_** is the AS number for any BGP interfaces that you will create later. Can be any integer. By default this property is set to `''` and tells Puppet not to set up BGP on the vRouter. (This can always be changed in the manifest later.)

**_`switch`_** the switch where the vRouter will live, this can be the name of any switch on the fabric. By deafult this value is set to `local` and creates a vRouter on whatever node is specified in the manifest.

#### Example Implementation

CLI:
```
CLI (...) > vrouter-create name demo-vrouter vnet demo-vnet-global hw-vrrp-id 18 enable
```

Puppet:
```puppet
pn_vrouter { 'demo-vrouter':
    ensure     => present,
    vnet       => 'demo-vnet-global',
    hw_vrrp_id => 18,
    service    => enable,
}
```

---
### pn_vrouter_bgp

Manage vRouter BGP interfaces. To create a BGP interface you must first create a [`pn_vrouter_ip`](#pn_vrouter_ip) so that the BGP interface has an established ip interface to live on.

#### Properties

**`name`** is a combination of the vRouter name and the BGP neighbor IP address, separated by a space.

**`ensure`** tells Puppet how to manage the BGP interface. Ensuring `present` will mean that the BGP interface will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the BGP interface is not present on the system after the catalog run.

**`bgp_as`** is the AS ID for the BGP interface.

**_`switch`_** is the name of the switch where the vRouter BGP interface will be hosted. This can be any switch on the fabric. The default value is `local` which creates a BGP interface on the node where the resource was declared.

#### Example Implementation

CLI:
```
CLI (...) > vrouter-create name demo-vrouter vnet demo-vnet-global hw-vrrp-id 18 enable bgp-as 65001
CLI (...) > vlan-create id 101 scope fabric
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 101.101.101.2/24 vlan 101 if data
CLI (...) > vrouter-bgp-add vrouter-name demo-vrouter neighbor 101.101.101.1 remote_as 65001 bfd
```

Puppet:
```puppet
pn_vrouter { 'demo-vrouter':
    ensure => present,
    vnet => 'demo-vnet-global',
    hw-vrrp-id => 18,
    service => enable,
    bgp_as => '65001',
}

pn_vlan { '101':
    require => Pn_vrouter['demo-vrouter'],
    ensure => present,
    scope => 'fabric',
    description => 'bgp',
}

pn_vrouter_ip { '101':
    require => Pn_vlan['101'],
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.2',
    mask => '24',
}

pn_vrouter_bgp { 'demo-vrouter 101.101.101.1':
    require => Pn_vrouter_ip['101'],
    ensure => present,
    bgp_as => '65001',
}
```

---
### pn_vrouter_ip

Mangae basic vRouter interfaces. This only creates an IP interface, and to create a [`pn_vrouter_bgp`](#pn_vrouter_bgp) or [`pn_vrouter_vrrp`](#pn_vrouter_vrrp) interface you must first create a `pn_vrouter_ip` interface.

#### Properties

**`vlan`** is the id of the vLan that the vRouter interface will live on.

**`ensure`** tells Puppet how to manage the IP interface. Ensuring `present` will mean that the IP interface will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the IP interface is not present on the system after the catalog run.

**`vrouter`** is the name of the vRouter that will host and manage the IP interface.

**`ip`** is the IP address of the interface. This can be passed as a static IP address, however passing IP patterns is allowed. For example passing `x.x.x.1` will look at the value of `vlan` and replace the `x`s in the pattern with the value. While this is fairly useless for configuring a single interface, when you create multiple IP interfaces with one resource deceleration, either by Puppet array or the range operator, this pattern will propagate to every instance of the resource that was declared. Any IP section can be specified with an `x`, except for the final number, which must be declared.

**`mask`** is simply the ip mask. Pass as `'24'` not `'/24'`.

**_`if_type`_** is the interface type for the IP interface. This can be either `data`, `mgmt` or `span`. The default value for `if_type` is `data`.

**_`switch`_** is the name of the switch where the IP interface will be created. This can be any switch on the fabric. The default value is `local`, which creates an IP interface on the node where the resource was declared.

#### Example Implementation

CLI:
```
CLI (...) > vrouter-create name demo-vrouter vnet demo-vnet-global hw-vrrp-id 18 enable
CLI (...) > vlan-create id 101 scope fabric
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 101.101.101.2/24 vlan 101 if data
```

Puppet:
```puppet
pn_vrouter { 'demo-vrouter':
    ensure => present,
    vnet => 'demo-vnet-global',
    hw-vrrp-id => 18,
    service => enable,
    bgp_as => '65001',
}

pn_vlan { '101':
    require => Pn_vrouter['demo-vrouter'],
    ensure => present,
    scope => 'fabric',
    description => 'bgp',
}

pn_vrouter_ip { '101':
    require => Pn_vlan['101'],
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.2',
    mask => '24',
}
```

---
### pn_vrouter_loopback

Creates a vRouter loopback interface on the destination switch.

#### Properties

**`name`** is a combination of the vRouter name and the loopback IP address, separated by a space.

**`ensure`** tells Puppet how to manage the loopback interface. Ensuring `present` will mean that the loopback interface will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the loopback interface is not present on the system after the catalog run.

**_`switch`_** is the name of the switch where the IP interface will be created. This can be any switch on the fabric. The default value is `local`, which creates an IP interface on the node where the resource was declared.

#### Example Implementation

CLI:
```
CLI (...) > vrouter-loopback-interface-add vrouter-name spine1vrouter ip 172.16.1.1
```

Puppet:
```puppet
pn_vrouter_loopback { 'spine1vrouter 172.16.1.1': 
    ensure => present,
}
```

---
### pn_vrouter_vrrp

#### Properties

**`vlan`** is the name of the vLAN where the VRRP interface will live.

**`ensure`** tells Puppet how to manage the VRRP interface. Ensuring `present` will mean that the VRRP interface will be created and present on the switch after a completed catalog run. Setting this to `absent` will ensure that the VRRP interface is not present on the system after the catalog run.

**`vrouter`** is the name of the vRouter that will host and manage the VRRP interface.

**`ip`** is the IP address of the interface. This can be passed as a static IP address, however passing IP patterns is allowed. For example passing `x.x.x.1` will look at the value of `vlan` and replace the `x`s in the pattern with the value. While this is fairly useless for configuring a single interface, when you create multiple IP interfaces with one resource deceleration, either by Puppet array or the range operator, this pattern will propagate to every instance of the resource that was declared. Any IP section can be specified with an `x`, except for the final number, which must be declared.

**`mask`** is simply the ip mask. Pass as `'24'` not `'/24'`.

**_`if_type`_** is the interface type for the VRRP interface. This can be either `data`, `mgmt` or `span`. The default value for `if_type` is `data`.

**_`vrrp_id`_** is the VRRP ID for the interface. This property must be an interger. The default value is `none` and will not create a VRRP interface.

**_`primary_ip`_** is the primary IP of the interface. The default value is `none` and will not create a VRRP interface.

**_`vrrp_priority`_** is the priority for the VRRP interface. This must be a integer between `0` and `255`. The default value is `none` and will not create a VRRP interface.

**_`switch`_** is the name of the switch where the VRRP interface will be created. The switch must be on the same fabric as the node where the resource was declared. The default value is `local` and will create a VRRP interface on the node where the resource was declared.

#### Example Implementation

CLI:
```
CLI (...) > vrouter-create name demo-vrouter vnet demo-vnet-global hw-vrrp-id 18 enable
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 101.101.101.3/24 vlan 101 if data
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 101.101.101.1/24 vlan 101 if data vrrp-id 18 vrrp-primary eth0.101 vrrp-priority 110
```

Puppet:
```puppet
pn_vrouter { 'demo-vrouter':
    ensure => present,
    vnet => 'demo-vnet-global',
    hw-vrrp-id => 18,
    service => enable,
    bgp_as => '65001',
}

pn_vlan { '101':
    require => Pn_vrouter['demo-vrouter'],
    ensure => present,
    scope => 'fabric',
    description => 'bgp',
}

pn_vrouter_ip { '101':
    require => Pn_vlan['101'],
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.2',
    mask => '24',
}

pn_vrouter_vrrp { '101':
    require => Pn_vlan['101'],
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.2',
    mask => '24',
    vrrp_id => 18,
    primary_ip => 'x.x.x.1',
    vrrp_priority => '110',
}
```

---
## Limitations

Pluribus Puppet currently only runs on ONVL distributions of Netvisor.

## Additional Resources

To be added.