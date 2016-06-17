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

Puppet::Type.newtype(:pn_vlan) do

  # @doc
  # @name: pn_vlan
  # @desc: Controls VLANs on the destination switch.
  # @example: examples/pn_vlan/example_vlan_range.pp
  # @example: examples/pn_vlan/pn_vlan_test_manifest_01.pp
  #

  desc "Manage a VLAN.

  pn_vlan {\"<vlan>\":
    ..attributes..
  }

  Example Usage:

    pn_vlan {\"2000\":
      ensure => present,
      scope => 'local',
      description => \"Description here.\",
      stats => 'enabled',
      ports => [68, 70, 78],
      untagged_ports => [65, 67, 72],
    }"

  # This type is ensurable, Netvisor can check to see if a VLAN is either
  # present or absent.
  #
  ensurable

  # @doc
  # @param: ID
  # @default:
  # @vals: number between 2 and 4092
  # @desc: The id of the vLAN being managed. vLAN ids are not unique across
  #     fabrics, however because of the nature and propagation of fabric vLANSs
  #     there is no need to worry about duplicate decelerations or interference
  #     from multiple vLANs.
  # @dev:
  #
  newparam(:id) do
    desc "The id of the vLAN to be managed."
    isnamevar
    # validate do |value|
    #   if not value !~ /\D/
    #     raise ArgumentError, 'ID must be a number'
    #   elsif not value.to_i.between?(2, 4092)
    #     raise ArgumentError, 'ID must be between 2 and 4092'
    #   end
    # end
  end

  # @doc
  # @prop: Scope
  # @default:
  # @vals: local fabric
  # @desc: The scope of the vLAN being managed. This can either be fabric or
  #     local depending on whether or not you need a local vLAN or one present
  #     on the fabric.
  # @dev:
  #
  newproperty(:scope) do
    desc "Set the scope of the specified fabric. Must be 'local' or 'fabric'"
    munge do |value|
      value.downcase
    end
    newvalues(:local, :fabric)
  end

  # @doc
  # @prop: Description
  # @default: `''`
  # @vals: string containing letters, numbers, _, ., : and -
  # @desc: The description of the vLAN being created. It is recommended that the
  #     vLAN description describe what the vLAN is used for.
  # @dev:
  #
  newproperty(:description) do
    desc 'Description of the specified fabric'
    defaultto('')
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'Description can only contain letters, numbers, ' +
            '_, ., :, and -'
      end
    end
  end

  # @doc
  # @prop: Stats
  # @default: `enable`
  # @vals: enable disable
  # @desc: Enable or disable vLAN stats for the managed vLAN resource.
  # @dev:
  #
  newproperty(:stats) do
    desc 'Enable or disable vlan statistics'
    defaultto(:enable)
    newvalues(:enable, :disable)
  end

  # @doc
  # @prop: Ports
  # @default: ``'none'``
  # @vals:
  # @desc:
  # @dev:
  #
  newproperty(:ports) do
    desc 'no whitespace comma seperated ports and port ranges'
    defaultto('none')
  end

  # @doc
  # @prop: Untagged_Ports
  # @default: ``'none'``
  # @vals:
  # @desc:
  # @dev:
  #
  newproperty(:untagged_ports) do
    desc 'no whitespace comma seperated ports and port ranges'
    defaultto(:none)
  end

end

