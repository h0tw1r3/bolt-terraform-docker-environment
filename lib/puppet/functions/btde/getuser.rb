# frozen_string_literal: true

# @summary
#   Returns the passwd information for the user with specified login id or name
#
Puppet::Functions.create_function(:'btde::getuser') do
  # @param key
  #   User login id or name
  #
  # @return
  #   Passwd structure or undef if not found
  #
  # @example
  #   $root_user = btde::getuser(0)
  #   $current_user = btde::getuser(system::env('USER'))
  #
  dispatch :btde_getuser do
    required_param 'Variant[String,Integer]', :key
    return_type 'Variant[Hash,Undef]'
  end

  def btde_getuser(key)
    require 'etc'
    x = key.is_a?(Integer) ? Etc.getpwuid(key).to_h : Etc.getpwnam(key).to_h
    x.map { |k, v| [k.to_s, v] }.to_h
  rescue ArgumentError
    nil
  end
end
