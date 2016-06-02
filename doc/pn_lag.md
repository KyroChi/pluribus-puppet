Controls VLANs on the destination switch.

| Option      | Valid Values                                                  | Default      |
|-------------|---------------------------------------------------------------|:------------:|
|ensure       |present or absent                                              |**REQUIRED**  |
|switch       |local or fabric                                                |**REQUIRED**  |
|ports        |comma seperated list, no whitespace.                           | `'none'`     |

##### Usage
```puppet
pn_lag { '<lag-name>':
	ensure => <present|absent>,
	switch => <switch-name>,
	ports => <ports>
}
```
None of the pn_lag properties are optional. The switch must be connected to the same fabric as the Puppet Agent node.
##### Examples
```puppet
pn_lag { 'my-new-lag':
    ensure => present,
    switch => 'f64-a',
    ports => '4,5,128-130'
}
```