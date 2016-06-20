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

Puppet::Type.type(:pn_vrouter_loopback).provide(:netvisor) do

  commands :cli => 'cli'

  def exists?
    @H = PuppetX::Pluribus::PnHelper.new(resource)

    @vrouter, @ip, @index = resource[:name].split ' '
    loopbacks = cli(*@H.splat_switch, 'vrouter-loopback-interface-show',
        'format', 'ip,index', *@H.pdq).split "\n"
    loopbacks.each do |l|
      v, i, x = l.split '%'
      if v.strip == @vrouter and i.strip == @ip
        @index = x
        return true
      end
    end
    false
  end

  def create
    cli(*@H.splat_switch, 'vrouter-loopback-interface-add',
        'vrouter-name', @vrouter, 'ip', @ip, @H.q)
  end

  def destroy
    cli(*@H.splat_switch, 'vrouter-loopback-interface-remove',
        'vrouter-name', @vrouter, 'index', @index)
  end

  def switch
    resource[:switch]
  end

end