# @summary primary puppet server role
#
# @api private
class btde::bootstrap::role::primary {
  assert_private()

  contain btde::bootstrap::role::common
}
