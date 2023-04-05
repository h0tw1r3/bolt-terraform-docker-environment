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

  if $facts['role'] {
    $map[$facts['role']] ? {
      String  => "btde::bootstrap::role::${map[$facts['role']]}",
      default => "btde::bootstrap::role::${facts['role']}",
    }.contain
  }
}
