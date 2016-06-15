# pn-puppet-module

| Current Release | Latest Stable Build | Latest Development Build |
|:---------------:|:-------------------:|:------------------------:|
|![Link to Forge](https://img.shields.io/badge/forge-na-red.svg) | ![Link to stable build](https://img.shields.io/badge/stable-na-red.svg) | ![Link to development build](https://img.shields.io/badge/dev-na-red.svg) |

### Table of Contents

1. [Module Description](#module-description)
2. [Setting up Pluribus Puppet](#setup)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Limitations](#limitations)
6. [Developers](#development)

## Module Description

The Pluribus Puppet adds Puppet functionality to Pluribus ONVL switchs. This module automates the setup and management of Netvisor resources.

## Setup


## Usage

Detailed usage guides are available for the following features. These guides provide full

1. [Cluster Management](doc/usage/pn_cluster.md#usage)
2. [Trunk/LAG Management](doc/usage/pn_lag.md#usage)
3. [vLAG Management](doc/usage/pn_vlag.md#usage)
4. [vLAN Management](doc/usage/pn_vlan.md#usage)
5. [vRouter Management](doc/usage/pn_vrouter.md#usage)
6. [vRouter BGP Interface Management](doc/usage/pn_vrouter_bgp.md#usage)
7. [vRouter IP Interface Management](doc/usage/pn_vrouter_ip.md#usage)
8. [vRouter VRRP Interface Management](doc/usage/pn_vrouter_vrrp.md#usage)

Sample deployment guides can be found here. These are much more detailed than the feature specific guides and explain in depth how the features can be used to set up real-world deployments in minutes. These guides will walk you through the sample deployment, what traditional steps would be taken, and how Puppet can save you time and energy.

1. [Setting up Clusters, Trunks, vLAGs, vLANs, vRouters and vRouter interfaces]()
2. [Mastering VRRP in manifests]()
4. [Setting up BGP]()
5. [Blank box to vRouter Configurations]()
6. [Everything Implemented on a Four Node Fabric]()
7. [Multiple Similar Deployments]()

## Reference

The following is a quick reference guide for all of the avaliable features in the Pluribus Puppet module. For more extensive documentation click the name of the resource or see the [Usage](#usage) section.

**Bold** are required parameters, *Italics* are optional.

1. [pn_cluster](#pn_cluster)
2. [pn_lag](#pn_lag)
3. [pn_vlag](#pn_vlag)
4. [pn_vlan](#pn_vlan)
5. [pn_vrouter](#pn_vrouter)
6. [pn_vrouter_bgp](#pn_vrouter_bgp)
7. [pn_vrouter_ip](#pn_vrouter_ip)
8. [pn_vrouter_vrrp](#pn_vrouter_vrrp)

### Resources

#### [pn_cluster](doc/usage/pn_cluster.md)
* **name**: The name of the cluster to be managed.
* **nodes**: The nodes in the managed cluster.
* *force-clustering*: Use with caution, see [usage guide]() for more. Default 'no'.

#### [pn_lag](doc/usage/pn_lag.md)
* **name**: The name of the link aggregation under management.
* **ports**: The ports in the link aggregation.
* *switch*: The name of the switch where this resource should be created. Default 'local'.

#### [pn_vlag](doc/usage/pn_vlag.md)
* **name**: The name of the vLAG to be managed.
* **switch**: The first switch in the vLAG.
* **peer_switch**: The second switch in the vLAG.
* **port**: The vLAG port on the switch.
* **peer_port**: The vLAG port on the peer switch.
* *mode*: The vLAG mode. Default 'active'. (for active-active)
* *failover*: vLAG L2 Failover mode. Default 'move'.
* *lacp_mode*: vLAG LACP mode. Default 'active'.
* *lacp_timeout*: Set the LACP timeout. Default 'fast'.
* *lacp_fallback*: Seth the LACP fallback type. Default 'bundle'.
* *lacp_fallback_timeout*: The LACP fallback timeout in seconds. Default '50'.

#### [pn_vlan](doc/usage/pn_vlan.md)
* **id**: The vLAN id of the vLAN to be managed.
* **scope**: The vLAN scope.
* *description*: The description of the vLAN. Default ''.
* *stats*: Enable or disable stats. Default 'enable'.
* *ports*: The ports for the vLAN. Default 'none'.
* *untagged_ports*: The untagged ports on the vLAN. Default 'none'.

#### [pn_vrouter](doc/usage/pn_vrouter.md)
* **name**: The managed vRouter's name.
* **vnet**: The vNet for the vRouter to live on.
* **hw_vrrp_id**: The hardware VRRP ID for the vRouter.
* *service*: Enable or disable the vRouter. Default 'enable'.
* *bgp_as*: BGP AS number. Default ''. (No BGP by default)
* *switch*: The name of the switch where this resource should be created. Default 'local'.

#### [pn_vrouter_bgp](doc/usage/pn_vrouter_bgp.md)
* **name**: This value is actually a throw-away value so that the manifest files will compile. This can be anything, and will not affect the execution of the manifest in any way. Make sure that these are unique for any BGP interface you create.
* **vrouter**: The name of the vRouter where the BGP interface will be created.
* **ip**: The ip of the BGP neighbor.
* **bgp_as**: The BGP AS number of the vRouter.
* *switch*: The name of the switch where this resource should be created. Default 'local'.

#### [pn_vrouter_ip](doc/usage/pn_vrouter_ip.md)
* **vlan**: The VLAN where the ip interface will be created. 
* **vrouter**: The name of the vRouter that will host the ip interface.
* **ip**: The ip interface's ip.
* **mask**: The netmask for the ip.
* *if_type*: The interface type being managed. Default 'data'.
* *switch*: The name of the switch where this resource should be created. Default 'local'.


#### [pn_vrouter_vrrp](doc/usage/pn_vrouter_vrrp.md)
* **vlan**: The VLAN where the ip interface will be created. 
* **vrouter**: The name of the vRouter that will host the ip interface.
* **ip**: The ip interface's ip.
* **mask**: The netmask for the ip.
* *if_type*: The interface type being managed. Default 'data'.
* *vrrp_id*: The vrrp_id for the interface.
* *primary_ip*: The primary ip for the interface.
* *vrrp_priority*: The priority for the VRRP interface.
* *switch*: The name of the switch where this resource should be created. Default 'local'.

## Limitations

There are no known limitations to this module in its current state.

## Development

Developers must follow the [developer's guide]()