# @summary manage local ssh_config for docker instances in ~/.ssh/btde_config
#
# @param [Boolean] noop
#   no changes, only report what would change
#
plan btde::local::ssh_config (
  Boolean $noop = false,
) {
  $targets = get_targets('docker')

  $ssh_hosts = $targets.reduce({}) |$memo, $target| {
    $check_config = ($target.transport_config()['host-key-check']) ? {
      true    => {},
      default => {
        'StrictHostKeyChecking' => 'no',
        'UserKnownHostsFile'    => '/dev/null',
      }
    }

    $domain = $target.vars()['terraform']['domain']

    $username = ('local_ssh_config_username' in $target.vars()) ? {
      true    => $target.vars()['local_ssh_config_username'],
      default => 'root',
    }

    $memo + {
      "${target.safe_name} ${target.target_alias.join(' ')} ${target.safe_name}.${domain}" => {
        'User'         => $username,
        'HostName'     => $target.uri,
        'IdentityFile' => btde::abspath($target.config()['ssh']['private-key']),
      } + $check_config,
    }
  }

  $target = get_target('localhost')
  $current_home = system::env('HOME')

  return apply($target, _noop => $noop, _catch_errors => true) {
    augeas { 'include_btde':
      lens    => 'Ssh.lns',
      incl    => "${current_home}/.ssh/config",
      context => "/files${current_home}/.ssh/config",
      changes => [
        'set Include[0] ~/.ssh/btde_config',
        'insert Include before *[1]',
        'mv Include[last()] Include[1]',
      ],
      onlyif  => 'match Include[.="~/.ssh/btde_config"] size == 0',
    }
    $ssh_content = epp('btde/ssh_config.epp', { hosts => $ssh_hosts })

    file { "${current_home}/.ssh/btde_config":
      mode    => '0400',
      content => $ssh_content,
    }
  }
}
