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

Facter.add(:lldp) do

  setcode do
    hash = {}
    lldp = Facter::Core::Execution.exec(
      'cli --quiet lldp-show format switch,sys-name,local-port parsable-delim %')
    lldp = lldp.split("\n")

    lldp.each do |connection|
      connection = connection.split('%')
      unless hash.has_key? connection[0]
        hash["#{connection[0]}"] = {}
      end
      unless hash["#{connection[0]}"].has_key? connection[1]
        hash["#{connection[0]}"]["#{connection[1]}"] = []
      end
      hash["#{connection[0]}"]["#{connection[1]}"] << connection[2]
    end
    hash
  end

end
