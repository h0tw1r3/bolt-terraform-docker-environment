# @summary bootstrap any node type
#
# @api private
class btde::bootstrap::base {
  assert_private()

  $normalize_user_name = regsubst($facts['btde']['user']['name'], /((.+[\\+])|[\W\s])/, '', 'G')
  $normalize_group_name = regsubst($facts['btde']['group']['name'], /((.+[\\+])|[\W\s])/, '', 'G')

  group { $normalize_group_name:
    gid => $facts['btde']['group']['gid'],
  }
  -> user { $normalize_user_name:
    ensure     => present,
    uid        => $facts['btde']['user']['uid'],
    gid        => $facts['btde']['user']['gid'],
    managehome => true,
  }
}
