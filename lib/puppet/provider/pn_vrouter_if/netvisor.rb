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
              '..', '..', '..', 'puppet_x', 'pn', 'pn_helper.rb'))

require File.expand_path(
    File.join(File.dirname(__FILE__),
              '..', '..', '..', 'puppet_x', 'pn', 'pn_vrouter_helper.rb'))

Puppet::Type.type(:pn_vrouter_if).provide(:netvisor) do

  # no path so only one provider for Solaris and Linux
  #  both platforms have cli in /usr/bin/cli
  #
  commands :cli => 'cli'

  def build_vrrp_primary(i)

    out = cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
              resource[:vrouter], 'ip',
              @H.build_ip(0, resource[:vrrp_ip], @mask, i),
              'format', 'nic', @H.pdq).split('%')

    unless out[1].nil?
      return out[1].strip
    end

    fail('no primary interface')
  end

  def exists?
    # Create a new PnVrouterHelper
    @H = PuppetX::Pluribus::PnVrouterHelper.new(resource)

    if cli(*@H.splat_switch, 'vrouter-show', 'name',
           resource[:vrouter], @H.q) == ''
      fail('vRouter does not exist')
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

      @vrrp_hw_id = cli(*@H.splat_switch, 'vrouter-show',
                        'name', resource[:vrouter],
                        'format', 'hw-vrrp-id', @H.pdq).strip

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
    @ids = @H.deconstruct_range(range)

    @ids.each do |i|
      interface_ip = @H.build_ip(1, @ip, @mask, i)
      if cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
             resource[:vrouter], 'nic',
             @H.get_nic(1, resource[:vrouter], @ip, @mask, i), @H.q) == ''
        if resource[:ensure].to_s == 'present'
          return false
        end
      else
        if resource[:ensure].to_s == 'absent'
          return true
        end
      end

      if @vrrp
        unless cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
               resource[:vrouter], 'nic',
                   @H.get_nic(1, resource[:vrouter], @vrrp_ip, @mask, i),
                   @H.q) == ''

          if cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
                 resource[:vrouter], 'nic',
                 @H.get_nic(1, resource[:vrouter], @vrrp_ip, @mask, i),
                 'format', 'vrrp-id', @H.pdq).split('%')[1].nil?
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

      interface_ip = @H.build_ip(1, @ip, @mask, i)

      current = cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
                    resource[:vrouter], 'ip', interface_ip, 'format', 'nic',
                    @H.pdq).split("\n")

      if current != '' and
          @H.get_nic(1, resource[:vrouter], @ip, @mask, i).strip == ''

        current.sort.reverse.each do |c|
          cli('vrouter-interface-remove', 'vrouter-name', resource[:vrouter],
              'nic', c.split('%')[1].strip)
        end
      end

      if cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
             resource[:vrouter], 'nic',
             @H.get_nic(1, resource[:vrouter], @ip, @mask, i), @H.q) == ''

        cli(*@H.splat_switch, 'vrouter-interface-add',
            'vrouter-name', resource[:vrouter], 'ip', interface_ip,
            'vlan', i, 'if', 'data')

        if @vrrp
          vrrp_ip = @H.build_ip(1, @vrrp_ip, @vrrp_mask, i)
          if cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
                 resource[:vrouter], 'nic',
                 @H.get_nic(1, resource[:vrouter], @vrrp_ip, @mask, i),
                 @H.q) == ''

            cli(*@H.splat_switch, 'vrouter-interface-add',
                'vrouter-name', resource[:vrouter], 'ip', vrrp_ip,
                'vlan', i, 'if', 'data', 'vrrp-id', @vrrp_hw_id,
                'vrrp-primary', build_vrrp_primary(i),
                'vrrp-priority', resource[:vrrp_priority])

          else

            interfaces = cli(*@H.splat_switch, 'vrouter-interface-show',
                             'vrouter-name', resource[:vrouter],
                             'ip', vrrp_ip, @H.pdq, 'format', 'ip').split("\n")

            @exists = false
            interfaces.each do |j|
              if j.split('%')[1] == vrrp_ip
                @exists = true
              end
            end

            unless @exists
              cli(*@H.splat_switch, 'vrouter-interface-add',
                  'vrouter-name', resource[:vrouter], 'ip', vrrp_ip,
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
      interface_ip = @H.build_ip(1, @ip, @mask, i)

      out = cli(*@H.splat_switch, 'vrouter-interface-show', 'vrouter-name',
                resource[:vrouter], 'ip', interface_ip, 'format', 'nic',
                @H.pdq).split("\n")

      out.each do |o|
        nics.push(o.split('%')[1].strip)
      end
      nics.sort.reverse.each do |n|

        cli(*@H.splat_switch, 'vrouter-interface-remove', 'vrouter-name',
            resource[:vrouter], 'nic', n)

      end
    end
  end

  def vrouter
    resource[:vrouter]
  end

  def switch
    resource[:switch]
  end

  def vrrp_ip
    if @vrrp

      @ids.each do |i|
        interfaces = cli(*@H.splat_switch, 'vrouter-interface-show',
                         'vrouter-name', resource[:vrouter],
                         'ip', @H.build_ip(1, @ip, @mask, i),
                         'format', 'ip,netmask,nic,vrrp-id', @H.pdq).split("\n")

        interfaces.each do |j|
          vr, ip, nm, ni, vi = j.split('%')

          unless vi.nil? or vi.strip == ''
            ip = ip + '/' + nm
            unless ip == @H.build_ip(1, @vrrp_ip, @mask, i)
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

        out = cli(*@H.splat_switch, 'vrouter-interface-show',
                  'vrouter-name', resource[:vrouter],
                  'nic', @H.get_nic(1, resource[:vrouter], @vrrp_ip, @mask, i),
                  'format', 'vrrp-priority', @H.pdq).split('%')[1]

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

      cli(*@H.splat_switch, 'vrouter-interface-show',
          'vrouter-name', resource[:vrouter], 'nic',
          @H.get_nic(1, resource[:vrouter], @vrrp_ip, @mask, i),
          'vrrp-priority', value.to_i.to_s.strip)

    end
  end

end