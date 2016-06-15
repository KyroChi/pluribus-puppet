# name

Description

| Option         | Valid Values                          | Default      |
|----------------|---------------------------------------|:------------:|
|ensure          |present or absent                      |**REQUIRED**  |
|vnet            |a valid vnet on the network            |**REQUIRED**  |
|hw_vrrp_id      |any number                             |**REQUIRED**  |
|service         |enable or disable                      |`'enable'`    |
|bgp_as          |must be a number                       |`''`          |
|switch          |The switch where the vRouter is located|`'local'`     |

1. [Usage](#usage)
2. [Examples](#examples)
3. [Notes](#notes)

## Usage

Usage notes

```puppet
pn_vrouter { <vrouter-name>:
  ensure => present,
  vnet => <vnet-name>,
  hw_vrrp_id => <number>,
  service => <enable|disable>,
}
```

## Examples

Creates a vRouter called 'example-vrouter'.

```puppet
pn_vrouter { 'example-vrouter':
  ensure => present,
  vnet => 'example-vnet',
  hw_vrrp_id => 18,
  service => enable,
}
```

## Notes