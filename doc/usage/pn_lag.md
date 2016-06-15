# pn_lag

Manage link aggregation on the destination switch.

| Option      | Valid Values                                                  | Default      |
|-------------|---------------------------------------------------------------|:------------:|
|ensure       |present or absent                                              |**REQUIRED**  |
|switch       |local or fabric                                                |**REQUIRED**  |
|ports        |comma seperated list, no whitespace.                           | `'none'`     |

1. [Usage](#usage)
2. [Examples](#examples)
3. [Notes](#notes)

## Usage

Usage notes

```puppet
pn_lag { '<lag-name>':
	ensure => <present|absent>,
	switch => <switch-name>,
	ports => <ports>
}
```

## Examples

```puppet
pn_lag { 'my-new-lag':
    ensure => present,
    switch => 'f64-a',
    ports => '4,5,128-130'
}
```

## Notes