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
    ports = cli('--quiet', 'vlag-show', 'format', 'name,port,peer-port',
               'no-show-headers', 'parsable-delim', '%').split("\n")
    debug(ports)
    ports.each do |p|
      name, port, peer_port = p.split("%", 3)
      if port == resource[:name] or peer_port == resource[:name]
        cli('--quiet', 'vlag-delete', 'name', name)
      end
    end
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

  # Checks to make sure that the ports specified by the manifest are available
  # for use as LAG ports. This method will either return nil or fail.
  # @return: nil
  #
  def verify_ports
    fail("Port(s) #{resource[:ports]} cannot be used to establish a LAG")
  end

  # Helper method to parse ports both from the user and from Netvisor.
  # @return: An array of sorted ports.
  #
  def port_arr(ports)
    port_arr = []
    ports.split(",").each do |x|
      if x =~ /-/
        y = x.split('-')
        (y[0]..y[1]).each do |n|
          port_arr.push(n)
        end
      else
        port_arr.push(x)
      end
    end
    port_arr.sort
  end

  # Get the current ports associated with the LAG. Will be in the form of
  # 'none', 'all', or a comma separated list of ports (ie. '2,4,5,8,9').
  # Output compared to resource[:ports].
  # @return: output of cli command.
  #
  def ports
    ports = cli('--quiet', 'switch', resource[:switch], 'trunk-show', 'name',
        resource[:name], 'no-show-headers', 'format', 'ports,').strip!
    in_ports = port_arr(resource[:ports])
    act_ports = port_arr(ports)
    if in_ports == act_ports
      return resource[:ports]
    else
      return act_ports
    end
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