# pn_cluster

Controls clustering of switches on the fabric.

does not support re-naming of clusters

| Option         | Valid Values              | Default      |
|----------------|---------------------------|:------------:|
|ensure          |present or absent          |**REQUIRED**  |
|nodes           |array of the required nodes|**REQUIRED**  |
|force_clustering|yes or no                  | `no`         |

##### Usage
```puppet
pn_cluster { '<cluster-name>':
	ensure => <present|absent>,
	nodes => ['<node1>','<node2>']
}
```
**Force Clustering**
Force clustering should only be used if you have identified a problem with the current cluster configuration and are sure that the cluster being forced is correct.
##### Examples
```puppet
pn_cluster { 'spine-cluster':
    ensure => present,
    nodes => ['spine_1', 'spine_2']
}
```

```puppet
pn_cluster { 'leaf-cluster-1:
   ensure => present,
   nodes => ['leaf_1', 'leaf_2'],
   force_clustering => 'yes
}
```