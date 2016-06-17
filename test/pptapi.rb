module Pptapi

  class Ppt

    QUIET = " --quiet"
    DELIM = " parsable-delim %"
    HEAD = " no-show-headers"
    FORMAT = QUIET + DELIM + HEAD

    @failures
    @passes

    def initialize()
      @failures = []
      @passes = []
    end

    #
    #
    def self.get__state(resource_type, identifier, resource_name, format,
                  list_element=0)
      cmd = "cli --quiet #{resource_type}-show #{identifier} #{resource_name} " +
          "format #{format} no-show-headers parsable-delim %"
      state = `#{cmd}`.split('%')[list_element].strip
    end

    def self.get_state(resource_type)
      state_hash = {}
      cmd = "cli #{resource_type}-show format all"
      properties = `#{cmd + QUIET}`.split("\n")[0].split(' ')
      state = `#{cmd + FORMAT}`.split("\n")
      (0..state.length - 1).each do |i|
        props = state[i].split('%')
        state_hash[i] = {}
        (0..properties.length - 1).each do |p|
          state_hash[i][properties[p]] = props[p]
        end
      end
      state_hash
    end

    #
    #
    def self.assert_equals(resource_hash, value_hash,
                      skip_extra_resource=0, skip_extra_value=0)

    end

    def self.assert_exists(target_resource, queried_resources,
        ignore_quried_extras=1)
      target_resource.keys.each do |k|
        queried_resources.keys.each do |j|
          queried_resources[j].keys.each do |l|

            if ignore_quried_extras != 0
              unless target_resource[k][l].nil?
                if target_resource[k][l] != queried_resources[j][l]

                end
              end
            else
              if target_resource[k][l].nil?
                @failures.append("Failure")
              end
            end

          end
        end
      end
      puts target_resource.keys
      puts queried_resources.keys
    end

  end

  # v = {
  #     1 => {
  #         switch => '',
  #         id => '',
  #         scope => '',
  #         description => '',
  #         active => '',
  #         stats => '',
  #         vrg => '',
  #         ports => '',
  #         untagged_ports => '',
  #         send_ports => '',
  #         active_edge_ports => '',
  #     }
  # }
  Ppt.new
  # h1 = {
  #     a => '1',
  #     b => '2'
  # }
  # h2 = {
  #     a => '1',
  #     b => '2'
  # }
  #Ppt.assert_equals(h1, h2)
  Ppt.assert_exists({}, Ppt.get_state('vlan'))

end