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

Facter.add(:present_clusters) do
  setcode do

  end
end

Facter.add(:present_vrouter_interface) do

end

Facter.add(:present_vrouter) do
  setcode do
  end
end

Facter.add(:avaliable_vnets) do
  setcode do
    vnets = Facter::Core::Execution.exec(
      'cli vnet-show format name parsable-delim %').split("\n")
    vnets
  end
end

Facter.add(:reachable_switches) do
  setcode do
    switches = Facter::Core::Execution.exec(
      'cli fabric-node-show format name parsable-delim %').split("\n")
    switches << 'local'
    switches
  end
end
