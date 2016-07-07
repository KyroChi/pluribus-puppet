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

Puppet::Type.newtype(:pn_vrouter_if) do

  @doc = "Manage vRouter IP interfaces and vRouter VRRP interfaces. If you are
creating a VRRP interface you must specify both vrrp_ip and vrrp_priority,
otherwise and IP interface will be created. When you create a VRRP interface,
pn_vrouter_if creates an IP interface AND a VRRP interface in one resource
deceleration.

Properties

name is the id of the vLan that the vRouter interface will live on. The name
consists of a comma or whitespace seperated list of vLANs, followed by an IP
pattern including netmask. The IP follows pattern matching.

ensure tells Puppet how to manage the vRouter interface. Ensuring present will
mean that the vRouter interface will be created and present on the switch after
a completed catalog run. Setting this to absent will ensure that the vRouter
interface is not present on the system after the catalog run.

vrouter is the name of the vRouter that will host and manage the interface.

vrrp_ip is the ip of the VRRP interface. This also obeys IP pattern matching,
and the only criteria is that this ip cannot be the same as the IP of the IP
interface. Default is none.

vrrp_priority The VRRP interface priority, this can be a number between 0 and
255. Default is none.

switch is the name of the switch where the IP interface will be created. This
can be any switch on the fabric. The default value is local, which creates an IP
interface on the node where the resource was declared.

Example Implementation

CLI:

CLI (...) > vrouter-create name demo-vrouter vnet demo-vnet-global hw-vrrp-id 18
enable
CLI (...) > vlan-create id 101 scope fabric
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 101.101.101.2/24
vlan 101 if data
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 101.101.101.1/24
vlan 101 if data vrrp-id 18 vrrp-primary eth0.101 vrrp-priority 110
CLI (...) > vlan-create id 102 scope fabric
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 102.102.102.2/24
vlan 101 if data
CLI (...) > vrouter-interface-add vrouter-name demo-vrouter ip 102.102.102.1/24
vlan 101 if data vrrp-id 18 vrrp-primary eth0.101 vrrp-priority 110

Puppet:

pn_vrouter { 'demo-vrouter':
    ensure     => present,
    vnet       => 'demo-vnet-global',
    hw-vrrp-id => 18,
    service    => enable,
}

pn_vlan { '101-102':
    require     => Pn_vrouter['demo-vrouter'],
    ensure      => present,
    scope       => 'fabric',
}

pn_vrouter_if { '101-102 x.x.x.2/24':
    require       => Pn_vlan['101'],
    ensure        => present,
    vrouter       => 'demo-vrouter',
    vrrp_ip       => 'x.x.x.1',
    vrrp_priority => '110',
}
"

  ensurable

  @ip

  newparam(:name) do
    desc "The id of the vLan that the vRouter interface will live on."
    validate do |value|
      v = value.rpartition(' ')
      unless v.first =~ /^((\d{1,4}-\d{1,4})|(\d{1,4})[,\s$]*){1,}$|^(\d{1,4})$/
        raise ArgumentError, 'vLAN ID must be a number or range of numbers'
      end
      @H = PuppetX::Pluribus::PnHelper.new
      ids = @H.deconstruct_range(v.first)
      ids.each do |i|
        unless (2..4092) === i.to_i #i.to_i.between?(2, 4092)
          raise ArgumentError, 'vLAN ID must be between 2 and 4092'
        end
      end
      # Regex to check ips, check Rubular.com if you don't believe me
      unless v.last =~ /(?x)^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[x])\.)
{3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\/\d{1,2})$/
        raise ArgumentError, 'IP must be an actual IP or follow a correct ip ' +
            'pattern. Must also include a netmask'
      end
      @ip = v.last
    end
  end

  newproperty(:switch) do
    desc "The name of the switch where the IP interface will be created."
    defaultto(:local)
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'Switch name can only contain letters, ' +
            'numbers, _, ., :, and -'
      end
    end
  end

  newproperty(:vrouter) do
    desc "The name of the vRouter that will host and manage the IP interface."
    validate do |value|
      if value =~ /[^\w.:-]/
        raise ArgumentError, 'vRouter name can only contain letters, ' +
            'numbers, _, ., :, and -'
      end
    end
  end

  newproperty(:vrrp_ip) do
    desc "The ip of the VRRP interface."
    defaultto('none')
    # The second ip for the interface
    validate do |value|
      if value !~ /(?x)^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[x])\.)
{3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\/\d{1,2})$/ and value != 'none'
        raise ArgumentError, 'VRRP IP must be an actual IP or follow a ' +
            'correct ip pattern. Must also include a netmask'
      end
    end
  end

  newproperty(:vrrp_priority) do
    desc "The priority for the VRRP interface."
    defaultto('none')
    validate do |value|
      unless value =~ /^(2[0-5][0-5]|1[0-9][0-9]|[0-9][0-9]|[0-9])$/ or
          value == 'none'
        raise ArgumentError, 'vrrp_priority must be a number between 0 and 255'
      end
    end
  end

end
