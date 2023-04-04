# @summary bootstrap primary puppet server
#
# @api private
class btde::bootstrap::role::primary {
  assert_private()

  contain btde::bootstrap::role::common
}
