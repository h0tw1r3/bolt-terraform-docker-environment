# frozen_string_literal: true

# @summary
#   Converts the path name of a file to an absolute path name.
#
Puppet::Functions.create_function(:'btde::abspath') do
  # @param path
  #   Path name to convert
  #
  # @return
  #   Absolute path name
  #
  # @example
  #   $path = btde::abspath('../../somepath')
  #
  dispatch :abspath do
    required_param 'String', :path
    return_type 'String'
  end

  def abspath(path)
    File.expand_path(path)
  end
end
