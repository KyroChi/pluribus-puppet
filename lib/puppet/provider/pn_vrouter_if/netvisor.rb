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

# Combine ip and vrrp interfaces and make it so that you can submit ranges
# to the interface

require File.expand_path(
    File.join(File.dirname(__FILE__),
              '..', '..', '..', 'puppet_x', 'pn', 'mixin_helper.rb'))

include PuppetX::Pluribus::MixHelper

Puppet::Type.type(:pn_vrouter_if).provide(:netvisor) do

  # no path so only one provider for Solaris and Linux
  #  both platforms have cli in /usr/bin/cli
  #
  commands :cli => 'cli'

  def build_vrrp_primary(i)

    out = cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
              @vrouter, 'ip',
              build_ip(0, resource[:vrrp_ip], @mask, i),
              'format', 'nic', PDQ).split('%')

    unless out[1].nil?
      return out[1].strip
    end
    fail('no primary interface')
  end

  def exists?

    location = resource[:switch] == :local ? `hostname`.strip : resource[:switch]

    vrouter_locations = cli('vrouter-show', 'format',
                            'location', PDQ).split("\n")

    vrouter_locations.each do |loc|
      if loc == location
        @vrouter = cli('vrouter-show', 'location', location,
                       'format', 'name', PDQ).strip
      end
    end

    unless @vrouter
      if resource[:ensure] == :present
        vnet = cli(*splat_switch, 'vnet-show',
                   'format', 'name', PDQ).split("\n")[0].split('%')[0]
        @vrouter = "#{location}-vrouter"
        cli('vrouter-create', 'name', @vrouter, 'vnet', vnet, 'enable',
            'hw-vrrp-id', '18', Q)
      else
        return false
      end
    end

    @vrrp = false
    if resource[:vrrp_priority] != 'none' and
        resource[:vrrp_ip] != 'none'
      if resource[:vrrp_ip] == resource[:name].split(' ')[1]
        fail('IP address and VRRP address must be different')
      else
        vip = resource[:vrrp_ip].split('.')
        ip = resource[:name].split(' ')[1].split('.')
        if (vip[0] != ip[0] or vip[1] != ip[1] or vip[2] != ip[2]) or
            ip[3].strip == vip[3].strip
          fail('IP address and VRRP address must be on the same subnet')
        end
      end
      @vrrp = true
      @vrrp_ip, @vrrp_mask = resource[:vrrp_ip].split '/'

      @vrrp_hw_id = cli(*splat_switch, 'vrouter-show',
                        'name', @vrouter,
                        'format', 'hw-vrrp-id', PDQ).strip

    elsif resource[:vrrp_priority] != 'none' or
        resource[:vrrp_ip] != 'none'

      if resource[:ensure].to_s == 'present'
        warn("Not all VRRP parameters defined, creating an IP interface" +
                 " instead")

      end
      @vrrp = false
    end

    range, x, @ip = resource[:name].rpartition(' ')
    @ip, @mask = @ip.split('/')
    @ids = deconstruct_range(range)

    @ids.each do |i|

      if cli(*splat_switch, 'vlan-show', 'id', i, 'format', 'id', PDQ) == ''
        cli(*splat_switch, 'vlan-create', 'id', i, 'scope', 'fabric')
      end

      if cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
             @vrouter, 'nic',
             get_nic(1, @vrouter, @ip, @mask, i), Q) == ''
        if resource[:ensure].to_s == 'present'
          return false
        end
      else
        if resource[:ensure].to_s == 'absent'
          return true
        end
      end

      if @vrrp
        unless cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
               @vrouter, 'nic',
                   get_nic(1, @vrouter, @vrrp_ip, @mask, i), Q) == ''

          if cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
                 @vrouter, 'nic',
                 get_nic(1, @vrouter, @vrrp_ip, @mask, i),
                 'format', 'vrrp-id', PDQ).split('%')[1].nil?
            if resource[:ensure].to_s == 'present'
              return false
            end

          else

            if resource[:ensure].to_s == 'absent'
              return true
            end

          end
        end
      end
    end
    # if the above logic returns neither true or false than all of the resources
    # are in the correct state and exists returns whatever Puppet is looking for
    if resource[:ensure].to_s == 'absent'
      return false
    else
      return true
    end
  end

  def create
    @ids.each do |i|

      interface_ip = build_ip(1, @ip, @mask, i)

      current = cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
                    @vrouter, 'ip', interface_ip, 'format', 'nic',
                    PDQ).split("\n")

      if current != '' and
          get_nic(1, @vrouter, @ip, @mask, i).strip == ''

        current.sort.reverse.each do |c|
          cli('vrouter-interface-remove', 'vrouter-name', @vrouter,
              'nic', c.split('%')[1].strip)
        end
      end

      if cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
             @vrouter, 'nic',
             get_nic(1, @vrouter, @ip, @mask, i), Q) == ''

        cli(*splat_switch, 'vrouter-interface-add',
            'vrouter-name', @vrouter, 'ip', interface_ip,
            'vlan', i, 'if', 'data')

        if @vrrp
          vrrp_ip = build_ip(1, @vrrp_ip, @vrrp_mask, i)
          if cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
                 @vrouter, 'nic',
                 get_nic(1, @vrouter, @vrrp_ip, @mask, i),
                 Q) == ''

            cli(*splat_switch, 'vrouter-interface-add',
                'vrouter-name', @vrouter, 'ip', vrrp_ip,
                'vlan', i, 'if', 'data', 'vrrp-id', @vrrp_hw_id,
                'vrrp-primary', build_vrrp_primary(i),
                'vrrp-priority', resource[:vrrp_priority])

          else

            interfaces = cli(*splat_switch, 'vrouter-interface-show',
                             'vrouter-name', @vrouter,
                             'ip', vrrp_ip, PDQ, 'format', 'ip').split("\n")

            @exists = false
            interfaces.each do |j|
              if j.split('%')[1] == vrrp_ip
                @exists = true
              end
            end

            unless @exists
              cli(*splat_switch, 'vrouter-interface-add',
                  'vrouter-name', @vrouter, 'ip', vrrp_ip,
                  'vlan', i, 'if', 'data', 'vrrp-id', @vrrp_hw_id,
                  'vrrp-primary', build_vrrp_primary(i),
                  'vrrp-priority', resource[:vrrp_priority])
            end
          end
        end
      end
    end
  end

  def destroy
    @ids.each do |i|
      # nics to destroy
      nics = []
      interface_ip = build_ip(1, @ip, @mask, i)

      out = cli(*splat_switch, 'vrouter-interface-show', 'vrouter-name',
                @vrouter, 'ip', interface_ip, 'format', 'nic',
                PDQ).split("\n")

      out.each do |o|
        nics.push(o.split('%')[1].strip)
      end
      nics.sort.reverse.each do |n|

        cli(*splat_switch, 'vrouter-interface-remove', 'vrouter-name',
            @vrouter, 'nic', n)

      end
    end
  end

  def switch
    resource[:switch]
  end

  def vrrp_ip
    if @vrrp

      @ids.each do |i|
        interfaces = cli(*splat_switch, 'vrouter-interface-show',
                         'vrouter-name', @vrouter,
                         'ip', build_ip(1, @ip, @mask, i),
                         'format', 'ip,netmask,nic,vrrp-id', PDQ).split("\n")

        interfaces.each do |j|
          vr, ip, nm, ni, vi = j.split('%')

          unless vi.nil? or vi.strip == ''
            ip = ip + '/' + nm
            unless ip == build_ip(1, @vrrp_ip, @mask, i)
              return ip
            end
          end

        end
      end

    end
    resource[:vrrp_ip]
  end

  def vrrp_ip=(value)
    destroy
    create
  end

  def vrrp_priority
    if @vrrp
      @ids.each do |i|

        out = cli(*splat_switch, 'vrouter-interface-show',
                  'vrouter-name', @vrouter,
                  'nic', get_nic(1, @vrouter, @vrrp_ip, @mask, i),
                  'format', 'vrrp-priority', PDQ).split('%')[1]

        if !out.nil? and (out.strip != resource[:vrrp_priority].to_s and
            !(out.strip == '' and resource[:vrrp_priority].to_s == 'none'))

          return out.strip

        end
      end
    end
    resource[:vrrp_priority]
  end

  def vrrp_priority=(value)
    @ids.each do |i|

      cli(*splat_switch, 'vrouter-interface-show',
          'vrouter-name', @vrouter, 'nic',
          get_nic(1, @vrouter, @vrrp_ip, @mask, i),
          'vrrp-priority', value.to_i.to_s.strip)

    end
  end

end