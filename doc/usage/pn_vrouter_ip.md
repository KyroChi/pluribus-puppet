# pn_vrouter_ip

Manage vRouter IP Interfaces. 

| Option      | Valid Values                                                  | Default      |
|-------------|---------------------------------------------------------------|:------------:|
|ensure       |present or absent                                              |**REQUIRED**  |
|vrouter      |local or fabric                                                |**REQUIRED**  |
|ip           |string, must be letters, numbers, \_, ., :, or -               | `''`         |
|mask         |comma seperated list, no whitespace. Must be between 2 and 4092| `'none'`     |
|if_type      |`data`, `mgmt` or `span`                                       |`'data'`      |

1. [Usage](#usage)
2. [Examples](#examples)
3. [Notes](#notes)

## Usage

Cannot create a vRouter IP interface without a [vRouter](pn_vrouter.md), for this reason it is recommended that you create a vRouter and require it when defining the vRouter IP interface.

```puppet
pn_vrouter { <vrouter-name>:
    ...
}

pn_vrouter_ip{ <vlan>:
    require => Pn_vrouter[<vrouter-name>],
    ensure => <present|absent>,
    vrouter => <vrouter-name>,
    ip => <ip|ip-pattern>,
    mask => <number>,
  }
```

#### vlan (namevar)

The namevar for vRouter IP interfaces is the vLAN where the interface will live. To create multiple IP interfaces in a single manifest decleration you can use Puppet arrays, or pass a range as the namevar. For example `'101-105'`, `['101', '102', '103', '104', '105']` and `'101-103, 103-105'` will all create and manage the same resource. To optimize catalog optimization times it is recommended that you do not pass Puppet a namevar array and instead use a range namevar. Range namevars execute much faster than Puppet's built in arrays.

#### ensure

Ensures that the resource is present or not.

#### vrouter

The vRouter that will host this IP interface. The vRouter must be created prior to creating a vRouter interface.

#### ip

The ip that the interface will be assigned. This can be an actual ip, as in `192.168.101.1`, however it is easier to use the built in ip pattern matching. You can feed the ip property an ip in the form of `x.x.x.1` and every x will be replaced by the vLAN id. The only number that cannot be an x is the final number. This is especially helpful when creating ranges of ip interfaces. Also valid are `255.x.x.1`, `x.255.x.4`, `x.x.34.3` and `255.x.255.3`.

#### mask

The ip netmask for the ip defined by the ip property.

## Examples

Creates 5 vRouter IP interfaces

```puppet
pn_vrouter_ip{ ['101', '102', '103', '104', '105']:
    ensure => present,
    vrouter => 'demo-vrouter',
    ip => 'x.x.x.3',
    mask => '24',
    require => Pn_vrouter['demo-vrouter']
  }
```

## Notes