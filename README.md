# pn-puppet-module

| Current Release | Latest Stable Build | Latest Development Build |
|:---------------:|:-------------------:|:------------------------:|
|![](https://img.shields.io/badge/forge-na-red.svg) | ![](https://img.shields.io/badge/stable-na-red.svg) | ![](https://img.shields.io/badge/dev-na-red.svg) |

Puppet is a network and data-center automation system to allow sys-admins to allocate their time more effiecently to spend less time setting things up and more time making sure everything is running smoothly. Puppet allows for automated set-ups as specified in files called `manifests` and can greatly speed up set up time.

In addition, it can allow the configurations of features to be repetably enforced, across multiple boxes or for repetable testing purposes.

This module provides puppet support on Pluribus switches. Implementations of this module allow for remote configuration of supported features on Pluribus switches.

##### Installation

##### Versioning

##### Supported Netvisor Features
| Feature        | Linux            | Solaris          | Planned Support                   |
|:---------------|:----------------:|:----------------:|:---------------------------------:|
|aaa-tacacs      |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|acl             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|admin-impi      |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|admin-service   |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|admin-sftp      |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|admin-syslog    |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|api-install     |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|bootenv         |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|client-server   |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|cluster         |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|connection      |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|control-stats   |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|control-traffic |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|dhcp            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|dhcp-host       |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|dhcp-pool       |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|dhcp-pxe        |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|disk-library    |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|dns             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|fabric          |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|hw-nat          |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|id-led          |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|igmp            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|ip-pool         |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|iso-library     |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|l2              |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|l3              |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|lacp            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|log-event       |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|mirror          |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|mld             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|mst             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|nat             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|netvisor        |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|nv              |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|openflow        |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|openstack       |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|openvswitch     |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|port            |:heavy_minus_sign:|:heavy_minus_sign:|:outbox_tray: 1.0.0                |
|ptp             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|role            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|sflow           |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|snmp            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|software        |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|storage         |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|stp             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|switch          |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|transaction     |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|trunk           |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|tunnel          |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|user            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|vflow           |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|vlag            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|vlan            |:white_check_mark:|:white_check_mark:|Supported v0.0.1.d                 |
|vlb             |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|vnet            |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|vport           |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|vrg             |:heavy_minus_sign:|:heavy_minus_sign:|:outbox_tray: 1.0.0                |
|vrouter-bgp     |:heavy_minus_sign:|:heavy_minus_sign:|:outbox_tray: 1.0.0                |
|vrouter-igmp    |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |
|vxlan           |:heavy_minus_sign:|:heavy_minus_sign:|:heavy_minus_sign:                 |

##### Developers

# Adding New Plugin Features
This document will serve as a guideline to future developers of this project to create new implementations of Pluribus CLI commands through Puppet. I was unable to find any good tutorials for implementing Puppet on a custom OS, so this will guide you through what I have discoverd works and create a guideline specific to the Pluribus implementation of Puppet.

### Resources / Additional Readings
Most if not all of the readings should be avalibale in the Pluribus Library
- 'Puppet Types and Providers' by Dan Bode and Nan Liu offers a quick crash course in Puppet types and providers, it is a short resource and can be completed in its entierty in less than 3 hours. I reccomend at the very least skimming this particular book so that you have an understanding of how Puppet classes interact with eachother so that users can create manifests with relative ease.
- 
# pn-puppet-module Development Introduction
It is reccomended that the markdown documents are read with an appropriate markdown reader.

This module is designed to give customors who are running some version of puppet on their network a way to interface and configure Pluribus Switches. This has the added benifit of allowing us to configure and run tests using Puppet internally.

These docs have been written with the intent that after reading them you will know just enough about Puppet and our implementation that you can write effective tools for customers or internal tests quickly and painlessly. There are not as many resources for Puppet module development on the internet as you may hope, and many of them are outdated or don't apply to Pluribus' own module needs. If you are a future maintainer of this codebase I reccomend reading the included "Resources/Additional Readings" so that you are better familiar with the core architecture of Puppet and the underlying development principals for creating Puppet modules.

## READMEs
This project has a lot of documentation and an attempt has been made to break everything up into readable and seperate pieces.
- For setting up a new test setup see: README_NEWSETUP.md
- For implemeting cli commands see: README_CLI_FEATURES.md
- For internal testing see: README_TESTING.md
- For customer support and customer docs see: README_SUPPORT.md
- For pushing code see: README_VCS.md
- For documentation guidlines and practices see: README_DOCUMENTATION.md
- For development guidelines see and programming styleguide see: README_DEV_GUIDELINES.md
