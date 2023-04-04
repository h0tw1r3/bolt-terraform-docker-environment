# @summary bootstrap role
#
# @param map
#   role name to role class name
#
# @api private
class btde::bootstrap::role (
  Hash $map = {},
) {
  assert_private()

  $roll_bootstrap_class = ($facts['role'] in $map) ? {
    true    => "btde::bootstrap::role::${map[$facts['role']]}",
    default => 'btde::bootstrap::role::common',
  }

  contain $roll_bootstrap_class
}
