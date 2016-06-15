# name

Description

| Option      | Valid Values                                                  | Default      |
|-------------|---------------------------------------------------------------|:------------:|
|ensure       |present or absent                                              |**REQUIRED**  |
|vrouter      |local or fabric                                                |**REQUIRED**  |
|ip           |string, must be letters, numbers, \_, ., :, or -               | `''`         |
|mask         |comma seperated list, no whitespace. Must be between 2 and 4092| `'none'`     |
|if_type      |`data`, `mgmt` or `span`                                       |`'data'`      |
|vrrp_id      |number between 0 and 255                                       |`'none'`      |
|primary_ip   |vrrp-primary or vrrp-primary-string                            |`'none'`      |
|vrrp_priority|number between 0 and 254                                       |`'none'`      |

1. [Usage](#usage)
2. [Examples](#examples)
3. [Notes](#notes)

## Usage

Usage notes

```puppet
pn_vrouter_vrrp{ <vlan>:
    ensure => present,
    vrouter => <vrouter-name>,
    ip => <ip>,
    mask => <mask>,
    vrrp_id => <id>,
    primary_ip => <>,
    vrrp_priority => <number>,
    require => Pn_vrouter_ip[<vlan>]
  }
```

## Examples

Creates a VRRP interface on ip interface 101

```puppet
pn_vrouter_vrrp{ '101':
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.1',
    mask => '24',
    vrrp_id => '18',
    primary_ip => 'x.x.x.3',
    vrrp_priority => '110',
    require => Pn_vrouter_ip['101']
  }
```

## Notes