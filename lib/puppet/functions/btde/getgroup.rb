# frozen_string_literal: true

# @summary
#   Returns the group information for the specified group id or name
#
Puppet::Functions.create_function(:'btde::getgroup') do
  # @param key
  #   Group id or name
  #
  # @return
  #   Group structure or undef if not found
  #
  # @example
  #   $group_zero = btde::getgroup(0)
  #   $group_nobody = btde::getgroup('nobody')
  #
  dispatch :btde_getgroup do
    required_param 'Variant[Integer,String]', :key
    return_type 'Variant[Hash,Undef]'
  end

  def btde_getgroup(key)
    require 'etc'
    x = key.is_a?(Integer) ? Etc.getgrgid(key).to_h : Etc.getgrnam(key).to_h
    x.map { |k, v| [k.to_s, v] }.to_h
  rescue ArgumentError
    nil
  end
end
