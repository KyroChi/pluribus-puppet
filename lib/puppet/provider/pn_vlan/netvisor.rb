Puppet::Type.type(:pn_vlan).provide(:netvisor) do

  commands :cli => 'cli'

  def get_vlan_info(id, format)
    info = Array.new
    info = cli('vlan-show', 'id', id, 'parsable-delim', '%', 'format', format).split("\n")
    info.shift
    info.shift
    info
  end
  
  def self.instances
    # not needed/used
  end

  def self.prefetch(resources)
    # not needed/used
  end
  
  def exists?
    get_vlan_info(resource[:name], 'id').length != 0
  end # exists?

  def scope
    get_vlan_info(resource[:name], 'scope')
  end

  def scope=(value)
    destroy
    create
  end

  def description
    get_vlan_info(resource[:name], 'description')
  end

  def description=(value)
    cli('vlan-modify', 'id', resource[:name], 'description', value)
  end

  def ports
    get_vlan_info(resource[:name], 'ports')
  end

  def ports=(value)
    scope=(value)
  end

  def create
    cli('vlan-create', 'id', resource[:name], 'scope', resource[:scope], 'ports', resource[:ports])
  end # create

  def destroy
    cli('vlan-delete', 'id', resource[:name])
  end # destroy

end # Puppet::Type
