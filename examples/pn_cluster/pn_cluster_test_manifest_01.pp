# Fail, Cannot change names
pn_cluster { 'spine-1':
  ensure => present,
  nodes => ['ara04', 'draco12']
}

# Expect Failure
pn_cluster { 'failure-spine':
  ensure => present,
  nodes => ['ara04', 'draco11']
}