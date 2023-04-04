# @summary bootstrap os
#
# @param packages
# @param class_name
#
# @api private
class btde::bootstrap::os (
  Array $packages = [],
  String $class_name = $facts['os']['family'],
) {
  assert_private()

  $full_class_name = "btde::bootstrap::os::${class_name.downcase()}"

  contain $full_class_name

  Class[$full_class_name]
  -> package { $packages: }
}
