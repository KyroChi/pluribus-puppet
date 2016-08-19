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

node default {  }

#   switch      local-port chassis-id port-id port-desc           sys-name
#   ----------- ---------- ---------- ------- ------------------- -----------
#   onvl-leaf1  49         09000166   49      PN Switch Port(49)  onvl-leaf2
#   onvl-leaf1  50         09000166   50      PN Switch Port(50)  onvl-leaf2
#   onvl-leaf1  52         090000fb   103     PN Switch Port(103) onvl-spine2
#   onvl-spine1 100        090000fb   100     PN Switch Port(100) onvl-spine2
#   onvl-spine1 101        090000fb   101     PN Switch Port(101) onvl-spine2
#   onvl-spine1 103        09000166   52      PN Switch Port(52)  onvl-leaf2
#   onvl-spine2 100        09000159   100     PN Switch Port(100) onvl-spine1
#   onvl-spine2 101        09000159   101     PN Switch Port(101) onvl-spine1
#   onvl-spine2 103        09000167   52      PN Switch Port(52)  onvl-leaf1
#   onvl-leaf2  49         09000167   49      PN Switch Port(49)  onvl-leaf1
#   onvl-leaf2  50         09000167   50      PN Switch Port(50)  onvl-leaf1
#   onvl-leaf2  52         09000159   103     PN Switch Port(103) onvl-spine1

# onvl-spine1, onvl-spine2, onvl-leaf1, onvl-leaf2
# agent running on onvl-spine1?

node onvl-spine1 {

}