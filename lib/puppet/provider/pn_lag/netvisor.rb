# Copyright (C) 2016 Pluribus Networks
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Puppet::Type.type(:pn_lag).provide(:netvisor) do

  # Don't pre-fetch as there are too many instances to query and they are not
  # guaranteed to have unique identifiers across nodes.

  desc 'Provider: Netvisor'

  commands :cli => 'cli'

  # Check existence of the LAG/Trunk. Relatively easy checking compared to some
  # of the other resource checking. Checks that the cli returns something other
  # than ''.
  # @return: true if resource exists, false otherwise
  #
  def exists?
    switch
    if cli('--quiet', 'switch', resource[:switch], 'trunk-show', 'name',
           resource[:name], 'no-show-headers', 'parsable-delim', '%') != ''
      return true
    end
    false
  end

  # Creates a new LAG/Trunk from the cli, this is used when the specified
  # resource does not yet exist.
  # @return: nil
  #
  def create
    cli('switch', resource[:switch], 'trunk-create', 'name', resource[:name],
        'ports', resource[:ports])
  end

  # Destroys the specified LAG.
  # @return: nil
  #
  def destroy
    cli('switch', resource[:switch], 'trunk-delete', 'name', resource[:name])
  end

  # Returns true or fails operation. Can be used to verify that the switch is on
  # the current fabric and can be managed. Cannot ever return false as the
  # switch isn't configurable by they user in the current scope.
  # @return: true
  #
  # TODO: Allow arrays as an argument so that many lags can be configured with
  #  a single command.
  def switch
    if cli('--quiet', 'switch', resource[:switch]) =~ /switch:/
      fail("Could not establish a connection to #{resource[:switch]}")
    else
      resource[:switch]
    end
  end

  # Get the current ports associated with the LAG. Will be in the form of
  # 'none', 'all', or a comma separated list of ports (ie. '2,4,5,8,9').
  # Output compared to resource[:ports].
  # @return: output of cli command.
  #
  def ports
    cli('--quiet', 'switch', resource[:switch], 'trunk-show', 'name',
        resource[:name], 'no-show-headers', 'format', 'ports,').strip!
  end

  # Since ports cannot be modified via cli commands the provider must first
  # destroy and than re-create the specified resource.
  # @return: nil
  #
  def ports=(value)
    delete
    create
  end

end