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

Puppet::Type.newtype(:pn_vrouter_loopback) do

  @doc = "Creates a vRouter loopback interface on the destination switch.

Properties

name is a combination of the vRouter name and the loopback IP address, separated
by a space.

ensure tells Puppet how to manage the loopback interface. Ensuring present will
mean that the loopback interface will be created and present on the switch after
a completed catalog run. Setting this to absent will ensure that the loopback
interface is not present on the system after the catalog run.

switch is the name of the switch where the IP interface will be created. This
can be any switch on the fabric. The default value is local, which creates an IP
interface on the node where the resource was declared.

Example Implementation

CLI:
CLI (...) > vrouter-loopback-interface-add vrouter-name spine1vrouter ip
172.16.1.1

Puppet:
pn_vrouter_loopback { 'spine1vrouter 172.16.1.1':
    ensure => present,
}
"

  ensurable
  switch()

  newparam(:name) do
    desc "A combination of the vRouter name and the loopback IP address."
    validate do |d|
      vrouter, ip, overflow = d.split ' '
      if vrouter =~ /[^\w.:-]/
        raise ArgumentError, 'vRouter name can only contain letters, numbers,' +
            ' _, ., :, and -'
      end
      if ip !~ /(?x)^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[x])\.){3}
(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
        raise ArgumentError, 'Name must include a valid IP'
      end
      if overflow
        raise ArgumentError, 'Too many arguments'
      end
    end
  end

end
