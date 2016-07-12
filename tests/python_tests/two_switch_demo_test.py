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

SWITCH1 = 'charmander.pluribusnetworks.com'
SWITCH2 = 'squirtle.pluribusnetworks.com'

set_up_test = Test('Set Up Tester')
set_up_test.add_manifest_from_file(
    '../../examples/demo_manifests/two_switch_demo_set_up.pp'
)

tear_down_test = Test('Tear Down Tester')
tear_down_test.add_manifest_from_file(
    '../../examples/demo_manifests/two_switch_demo_tear_down.pp'
)

test = TestRunner([SWITCH1, SWITCH2], debugging=False, logging=False,
                  no_clean_on_entry=True)

# test.clean_setup()
# test.assert_runs(set_up_test, 'set_up manifest can be applied')
test.clean_setup()
test.assert_exec_equals(set_up_test, 'set_up manifest applies correctly',
                        test.all_matchers(set_up_test))
test.assert_exec_equals(set_up_test, 'set_ip idempotency', test.no_changes,
                        explicit=True)

test.clean_setup()
test.assert_runs(set_up_test, 'apply set_up manifest')
test.assert_runs(tear_down_test, 'tear_down manifest can be applied')
test.clean_setup()
test.assert_runs(set_up_test, 'apply set_up manifest')
test.assert_exec_equals(set_up_test, 'tear_down manifest applies correctly',
                        test.all_matchers(tear_down_test), 'removed')
test.assert_exec_equals(set_up_test, 'tear_down idempotency', test.no_changes,
                        explicit=True)

test.end_tests()