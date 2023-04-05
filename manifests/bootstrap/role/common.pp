# @summary common resources for all roles
#
# @api private
class btde::bootstrap::role::common {
  assert_private()

  file { '/etc/profile.d/btde-shell_prompt.sh':
    content => file("${module_name}/shell_prompt.sh"),
  }
}
