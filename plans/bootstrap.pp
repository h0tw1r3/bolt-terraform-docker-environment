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
  ctrl::do_until('interval' => 10, 'limit' => 12) || {
    $targets.apply_prep
  }

  $current_user = btde::getuser(system::env('USER'))
  $current_user_group = btde::getgroup($current_user['gid'])

  $normalize_user_name = regsubst($current_user['name'], /((.+[\\+])|[\W\s])/, '', 'G')
  $normalize_group_name = regsubst($current_user_group['name'], /((.+[\\+])|[\W\s])/, '', 'G')

  # prepare custom facts
  get_targets($targets).each() |$target| {
    [$target.safe_name, $target.target_alias].each |$pn| {
      if ($pn in $target.vars()['nodes'] and 'facts' in $target.vars()['nodes'][$pn]) {
        add_facts($target, $target.vars()['nodes'][$pn]['facts'])
      }
    }
    add_facts($target, {
        'btde' => {
          'user'  => deep_merge($current_user, { 'name' => $normalize_user_name }),
          'group' => deep_merge($current_user_group, { 'name' => $normalize_group_name }),
        },
    })
    $target.set_var('local_ssh_config_username', $normalize_user_name)
  }

  if $ssh_config {
    run_plan('btde::local::ssh_config', 'noop' => $noop)
  }

  $results = apply($targets, _noop => $noop, _catch_errors => true) {
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

  return($results)
}
