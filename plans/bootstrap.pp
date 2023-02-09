# @summary bootstrap nodes
#
# @param [TargetSpec] targets
#   targets to apply bootstrap
#
# @param [Boolean] noop
#   no changes, only report what would change
#
# @param [Boolean] ssh_config
#   maintain local ssh client configuration
#
plan btde::bootstrap (
  TargetSpec $targets = 'docker',
  Boolean    $noop = false,
  Boolean    $ssh_config = true,
) {
  if $ssh_config {
    run_plan('btde::local::ssh_config')
  }

  ctrl::do_until('interval' => 10, 'limit' => 12) || {
    $targets.apply_prep
  }

  $current_user = btde::getuser(system::env('USER'))
  $current_user_group = btde::getgroup($current_user['gid'])

  # prepare custom facts
  get_targets($targets).each() |$target| {
    [$target.safe_name, $target.target_alias].each |$pn| {
      if ($pn in $target.vars()['nodes'] and 'facts' in $target.vars()['nodes'][$pn]) {
        add_facts($target, $target.vars()['nodes'][$pn]['facts'])
      }
    }
    add_facts($target, {
        'btde' => {
          'user'  => $current_user,
          'group' => $current_user_group,
        },
    })
  }

  $results = apply($targets) {
    include btde::bootstrap
  }

  $results.each |$result| {
    if 'logs' in $result.report {
      $result.report['logs'].each |$log| {
        out::message("${result.target.safe_name} [${log['level'].upcase}] ${log['source']} | ${log['message']}")
      }
    }
    if ! $result.ok {
      log::error($result.error)
    }
  }
}
