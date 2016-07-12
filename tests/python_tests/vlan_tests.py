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

SWITCH2 = 'squirtle.pluribusnetworks.com'

vlan_set_up_test = Test('vlan set up test')
vlan_set_up_test.add_manifest_from_file(
    '../../examples/pn_vlan/pn_vlan_set_up.pp'
)

vlan_tear_down_test = Test('vlan tear down test')
vlan_tear_down_test.add_manifest_from_file(
    '../../examples/pn_vlan/pn_vlan_tear_down.pp'
)

vlan_fail_test1 = Test('vlan bad name test', """pn_vlan { 'bad name':
ensure => present,
}""")
vlan_fail_test2 = Test('vlan bad description test', """pn_vlan { '123':
ensure => present, description => 'no spaces ', scope => local,
}""")
vlan_fail_test3 = Test('vlan bad description test', """pn_vlan { '123':
ensure => present, description => '-', scope => farbrick,
}""")
vlan_fail_test4 = Test('vlan bad description test', """pn_vlan { '123':
ensure => present, description => '-', scope => fabric, ports => 'letters',
}""")

test_runner = TestRunner([SWITCH2], debugging=False, logging=False,
                         no_clean_on_entry=True)
test_runner.clean_setup()

test_runner.assert_exec_equals(
    vlan_set_up_test,
    'pn_vlan_set_up.pp manifest applies correctly',
    test_runner.all_matchers(vlan_set_up_test))
test_runner.assert_exec_equals(
    vlan_set_up_test,
    'pn_vlan_set_up idempotency',
    test_runner.no_changes, explicit=True
)


test_runner.clean_setup()

test_runner.assert_runs(vlan_set_up_test, 'pre tear down')
test_runner.assert_exec_equals(
    vlan_tear_down_test,
    'pn_vlan_tear_down.pp manifest applies correctly',
    test_runner.all_matchers(vlan_tear_down_test, 'removed'))
test_runner.assert_exec_equals(
    vlan_tear_down_test,
    'pn_vlan_tear_down idempotency',
    test_runner.no_changes, explicit=True
)

test_runner.assert_runs(vlan_fail_test1, 'vlan bad name', False)
test_runner.assert_runs(vlan_fail_test2, 'vlan bad desc', False)
test_runner.assert_runs(vlan_fail_test3, 'vlan bad scope', False)
test_runner.assert_runs(vlan_fail_test4, 'vlan bad ports', False)

test_runner.end_tests()