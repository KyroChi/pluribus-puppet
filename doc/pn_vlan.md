# pn_vlan

Controls VLANs on the destination switch.

| Option      | Valid Values                                                  | Default      |
|-------------|---------------------------------------------------------------|:------------:|
|ensure       |present or absent                                              |**REQUIRED**  |
|scope        |local or fabric                                                |**REQUIRED**  |
|description  |string, must be letters, numbers, \_, ., :, or -               | `''`         |
|ports        |comma seperated list, no whitespace. Must be between 2 and 4092| `'none'`     |

##### Usage
If you are ensuring absent the other parameters can be ignored, including scope, which cannot be ignored if you are insuring present.
```
pn_vlan { '<id>':
	ensure => absent
}
```
If you are ensuring present it is reccomended that you include all of the parameters. It is also reccomended that defaults are explicitly stated so as to improve readability and prevent future breaks if the defaults in the codebase change.
```
pn_vlan { '<id>':
	ensure => present,
    scope => <local|fabric>,
    description => <description>,
    ports => <ports>
}
```
##### Examples
```
pn_vlan { '1000':
	ensure => present,
    scope => local,
    description => 'Puppet-1000',
    ports => '56,74,101-127'
}
```
```
pn_vlan { '1001':
	ensure => absent,
    ports => '56,74,101-127'
}
```
```
pn_vlan { '1002':
	ensure => present,
    scope => fabric,
    description => 'Puppet-1002',
    ports => 'none'
}
```