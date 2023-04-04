# @summary bootstrap node
#
# @param custom_facts
#   Create custom facts on the node for these fact names
# @param classes
#   Bootstrap classes to contain
#
class btde::bootstrap (
  Array $custom_facts = [],
  Array $classes = [],
) {
  $_custom_facts = $custom_facts.reduce({}) |$memo, $fact| {
    $memo + { $fact => $facts[$fact] }
  }

  file { ['/etc/facter','/etc/facter/facts.d']:
    ensure => directory,
  }
  -> file { '/etc/facter/facts.d/test.json':
    content => btde::to_json($_custom_facts),
  }

  $classes.map |$c| { "btde::bootstrap::${c}" }.contain
}
