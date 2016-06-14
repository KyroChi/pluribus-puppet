# Copyright (C) 2016 Pluribus Networks
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

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
# No error check for escaped slashes, escape them yourself please :)
IGNORE_DIR = [ROOT + '\/doc', '..\/.git', ROOT + '\/.idea']
IGNORE_FILES = ['../README.md',
                '../examples/pn_vrouter_vrrp/pn_vrouter_many_vrrps_' + # lol
                'test_manifest_01.pp']
IGNORE = '('
for r in IGNORE_DIR:
    IGNORE += "(%s)" % (r)
    if r != IGNORE_DIR[-1]:
        IGNORE += '|'
IGNORE += ')'

checkIgnore = re.compile(r'%s' % IGNORE)

for root, subdirs, files in os.walk(ROOT):
    if checkIgnore.search(root) is not None:
        continue
    else:
        for f in files:
            if root + '/' + f in IGNORE_FILES:
                continue
            contents = open(root + '/' + f).read().split("\n")

            # Check for line lengths
            linenum = 1
            for line in contents:
                if len(line) > 80:
                    print "%s " %  (root + '/' + color.BLUE + f + color.ENDC)\
                          + "at line %s is" % (color.WARNING + str(linenum)
                                               + color.ENDC) \
                          + color.FAIL + " %s " % (str(len(line))) \
                          + color.ENDC +  "characters long"
                linenum += 1