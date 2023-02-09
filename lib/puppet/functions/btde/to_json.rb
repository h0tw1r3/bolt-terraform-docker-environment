# frozen_string_literal: true

require 'json'

# @summary
#   Convert Array or Hash to JSON
#
Puppet::Functions.create_function(:'btde::to_json') do
  # @param value
  #   value to convert to JSON
  #
  # @return
  #   value converted to JSON
  #
  # @example
  #   $test = [1,2,3]
  #   $json = btde::to_json($test)
  #
  dispatch :to_json do
    required_param 'Variant[Hash,Array]', :value
    return_type 'String'
  end

  def to_json(value)
    JSON.pretty_generate value
  end
end
