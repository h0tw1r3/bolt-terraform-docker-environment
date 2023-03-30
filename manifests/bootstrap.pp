# @summary bootstrap node
#
# @param custom_facts
#   Create custom facts on the node for these fact names
# @param packages
#   See hiera data/common.yaml
# @param role_map
#   See hiera data/common.yaml
#
class btde::bootstrap (
  Array $custom_facts = [],
  Array $packages = [],
  Hash  $role_map = {},
) {
  $_custom_facts = $custom_facts.reduce({}) |$memo, $fact| {
    $memo + { $fact => $facts[$fact] }
  }

  exec { 'pre-apt-update':
    command     => '/usr/bin/env apt-get -y update',
    environment => ['DEBIAN_NONINTERACTIVE=1'],
    onlyif      => '/usr/bin/env find /var/lib/apt/lists -maxdepth 0 -empty | grep -q .',
  }
  -> package { $packages: }
  -> file { ['/var/cache/puppet','/var/lib/puppet','/etc/facter','/etc/facter/facts.d']:
    ensure => directory,
  }
  -> file { '/etc/facter/facts.d/test.json':
    content => btde::to_json($_custom_facts),
  }
  -> service { 'puppet':
    ensure => stopped,
    enable => false,
  }

  $roll_bootstrap_class = ($facts['role'] in $role_map) ? {
    true    => "btde::bootstrap::${role_map[$facts['role']]}",
    default => 'btde::bootstrap::base',
  }

  include $roll_bootstrap_class

  Service['puppet']
  -> Class[$roll_bootstrap_class]
}
