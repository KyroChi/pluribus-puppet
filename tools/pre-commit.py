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

# This script runs through the entire system and check things like line lengths

class color:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

ROOT = '..'

################################################################################
# Ignore Directories and Specific Files
################################################################################

# No error check for escaped slashes, escape them yourself please :)
IGNORE_DIR = [ROOT + '\/doc', ROOT + '\/.git', ROOT + '\/.idea',
              ROOT + '\/spec']
IGNORE_FILES = ['../README.md',
                '../examples/pn_vrouter_vrrp/pn_vrouter_many_vrrps_' + # lol
                'test_manifest_01.pp', '../examples/ex_vlag_vrouter_setups.pp',
                '../LICENSE', '../metadata.json', '../README2.md',
                '../.gitignore']
IGNORE = '('

for r in IGNORE_DIR:
    IGNORE += "(%s)" % (r)
    if r != IGNORE_DIR[-1]:
        IGNORE += '|'
IGNORE += ')'

checkIgnore = re.compile(r'%s' % IGNORE)

################################################################################
# License Header File Location
################################################################################

HEADER = open('header_LICENSE').read().split("\n")

################################################################################
# Walk through and preform the checks
################################################################################

fails = 0
for root, subdirs, files in os.walk(ROOT):
    if checkIgnore.search(root) is not None:
        continue
    else:
        for f in files:
            if root + '/' + f in IGNORE_FILES:
                continue

            contents = open(root + '/' + f).read().split("\n")

            ####################################################################
            # Check Line Lengths
            ####################################################################

            linenum = 1
            for line in contents:
                if len(line) > 80:
                    print "%s " %  (root + '/' + color.BLUE + f + color.ENDC)\
                          + "at line %s is" % (color.WARNING + str(linenum)
                                               + color.ENDC) \
                          + color.FAIL + " %s " % (str(len(line))) \
                          + color.ENDC +  "characters long"
                    fails += 1
                linenum += 1

            ####################################################################
            # Check License and change if needed.
            ####################################################################

            lines = []
            comment = re.compile('^#')
            header = True
            for line in contents:
                if comment.search(line) is None:
                    header = False
                if not header:
                    lines.append(line)

            file = open(root + '/' + f, 'w')
            for l in HEADER + lines:
                file.write(l + "\n")



if fails == 0:
    print color.GREEN + "All checks passed" + color.ENDC

