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
         '..', '..', '..', 'puppet_x', 'pn', 'pn_helper.rb'))

Puppet::Type.type(:pn_vrouter_bgp).provide(:netvisor) do

  commands :cli => 'cli'

  def decon_bgp_rng(ip = @i, increment = resource[:increment])
    @range = []
    base = ip.match(/(([\d]{1,3}\.){1,3})/).captures[0]
    ips = ip.match(/([\d\-]*,|[\d\-]*$)/).captures
    ips.each do |i|
      if i.match(/-/)
        lower, upper = i.split('-')
        lower = lower.to_i; upper = upper.to_i
        (lower, upper = upper, lower) if lower > upper
        until upper < lower
          @range.push(base + lower.to_s)
          lower += increment.to_i
        end
      else
        @range.push(base + "#{i}")
      end
    end
  end

  def get_bgp_info(format, i)
    out = cli('--quiet', *@H.splat_switch, 'vrouter-bgp-show',
              'vrouter-name', @v, 'neighbor', i, 'format', format,
              'no-show-headers', 'parsable-delim', '%').split('%')
    if out[1]
      return out[1].strip
    end
    out[0]
  end

  def exists?
    @H = PuppetX::Pluribus::PnHelper.new(resource)
    @v, @i = resource[:name].split ' '
    decon_bgp_rng
    @range.each do |i|
      if cli(@H.q, *@H.splat_switch, 'vrouter-bgp-show',
             'vrouter-name', @v, 'neighbor', i) == ''
        return false
      end
    end
    true
  end

  def create
    @range.each do |i|
      if cli(@H.q, *@H.splat_switch, 'vrouter-bgp-show',
             'vrouter-name', @v, 'neighbor', i) == ''
        cli(@H.q, *@H.splat_switch, 'vrouter-bgp-add',
            'vrouter-name', @v, 'neighbor', i, 'remote-as', resource[:bgp_as])
      end
    end
  end

  def destroy
    @range.each do |i|
      unless cli(@H.q, *@H.splat_switch, 'vrouter-bgp-show',
             'vrouter-name', @v, 'neighbor', i) == ''
        cli(@H.q, *@H.splat_switch, 'vrouter-bgp-remove', 'vrouter-name', @v,
            'neighbor', i)
      end
    end
  end

  def switch
    resource[:switch]
  end

  def bgp_as
    @range.each do |i|
      unless get_bgp_info('remote-as', i) == resource[:bgp_as].to_s
        return "Incorrect BGP AS"
      end
    end
    resource[:bgp_as]
  end

  def bgp_as=(value)
    @range.each do |i|
      cli(@H.q,  *@H.splat_switch, 'vrouter-bgp-modify', 'vrouter-name', @v,
          'neighbor', i, 'remote-as', value)
    end
  end

  def increment
    resource[:increment]
  end

end
