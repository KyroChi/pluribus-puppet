# Fail
pn_lag { 'fail-lag':
  ensure => 'present',
  switch => 'draco_not_real',
  ports => 'none'
}