# @summary base role
#
# @api private
class btde::bootstrap::role::base {
  assert_private()

  contain btde::bootstrap::role::common
}
