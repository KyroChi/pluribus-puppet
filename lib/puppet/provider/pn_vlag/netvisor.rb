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

Puppet::Type.type(:pn_vlag).provide(:netvisor) do

  desc 'Provider: Netvisor'

  # no path so only one provider for Solaris and Linux
  #  both platforms have cli in /usr/bin/cli

  commands :cli => 'cli'

  # No pre-fetching or instances as they are too heavy of system calls to be
  # executed whenever a manifest is applied.

  @remake = false

  # This method returns specific information about the specified VLAG.
  # @param name: The name of the VLAG to query
  # @param format: The desired information to retrieve. Must be in the vlag-show
  #  table.
  # @return: A string containing the desired information
  #
  def get_vlag_info(name, format)
    info = cli('--quiet', 'switch', resource[:switch], 'vlag-show', 'name',
               name, 'no-show-headers', 'format', format).chomp.strip!
  end

  # Query the system and check whether or not the specified resource exists on
  # on the switch.
  # @return: false if resource does not exist, true otherwise
  #
  def exists?
    verify_switches_clustered
    if @remake
      debug("Remake called")
      #destroy
      #create
      @remake = false
    end
    if get_vlag_info(resource[:name], 'name') == ''
      return false
    end
    true
  end

  # This method verifies that both nodes are in a cluster together before
  # attempting to create a new VLAG. Nodes can only create VLAGs if they are a
  # member of a cluster, and can only create a VLAG with the switch they are
  # clustered with. This method will either return 0 or cause a failure. Calls
  # switch and verify_peer_switch so those do not need to be explicitly called
  # by exists?
  # @return: 0
  #
  def verify_switches_clustered
    switch
    verify_peer_switch
    # Check that the peer-switch is the same as defined by the manifest.
    if cli('--quiet', 'switch', resource[:switch], 'cluster-show',
           'cluster-node-1', resource[:switch], 'format',
           'cluster-node-2', 'no-show-headers').strip! == \
           resource[:peer_switch] or cli('--quiet', 'switch', resource[:switch],
                                         'cluster-show', 'cluster-node-2',
                                         resource[:switch], 'format',
                                         'cluster-node-1',
                                         'no-show-headers').strip! == \
                                         resource[:peer_switch]
      return 0
    else
      fail("Could not verify that #{resource[:switch]} and " +
               "#{resource[:peer_switch]} are in a cluster together")
    end
  end

  # Returns true or fails operation. Can be used to verify that the switch is on
  # the current fabric and can be managed. Cannot ever return false as the
  # switch isn't configurable by they user in the current scope. Because this
  # method will never return false, there is no need for a switch=() method.
  # @return: true
  #
  def switch
    if cli('--quiet', 'switch', resource[:switch]) =~ /switch:/
      fail("Could not establish a connection to #{resource[:switch]}")
    else
      resource[:switch]
    end
  end

  # Make sure specified ports are valid
  #
  def verify_port

  end

  # Check the port that the VLAG is currently present on and compare it to the
  # port specified by the user.
  # @return: A string representing the port that the VLAN is present on.
  #
  def port
    get_vlag_info(resource[:name], 'port')
  end

  # Since ports are not modifiable by the cli, the resource must be deleted and
  # re-created.
  # @return: nil
  #
  def port=(value)
    @remake = true
  end

  # Not sure if needed
  #
  def verify_peer_port

  end

  # Query the resource and return the current peer-port
  # @return: String name of the peer-port
  #
  def peer_port
    get_vlag_info(resource[:name], 'peer-port')
  end

  # Since peer-ports are not modifiable by the cli, the resource must be deleted
  # and re-created.
  # @return: nil
  #
  def peer_port=(value)
    @remake = true
  end

  # Get the current mode of the resource, either active or standby. Resource can
  # only be in 'active-active' or 'active-standby' so the output must be
  # converted prior to being returned.
  # @return: :active or :standby
  #
  def mode
    if get_vlag_info(resource[:name], 'mode') == 'active-active'
      :active
    else
      :standby
    end
  end

  # Since mode isn't modifiable by the cli, the resource must be deleted and
  # re-created.
  # @return: nil
  #
  def mode=(value)
    @remake = true
  end

  # Verifies that the specified peer switch exists and is manageable by the
  # Puppet Agent. If a connection to the node cannot be established this method
  # will cause a failure to abort the operation of the provider. This method
  # either return nil or cause a failure.
  # @return: nil
  #
  def verify_peer_switch
    if cli('--quiet', 'switch', resource[:peer_switch]) =~ /switch:/
      fail("Could not establish a connection to #{resource[:peer_switch]}")
    end
  end

  # Check the current VLAG peer switch.
  # @return: A string containing the name of the current peer-switch.
  #
  def peer_switch
    get_vlag_info(resource[:name], 'peer-switch')
  end

  # Since we cannot change the
  def peer_switch=(value)
    @remake = true
  end

  def failover
    if get_vlag_info(resource[:name], 'failover-move-L2') == 'no'
      :ignore
    else
      :active
    end
  end

  # Sets the failover to the value specified in the resource type deceleration.
  # Since this is modifiable by the cli all we need to do is call the
  # vlag-modify command.
  # @return: nil
  #
  def failover=(value)
    cli('switch', resource[:switch], 'vlag-modify', 'name', resource[:name],
        "failover-#{value}-L2")
  end

  # Checks the current lacp mode. Converts the switch's built in 'active-active'
  # and 'active-standby' to :active and :standby respectively.
  # @return: :active or :standby
  #
  def lacp_mode
    if get_vlag_info(resource[:name], 'lacp-mode') == 'active'
      :active
    else
      :standby
    end
  end

  # lacp-mode is not modifiable so we have to remake the resource to change
  # lacp-mode.
  # @return: nil
  #
  def lacp_mode=(value)
    @remake = true
  end

  # Checks the current lacp timeout. Converts cli output to either :move or
  # :ignore.
  # @return: :move or :ignore
  #
  def lacp_timeout
    get_vlag_info(resource[:name], 'lacp-timeout')
  end

  # Since we can modify lacp-timeout from the cli we can use the Puppet setter
  # to set the proper value for the timeout without having to re-make the
  # resource.
  # @return: nil
  #
  def lacp_timeout=(value)
    cli('vlag-modify', 'name', resource[:name], "lacp-timeout", value)
  end

  # Check the current lacp fallback of the resource.
  # @return: A string containing the current lacp fallback
  #
  def lacp_fallback
    get_vlag_info(resource[:name], 'lacp-fallback')
  end

  # lacp-fallback is a modifiable property from the cli so we don't need to
  # re-make. This method simply calls the cli command to modify the VLAG and
  # supplies the necessary parameters.
  # @return: nil
  #
  def lacp_fallback=(value)
    cli('vlag-modify', 'name', resource[:name], 'lacp-fallback', value)
  end

  # Checks what the current lacp fallback timeout is set to.
  # @return: the current lacp fallback timeout
  #
  def lacp_fallback_timeout
    get_vlag_info(resource[:name], 'lacp-fallback-timeout')
  end

  # The lacp fallback timeout can be set by the cli so we simply call the cli
  # command and pass in the desired value for the timeout.
  # @return: nil
  #
  def lacp_fallback_timeout=(value)
    cli('vlag-modify', 'name', resource[:name], 'lacp-fallback-timeout', value)
  end

  # Create a new VLAG from the cli. This method pulls data from the specified
  # resource and should not be called until all of the resources have been
  # confirmed.
  # @return: nil
  #
  def create
    cli('vlag-create', 'name', resource[:name],
        'port', resource[:port],
        'peer-port', resource[:peer_port],
        'mode', "active-#{resource[:mode]}",
        'peer-switch', resource[:peer_switch],
        "failover-#{resource[:failover]}-L2",
        'lacp-mode', resource[:lacp_mode],
        'lacp-timeout', resource[:lacp_timeout],
        'lacp-fallback', resource[:lacp_fallback],
        'lacp-fallback-timeout', resource[:lacp_fallback_timeout])
  end

  # Destroy the resource. This method simply calls the destroy command on the
  # cli to delete the VLAG.
  # @return: nil
  #
  def destroy
    cli('vlag-delete', 'name', resource[:name])
  end

end