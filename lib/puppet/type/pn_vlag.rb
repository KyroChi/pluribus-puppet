# Copyright 2016 Pluribus Networks
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Puppet::Type.newtype(:pn_vlag) do

  # DON'T need to make twice for each cluster, switch and peer-switch
  # interchangeable.
  # Do serious error handling in the Provider instead so that the switch can be
  # queried during error checking.

  @doc = "Manage VLAGs

~~~puppet
pn_vlag { '<name>':
    ensure => present,
    switch => <switch-name>,
    peer_switch => <peer-switch-name>,
    port => <vlag-port>,
    peer_port => <peer-port>,
    mode => <active|standby>,
    failover => <move|ignore>,
    lacp_mode => <off|passive|active>,
    lacp_timeout => <fast|slow>,
    lacp_fallback => <bundle|individual>,
    lacp_fallback_timeout => <30..60>
}
~~~

name: The name of the VLAG to be created.  No default, this is a required
  parameter.

ensure: Should the VLAG be present or absent.  No default, this is a required
  parameter.

switch: The name of the switch where the VLAG will live.  No default, this is a
  required parameter.

peer-switch: The name of the peer-switch (same cluster) on the VLAG.  No
  default, this is a required parameter.

  NOTE: The VLAG only needs to be specified once for the switch and its peer

port: The port on the switch to connect the VLAG.  No default, this is a
  required parameter.

peer-port: The port on the peer-switch to connect the VLAG. No default, this is
  a required parameter.

mode: active for active-active mode, passive for active-passive mode. Default is
  active.

failover: Choose between move (failover-move-L2) and ignore
  (failover-ignore-L2). Default is move.

lacp_mode: The lacp mode of the VLAG, can be active, passive or off. Default is
  off.

lacp_timeout: The lacp timeout of the VLAG, can be either fast or slow. Default
  is fast.

lacp_fallback: The VLAG's lacp fallback mode. Can be bundle (bundled fallback)
  or individual. The default is bundle.

lacp_fallback_timeout: The lacp fallback timeout in seconds. Can be between 30
  and 60. The default is 50.

Switch and peer-switch must already be part of a cluster before creating a VLAG.

Example:
~~~puppet
node puppet-agent.pluribusnetworks.com {
    pn_cluster { 'spine1-spine2':
        ensure => present,
        nodes => ['onvlspine1', 'onvlspine2']
    }
    pn_vlag { 'spine-to-leaf3':
        ensure => present,
        switch => onlvspine1,
        peer_switch => onvlspine2,
        port => spine1-to-leaf3,
        peer_port => spine2-to-leaf3,
        mode => active,
        failover => move,
        lacp_mode => passive,
        lacp_timeout => fast,
        lacp_fallback => bundle,
        lacp_fallback_timeout => 31
    }
    pn_vlag { 'spine-to-leaf4':
        ensure => present,
        switch => onlvspine1,
        peer_switch => onvlspine2,
        port => spine1-to-leaf4,
        peer_port => spine2-to-leaf4,
        mode => active,
        failover => move,
        lacp_mode => passive,
        lacp_timeout => fast,
        lacp_fallback => bundle,
        lacp_fallback_timeout => 31
    }
}
~~~"

  ensurable

  # The name of the vlan. Must follow the cli naming rules; can only contain
  # letters, numbers, _, ., :, and -
  #
  newparam(:name, :namevar => true) do
    desc "VLAN name"
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'VLAG name can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  # The name of one of the switches in the VLAN. switch and peer-switch are
  # technically interchangeable. As long as they are in a cluster the VLAG
  # should be created.
  #
  newproperty(:switch) do
    desc "Name of the switch where the VLAG will be created. Must be on the" +
             ' same fabric as the Puppet Agent.'
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, "Invalid switch name #{value}"
      end
    end
  end

  # The name of the peer-switch in the cluster. This switch is the VLAG peer of
  # switch. It must be in the same cluster and as such on the same fabric.
  #
  newproperty(:peer_switch) do
    desc "Name of the peer-switch where the VLAG will be created. Must be on " +
             'the same fabric as the Puppet Agent.'
    validate do |value|
      if value =~ /\s/
        raise ArgumentError, "Invalid peer-switch name #{value}"
      end
    end
  end

  # The port on the switch where the VLAN will be created. This should be a name
  # preferably describing the VLAG being created. Can only contain letters,
  # numbers, _, ., :, and -
  #
  newproperty(:port) do
    desc "Name of the port where the VLAG will be created."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, "Invalid port name #{value}"
      end
    end
  end

  # The port on the peer switch where the VLAN will be created. Must follow the
  # cli naming guidelines and should describe the VLAG being created. Can only
  # contain letters, numbers, _, ., :, and -
  #
  newproperty(:peer_port) do
    desc "Name of the port on the peer-switch where the VLAG will be created."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, "Invalid peer-port name #{value}"
      end
    end
  end


  # The vlag mode. The modes active-active and active-standby on the cli are
  # notated by active and standby respectively.
  #
  newproperty(:mode) do
    desc "The VLAG mode, can be either active or standby."
    defaultto(:active)
    newvalues(:active, :standby)
  end

  # The L2 failover mode. This can either be move (failover-move-L2) or ignore
  # (failover-ignore-L2).
  #
  newproperty(:failover) do
    desc "The L2 failover type, can either be move or ignore."
    defaultto(:move)
    newvalues(:move, :ignore)
  end

  # The lacp mode. Can be set to off, passive or active.
  #
  newproperty(:lacp_mode) do
    desc "The VLAGs lacp mode, can be off, passive or active."
    defaultto(:active)
    newvalues(:off, :passive, :active)
  end

  # Choose a lacp timeout for the VLAG, can be either fast (:fast) or slow
  # (:slow). This property's default value is :fast.
  #
  newproperty(:lacp_timeout) do
    desc "The lacp timeout can either be fast or slow."
    defaultto(:fast)
    newvalues(:slow, :fast)
  end

  # Choose lacp fallback mode. This can be either bundled (:bundle) or
  # individual (:individual). This property's default value is :bundle.
  #
  newproperty(:lacp_fallback) do
    desc "The lacp fallback, can be bundle or individual."
    defaultto(:bundle)
    newvalues(:bundle, :individual)
  end

  # The timeout in seconds for lacp fallback. Must be a number between 30 and 60
  #
  newproperty(:lacp_fallback_timeout) do
    desc "The lacp fallback timeout in seconds."
    defaultto('50')
    validate do |value|
      unless value.to_i.between?(30, 60)
        raise ArgumentError, "Timeout must be between 30 and 60 seconds"
      end
    end
  end

end
