# frozen_string_literal: true

# @summary
#   Generates a SHA512 passwd (shadow) suitable hash using a fqdn_rand salt
#
Puppet::Functions.create_function(:'btde::hash_passwd') do
  # @param password
  #   Value to generate a passwd hash for
  #
  # @return
  #   SHA-512 passwd hash
  #
  # @example
  #   $hash = btde::hash_passwd('super secure stuff here')
  #
  dispatch :btde_hash_passwd do
    required_param 'Variant[Sensitive,String]', :password
    return_type 'String'
  end

  def btde_hash_passwd(password)
    password = password.unwrap if password.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
    charset = [('A'..'Z'), ('a'..'z'), (0..9)].map(&:to_a).flatten.map(&:to_s)

    p = call_function('fqdn_rand', 100_000_000, password)
    p = p.to_s.chars.each_slice(2).map(&:join).map(&:to_i).map { |i| charset[i > charset.length ? i - charset.length : i] }.join('')

    password.crypt("$6$#{p}")
  end
end
