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
from test_runs import TestRunner, Test

def tests_four_nodes(runner):
    runner.clean_setup()

if __name__ == "__main__":
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
