Puppet::Type.newtype(:pn_vlan) do

  desc "Manage a VLAN.

  pn_vlan {\"<vlan>\":
    ..attributes..
  }

  Example Usage:

    pn_vlan {\"2000\":
      ensure => present,
      scope => 'local',
      description => \"Description here.\",
      stats => 'enabled',
      ports => [68, 70, 78],
      untagged_ports => [65, 67, 72],
    }"

  ensurable

  newparam(:id, :namevar => true) do
    validate do |value|
      if not value !~ /\D/
        raise ArgumentError, "ID must be a number"
      elsif not value.to_i.between?(2, 4092)
        raise ArgumentError, "ID must be between 2 and 4092"
      end
    end
  end # newparam vlan

  newproperty(:scope) do
    desc "Set the scope of the specified fabric. Must be 'local' or 'fabric'"
    munge do |value|
      value.downcase
    end
    newvalues(:local, :fabric)
  end

  newproperty(:description) do
    desc "Description of the specified fabric"
    validate do |value|
      if value =~ /[^\w,.,:,-]/
        raise ArgumentError, "Description can only contain letters, numbers, _, ., :, and -"
      end
    end
  end

  newproperty(:ports) do
    desc "no whitespace comma seperated ports and port ranges"
  end

end # Puppet::Type.newtype
