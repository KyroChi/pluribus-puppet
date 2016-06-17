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

  def get_bgp_info(format)
    out = cli('--quiet', *@H.splat_switch, 'vrouter-bgp-show',
              'vrouter-name', resource[:vrouter],
              'neighbor', resource[:ip],'format', format,
              'no-show-headers', 'parsable-delim', '%').split('%')
    if out[1]
      out[1].strip
    end
    out[0]
  end

  def exists?
    @H = PuppetX::Pluribus::PnHelper.new(resource)
    if cli('--quiet', *@H.splat_switch, 'vrouter-bgp-show',
              'vrouter-name', resource[:vrouter],
              'neighbor', resource[:ip]) != ''
      return true
    end
    false
  end

  def create
    cli('--quiet', *@H.splat_switch, 'vrouter-bgp-add',
        'vrouter-name', resource[:vrouter], 'neighbor', resource[:ip],
        'remote-as', resource[:bgp_as])
  end

  def destroy
    cli('--quiet', *@H.splat_switch, 'vrouter-bgp-remove',
        'vrouter-name', resource[:vrouter], 'neighbor', resource[:ip])
  end

  def switch
    resource[:switch]
  end

  def vrouter
    resource[:vrouter]
  end

  def ip
    resource[:ip]
  end

  def bgp_as
    get_bgp_info('remote-as')
  end

  def bgp_as=(value)
    cli('--quiet', *@H.splat_switch, 'vrouter-bgp-modify',
        'vrouter-name', resource[:vrouter], 'neighbor', resource[:ip],
        'remote-as', value)
  end

end
