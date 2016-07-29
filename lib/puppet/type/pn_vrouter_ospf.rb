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

require File.expand_path(
          File.join(File.dirname(__FILE__),
                    '..', '..', 'puppet_x', 'pn', 'type_helper.rb'))

include PuppetX::Pluribus::TypeHelper

require 'ipaddr'

Puppet::Type.newtype(:pn_vrouter_ospf) do

  ensurable
  switch()

  newparam(:name) do
    munge do |value|
      # *Rolls eyes* convert an ip to its netmasked ip
      vrouter, ip = value.split(' ')
      mask = /\/(.*)/.match(ip).to_s
      ip = IPAddr.new(ip).to_s
      value = vrouter + ' ' + ip + mask
    end
  end

  newproperty(:ospf_area) do
    validate do |value|
      if value =~ /[^\d*$]/ and value != ''
        raise ArgumentError, 'bgp_as must be a number'
      end
    end
  end

end
