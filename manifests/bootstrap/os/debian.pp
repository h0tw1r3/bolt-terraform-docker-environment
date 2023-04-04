# @summary bootstrap debian type os
#
# @api private
class btde::bootstrap::os::debian {
  assert_private()

  exec { 'pre-apt-update':
    command     => '/usr/bin/env apt-get -y update',
    environment => ['DEBIAN_NONINTERACTIVE=1'],
    onlyif      => '/usr/bin/env find /var/lib/apt/lists -maxdepth 0 -empty | grep -q .',
  }
}
