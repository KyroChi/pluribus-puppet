# pn_vlag

Manages VLAGs

| Option              | Valid Values                                                  | Default      |
|---------------------|---------------------------------------------------------------|:------------:|
|ensure               |present or absent                                              |**REQUIRED**  |
|switch               |local or fabric                                                |**REQUIRED**  |
|peer_switch          |string, must be letters, numbers, \_, ., :, or -               |**REQUIRED**  |
|port                 |name of the port on the switch that the VLAG will live on      |**REQUIRED**  |
|peer_port            |name of the port on the peer-switch that the VLAG will live on |**REQUIRED**  |
|mode                 |active-active or active-standby mode. `< active | standby >`   | `active`     |
|failover             |L2 failover `< move | ignore>`                                 | `move`       |
|lacp_mode            |`< off | passive | active >`                                   | `off`        |
|lacp_timeout         |how fast does lacp timeout `< fast | slow >`                   | `fast`       |
|lacp_fallback        |what type of fallback for lacp `< bundle | individual >`       | `bundle`     |
|lacp_fallback_timeout|fallback timeout (in seconds) `< 30..60 >`                     | `'50'`       |

1. [Usage](#usage)
2. [Examples](#examples)
3. [Notes](#notes)

## Usage

VLAG can only be configured __*AFTER*__ a cluster has been configured, keep this in mind when creating VLAGs so that you specify clusters prior to VLAG creation.

```puppet
pn_vlag { '<name>':
    ensure => present,
    switch => <switch-name>,
    peer_switch => <peer-switch-name>,
    port => <vlag-port>,
    peer_port => <peer-port>,
    mode => <active|standby>,
    failover => <move|ignore>,
    lacp_mode => <off|passive|active>,
    lacp_timeout => <fast|slow>,
    lacp_fallback => <bundle|individual>,
    lacp_fallback_timeout => <30..60>
}
```

## Examples

This example sets up a cluster between two spines and configures 2 vLAGs between them. This example assumes a 2 spine, 4 leaf setup, where the leafs are grouped into 2 clusters. This manifest creates the two vLAGs between the spine cluster and each of the leaf clusters.

```puppet
node puppet-agent.pluribusnetworks.com {

    pn_cluster { 'spine1-spine2':
        ensure => present,
        nodes => ['onvlspine1', 'onvlspine2']
    }
    
    pn_vlag { 'spine-to-leaf3':
        ensure => present,
        switch => onlvspine1,
        peer_switch => onvlspine2,
        port => spine1-to-leaf3,
        peer_port => spine2-to-leaf3,
        mode => active,
        failover => move,
        lacp_mode => passive,
        lacp_timeout => fast,
        lacp_fallback => bundle,
        lacp_fallback_timeout => 40
    }
    
    pn_vlag { 'spine-to-leaf4':
        ensure => present,
        switch => onlvspine1,
        peer_switch => onvlspine2,
        port => spine1-to-leaf4,
        peer_port => spine2-to-leaf4,
        mode => active,
        failover => move,
        lacp_mode => passive,
        lacp_timeout => fast,
        lacp_fallback => bundle,
        lacp_fallback_timeout => 40
    }
    
}
```

## Notes
