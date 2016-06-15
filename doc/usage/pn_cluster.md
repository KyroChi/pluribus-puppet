# pn_cluster

Controls clustering of switches on the fabric.

| Option         | Valid Values              | Default      |
|----------------|---------------------------|:------------:|
|ensure          |present or absent          |**REQUIRED**  |
|nodes           |array of the required nodes|**REQUIRED**  |
|force_clustering|yes or no                  | `no`         |

1. [Usage](#usage)
2. [Examples](#examples)
3. [Notes](#notes)

## Usage

```puppet
pn_cluster { '<cluster-name>':
	ensure => <present|absent>,
	nodes => ['<node1>','<node2>']
}
```

## Examples

Creates a cluster between two switches named `spine_1` and `spine_2`.

```puppet
pn_cluster { 'spine-cluster':
    ensure => present,
    nodes => ['spine_1', 'spine_2']
}
```

Creates a cluster between two switches named `leaf_1` and `leaf_2`.

```puppet
pn_cluster { 'leaf-cluster-1:
   ensure => present,
   nodes => ['leaf_1', 'leaf_2'],
   force_clustering => 'yes
}
```

## Notes

* Does not currently support re-naming of clusters.
* Force clustering not yet implemented. (DO NOT USE)