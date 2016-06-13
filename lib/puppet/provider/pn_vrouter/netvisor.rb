# Copyright (C) 2016 Pluribus Networks
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Puppet::Type.type(:pn_vrouter).provide(:netvisor) do

  # Don't pre-fetch as there are too many instances to query and they are not
  # guaranteed to have unique identifiers across nodes.

  desc 'Provider: Netvisor'

  commands :cli => 'cli'

  # def self.getvrouters
  #   vrouters = cli('--quiet', 'vrouter-show', 'format', 'name,',
  #                  'no-show-headers').split("\n")
  #   vrouters.each do |v|
  #     v.strip!
  #   end
  #   vrouters
  # end
  #
  # def self.instances
  #   vrouters = []
  #   getvrouters.each do |v|
  #     vrouters.push(v)
  #   end
  #   vrouters
  # end
  #
  # def self.prefetch(resources)
  #   vrouters = instances
  #   vrouters.each do |name|
  #     provider = vrouters.find { |v| v == name }
  #     resources[name].provider = provider unless provider.nil?
  #   end
  # end

  #
  # Chomps and strip!s output before returning it.
  # @return: A string containing the requested information.
  #
  def get_vrouter_info(format, name="#{resource[:name]}")
    cli('--quiet', 'vrouter-show', 'name', name, 'format', format,
        'no-show-headers').strip
  end

  #
  #
  def exists?
    # check that the vnet is correct
    if get_vrouter_info('name') != ''
      return true
    end
    false
  end

  #
  #
  def create
    cli('--quiet', 'vrouter-create', 'name', resource[:name], 'vnet',
        resource[:vnet], 'hw-vrrp-id', resource[:hw_vrrp_id],
        resource[:service])
  end

  #
  #
  def destroy
    cli('--quiet', 'vrouter-delete', 'name', resource[:name])
  end

  def vnet
    get_vrouter_info('vnet')
  end

  def vnet=(value)

  end

  def hw_vrrp_id
    get_vrouter_info('hw-vrrp-id')
  end

  def hw_vrrp_ip=(value)
    destroy
    create
  end

  def service
    if get_vrouter_info('state') == 'enabled'
      return :enable
    end
    return :disable
  end

  def service=(value)
    cli('--quiet', 'vrouter-modify', 'name', resource[:name], value)
  end

end
