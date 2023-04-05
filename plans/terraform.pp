# @summary manage infrastructure with terraform
#
# @param [Boolean] destroy
#     Destroy all terraform resources
#
# @param [Boolean] output
#     Display terraform output
#
# @param [Enum] provider
#     Use terraform provider
#
plan btde::terraform (
  Boolean $destroy = false,
  Boolean $output = false,
  Enum['docker'] $provider = 'docker',
) {
  $target = get_target('localhost')

  $terraform_vars = $target.vars()['terraform']

  $task = ($destroy) ? {
    true    => 'terraform::destroy',
    default => 'terraform::apply',
  }

  if ! $destroy {
    $init_result = run_task(
      'terraform::initialize',
      'localhost',
      dir => "./terraform/${provider}",
    )
  }

  $results = run_plan(
    $task,
    'dir' => "./terraform/${provider}",
    'var' => $terraform_vars,
  )
  $results.each |$result| {
    out::message($result.value['stdout'])
  }

  if ! $destroy and $output {
    $output_results = run_task(
      'terraform::output',
      'localhost',
      'dir' => "./terraform/${provider}",
    )
    $output_results.each |$result| {
      out::message($result.value)
    }
  }
}
