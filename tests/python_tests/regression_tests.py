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

import sys
sys.path.append('../')
from test_runs import TestRunner as tr, Test

import cluster_tests
import lag_tests
import vlan_tests
import vlag_tests
import vrouter_bgp_tests
import vrouter_interface_tests
import two_switch_demo_test
import vrouter_ospf_tests

def tests(runner):
    cluster_tests.tests_two_nodes(runner)
    lag_tests.tests_two_nodes(runner)
    vlan_tests.tests(runner)
    vlag_tests.tests_two_nodes(runner)
    vrouter_bgp_tests.tests_two_nodes(runner)
    vrouter_interface_tests.tests_two_nodes(runner)
    vrouter_ospf_tests.tests_two_nodes(runner)
    two_switch_demo_test.tests(runner)

# Run these before you push changes :)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == '4':
        SWITCH1 = 'charmander'
        SWITCH2 = 'squirtle'
        SWITCH3 = 'gyarados'
        SWITCH4 = 'lapras'
        SWITCH5 = 'pikachu'
        SWITCH6 = 'jigglypuff'
        runner = TestRunner([SWITCH1, SWITCH2, SWITCH3, SWITCH4],
                            debugging=True, logging=False,
                            no_clean_on_entry=True)
        tests_four_nodes(runner)
        runner.end_tests()
    else:
        SWITCH1 = 'charmander'
        SWITCH2 = 'squirtle'
        runner = tr([SWITCH1, SWITCH2], debugging=False, logging=False,
                        no_clean_on_entry=True)
        tests(runner)
        runner.end_tests()
