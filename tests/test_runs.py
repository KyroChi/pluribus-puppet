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

import os
import re
from subprocess import call

def puppet_run(manifest=[]):
    o = open('./' + 'run.pp', "w")
    for l in manifest:
        o.write(l + "\n")

    print 'STARTING RUN'

    o = open('./' + 'run.pp', "r")
    print o.read()

    call(['puppet', 'apply',
          '/etc/puppet/modules/pn-puppet-module/tests/run.pp'])

    o.close()

    print ""

def all_runs():
    for f in os.listdir('./runs/'):
        o = open('./runs/' + f, 'r')
        run = []
        for l in o.read().split("\n"):
            if re.match('#', l):
                if len(run) != 0:
                    puppet_run(run)
                run = []
            elif re.match('^$', l):
                continue
            else:
                run.append(l)

        o.close()

all_runs()