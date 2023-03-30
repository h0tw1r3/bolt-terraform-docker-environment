# @summary bootstrap any role
#
# @param password
#   generated user password
# @param groups
#   ensure generated user is member of groups
#
# @api private
class btde::bootstrap::base (
  Sensitive $password,
  Optional[Array] $groups,
) {
  assert_private()

  $user = $facts['btde']['user']
  $group = $facts['btde']['group']
  $ssh_key = file("${module_name}/../keys/ssh.pub").split(/\s/)

  group { $group['name']:
    gid => $group['gid'],
  }
  -> user { $user['name']:
    ensure     => present,
    password   => Sensitive(sprintf('%s', btde::hash_passwd($password))),
    uid        => $user['uid'],
    gid        => $user['gid'],
    managehome => true,
    groups     => $groups,
    shell      => '/bin/bash',
  }
  -> ssh_authorized_key { "${user['name']}@${module_name}":
    ensure => present,
    user   => $user['name'],
    key    => $ssh_key[1],
    type   => $ssh_key[0],
  }

  file { '/etc/profile.d/btde-shell_prompt.sh':
    content => file("${module_name}/shell_prompt.sh"),
  }
}
