# @summary bootstrap primary puppet server
#
# @api private
class btde::bootstrap::primary {
  assert_private()

  require btde::bootstrap::base
}
