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

import re
import sys
import time
import string
import argparse
import datetime
import threading
import itertools
from collections import OrderedDict
from subprocess import call, Popen, PIPE

# Change all this crap to be more cleanly integrated

spinner = itertools.cycle(['[-]', '[/]', '[|]', '[\\]'])


def spin():
    sys.stdout.write('\b\b\b')
    sys.stdout.write(spinner.next())
    sys.stdout.flush()


class Spinner(threading._Timer):
    def run(self):
        while True:
            self.finished.wait(self.interval)
            if self.finished.is_set():
                return
            else:
                self.function(*self.args, **self.kwargs)


class TestRunner:
    """
    This object is responsible for running tests on the target system. Spawn
    one test runner for each set of switches under test.

    For a full guide on this framework look under 'doc/developers.md#testing'

    The TestRunner adds command line arguments to any file using a TestRunner.
    Any option specified on the command line will overwrite the value specified
    in the test file.

        usage: test-name.py [-h] [-d] [-D] [-l] [-k] [-x] [-e]

        optional arguments:
            -h, --help            show this help message and exit
            -d, --debugging       enable debugging
            -D, --detailed-debugging
                                    enable detailed debugging
          -l, --logging         enable logging
          -k, --keep-run        keep the run.pp file after exit
          -x, --no-clean-on-exit
                                turn off test exit cleaning
          -e, --no-clean-on-entry
                                turn off test entry cleaning

    I didn't want to use RSpec-Puppet because it doesn't check state or proper
    execution, only that the manifest compiles. I could RUnit the types and
    providers myself... except that I would have to write a framework that
    generates the resource hashes at runtime and the benefit doesn't seem to
    out-weigh the cost. There is still Beaker testing, but without a dedicated
    setup it doesn't make sense to use Beaker. Beaker is also optimized to run
    for classes and not so much types and providers. ServerSpec was another
    option, and one I may use in the future for state _assertions, however, it
    has a lot of stuff that we won't use and it was going to be easier to write
    my own implementation of ServerSpec and bundle it with its own set of
    _assertions that are directly related to our testing needs. So I present to
    you the TestRunner. Oh ya, I can't forget to mention... Python > Ruby!
    (They should have written Puppet in Python in the first place)
    - Kyle 7/13/16
    """
    def __init__(self, switches, debugging=False, logging=True,
                 no_clean_on_exit=False, no_clean_on_entry=False,
                 keep_run=False, command_line_args=None,
                 detailed_debugging=False):
        """
        :param switches: An array of switches to be handled by the TestRunner.

        :param debugging: Boolean, enable or disable debugging to the console.
        This is set to False by default.

        :param logging: Boolean, enable or disable logging to the _logfile. This
        is set to True by default.

        :param no_clean_on_exit: Boolean, when set to True the runner won't
        clean the setup when it finishes all its tests, set this to True if you
        need to examine the state after the Runner finishes.

        :param no_clean_on_entry: Boolean, when set to True test setups will not
        be cleaned when a new test is created. If you want to clean the setup
        with this flag you must call the clean_setup() method explicitly.

        :param keep_run: Boolean, if this is set to True the run.pp file will
        not be purged after the tests are done running, this can allow for
        manual debugging after the tests have finished.
        """
        self.GREEN = '\033[32m'
        self.BLUE = '\033[36m'
        self.RED = '\033[31m'
        self.YELLOW = '\033[33m'
        self.WHITE = '\033[37m'
        self.CLEAR = '\033[0m'

        self.debugger = debugging
        self.detailed_debugging = detailed_debugging
        self.logging = logging
        self.no_clean_on_exit = no_clean_on_exit
        self.no_clean_on_entry = no_clean_on_entry
        self.keep_run = keep_run
        self.switches = switches

        parser = argparse.ArgumentParser()
        parser.add_argument('-d', '--debugging',
                            help="enable debugging", action="store_true")
        parser.add_argument('-D', '--detailed-debugging',
                            help="enable detailed debugging",
                            action="store_true")
        parser.add_argument('-l', '--logging',
                            help="enable logging", action="store_true")
        parser.add_argument('-k', '--keep-run',
                            help="keep the run.pp file after exit",
                            action="store_true")
        parser.add_argument('-x', '--no-clean-on-exit',
                            help="turn off test exit cleaning",
                            action="store_true")
        parser.add_argument('-e', '--no-clean-on-entry',
                            help="turn off test entry cleaning",
                            action="store_true")
        args = parser.parse_args()

        if args.debugging:
            if not self.debugger:
                self.debugger = not self.debugger

        if args.detailed_debugging:
            if not self.detailed_debugging:
                self.detailed_debugging = not self.detailed_debugging

        if args.logging:
            if not self.logging:
                self.logging = not self.logging

        if args.keep_run:
            if not self.keep_run:
                self.keep_run = not self.keep_run

        if args.no_clean_on_exit:
            if not self.no_clean_on_exit:
                self.no_clean_on_exit = not self.no_clean_on_exit

        if args.no_clean_on_entry:
            if not self.no_clean_on_entry:
                self.no_clean_on_entry = not self.no_clean_on_entry

        self._assertions = 0
        self._failures = 0
        self._warnings = 0
        self._passes = 0

        if self.logging:
            self.log_init()

        self._logfile = None
        self._runfile = None

        # include explicit=True when using no_changes
        self.no_changes = [(
            ".*(Notice\: Compiled catalog for .* in "
            "environment production in .* seconds\s*Notice\: Applied catalog in"
            " .* seconds).*"
        )]

    @staticmethod
    def manifest_from_file(path):
        """
        Returns the contents from a manifest as a string.

        :param path: A string, the path to the file to be loaded, no error
        checking so be careful.

        :return: A string containing the contents from the manifest file
        """
        manifest_file = open(path, "r")
        manifest = manifest_file.read()
        manifest_file.close()

        return manifest

    @staticmethod
    def manifest_array(path):
        """
        Not sure why you would ever need this method, I recommend using
        manifest_hash() instead :P

        Parses a commented manifest and returns an array of manifests. This
        allows a ton of manifests to be declared in a single file and than
        iterated through by a script. Breaks by comment. Look at
        auto_gen_tests() for generating huge amounts of test cases with
        manifest_dict().

        :param path: String path the the manifest to be loaded.

        :return: An array of string representations of the manifest contents.
        """
        manifests = []
        manifest_file = TestRunner.manifest_from_file(path)

        i = 0
        for line in manifest_file.read().split("\n"):

            if re.match('#|\Z', line):
                if len(manifests) < i + 1:
                    continue
                else:
                    i += 1

            elif re.match('^\s*$', line):
                continue

            else:
                if len(manifests) < i + 1:
                    manifests.append(line)
                else:
                    manifests[i] += line

        manifest_file.close()
        return manifests

    @staticmethod
    def collapse_manifest(manifest):
        """
        Collapses manifests by removing newlines and making all spaces one space
        wide. This method collapses along comments. If your comment your
        manifest you may want to parse the manifest prior to collapsing the
        manifest. This method is usually used as a helper method for the
        manifest_dict() method but you may need to use it elsewhere.

        :param manifest: The manifest to be collapsed

        :return: Returns a collapsed string version of the manifest.
        """
        collapser = re.compile('(\n)(?!#|\Z)')
        condensor = re.compile(' +')
        collapsed = condensor.sub(' ', collapser.sub(' ', manifest))

        return collapsed

    @staticmethod
    def manifest_dict(path):
        """
        Parses a commented manifest and sets description as a key and the
        manifest as the value. Allows for the 'walking through tests' logic to
        be specified in a manifest and simply run by the test script.

        :param path: String path the the manifest to be loaded.

        :return: A dictionary containing all of the tests. Keys are the test
        descriptions, and the value is a list containing the value 'PASS' or
        'FAIL' as the first element and the manifest to be applied as a string
        as the second element.

        :note: Because the description is the key, there can only be one test
        with a given name, because of this the intended behavior is that the
        test with the shared description will be the one that gets used. Also
        note that because 'PASS' and 'FAIL' aren't included in the description
        both '# PASS description' and '# FAIL description' will be read as
        'description' and whichever was declared last will over-write previous
        decelerations. Manifest tests will be in the order that they were
        declared.

        Format of test dictionaries:
                    ("..." is the contents of a manifest)
        {
            "description of test1" : ['PASS', "...", <options>],
            "description of test2" : ['FAIL', "...", <options>],
        }

        """
        manifests = OrderedDict()
        manifest_file = open(path, "r")

        passfail = re.compile('^\s*#\s*(PASS|FAIL|SETUP|TEARDOWN)\s*(.*)$')
        options = re.compile('^(\|.*\|\s){0,1}(.*?)(?=\s\S*\s{)')

        manifest = TestRunner.collapse_manifest(manifest_file.read())
        manifest_file.close()

        for line in manifest.split("\n"):

            pass_fail = passfail.match(line)

            if pass_fail:
                the_rest = pass_fail.group(2)

                if pass_fail.group(1) == 'SETUP':
                    manifests['setup'] = the_rest

                else:
                    opts = options.match(the_rest)
                    desc = opts.group(2)
                    the_rest = options.sub('', the_rest)

                    if desc:
                        manifests[desc] = [pass_fail.group(1), the_rest,
                                           opts.group(1) if opts.group(1)
                                           else None]

        return manifests

    @staticmethod
    def all_matchers(manifest):
        """
        Parse the .pp and create a matcher for every element in the manifest.
        This method will create a regular expression method for the entire file,
        DO NOT SPECIFY MATCHERS BY HAND, save yourself the time and headache and
        use all_matchers() instead. This can be used when creating
        assert_exec_equals() tests, for example:
                t.assert_exec_equals(test, 'desc', t.all_matchers(test))
        This will create all of the assertion matchers for the test.

        :param manifest: The manifest you are generating matchers for.

        :return: An array of all the matchers for the manifest.
        """
        match_array = []
        # V group one is the type, group two is the stuff between {}
        find_declerations = re.compile("(\S*)\s{(.*?)}")
        # V group one is name, group two is the ensure value
        resources_info = re.compile(
            "'(.*)'\:.*\sensure\s=>[\s|\']*(.*?)[\']*,|\Z")

        manifest = TestRunner.collapse_manifest(manifest)

        for (type, content) in re.findall(find_declerations, manifest):

            s = 'Notice: /Stage[main]/Main/' + string.capwords(type) + '['

            (name, value) = re.findall(resources_info, content)[0]
            if name is not None and value is not None:
                s += name + ']/ensure: '
                s += 'created' if value == 'present' else 'removed'

            match_array.append(s)

        return match_array

    @staticmethod
    def time():
        """
        Got tired of writing 'datetime.datetime.now().time(). Can't be a
        constant because it would only be assigned once.

        :return: The current time as a string.
        """
        return datetime.datetime.now()

    def log_init(self):
        """
        Open the _logfile and start writing to it. Catches IOError and prints an
        error to console but will not halt execution. It will return -1 if
        unsuccessful so check for that instead.

        :return: 0 if successful and -1 if failed.
        """
        try:
            self._logfile = open('/var/log/pnpuppettester', "a")
            self._logfile.write("Log stream opened at %s\n" % self.time())
            return 0
        except (OSError, IOError):
            self.logging = False
            self.message('error',
                         'Log file could not be opened, disabling logging')
            return -1

    def log(self, content):
        """
        Logs a message to the _logfile if logging is enabled.
        Follows the format: [<TIME>] <CONTENT> \n

        :param content: The content to be logged.

        :return: ---
        """
        if self.logging:
            self._logfile.write("[%s] %s \n" % (self.time(), content))

    def log_close(self):
        """
        Closes the log file.

        :return: ---
        """
        self._logfile.close()

    def open_run(self):
        """
        Init temp manifest run.

        :return: ---
        """
        self._runfile = open('./' + 'run.pp', "w")

    def close_run(self):
        """
        Close the run file.

        :return: ---
        """
        self._runfile.close()

    def write_run(self, content):
        """
        Write to the run file.

        :return: ---
        """
        self.open_run()

        for line in content.split("\n"):
            self._runfile.write(line + "\n")

    def purge_run(self):
        """
        Remove the run file from the host's file system.

        :return: ---
        """
        if not self.keep_run:
            self.close_run()
            self.syscall('rm ./run.pp')
            self._runfile = False

    @staticmethod
    def syscall(command='', more=False):
        """
        Calls a command on the target system command line.

        :param command: A string command to be executed on the target.

        :param more: Boolean, return error with value or not. Default is False.

        :return: The value returned by the system or a tuple of (value, error)
        if error is set to True.
        """
        timer = Spinner(0.1, spin)
        timer.daemon = True
        timer.start()

        output = Popen([command], stdout=PIPE, stderr=PIPE, shell=True,
                       bufsize=-1)
        output.wait()
        timer.cancel()
        sys.stdout.write('\b\b\b')

        (v, e) = output.communicate()
        exit = output.returncode

        if more:
            return v, e, exit, command

        return v

    def cli(self, command='', switch='', parsable=True, more=False):
        """
        Executes a CLI command and returns the CLI's returned value. This
        method is a wrapper for self.syscall that adds the long cli command
        parts for you.

        :param command: A string command to be executed on the target.

        :param switch: The switch where the CLI command should be executed. If
        this value is '' no switch will be included in the call, if you include
        'local' it will execute with 'switch-local'. Otherwise it will attempt
        to execute on whatever switch you specified. There is no error checking
        to see if that switch is on the fabric.

        :param parsable: Boolean, enable parsable delimiter '%'. Default is
        True.

        :param more: Boolean, return error with value or not. Default is False.

        :return: The value returned by the CLI call or a tuple of (value, error)
        if error is set to True.
        """
        cmd = 'cli --quiet '

        if switch != '':
            if switch == 'local':
                cmd = cmd + "switch-local "

            else:
                cmd = cmd + "switch %s " % switch

        cmd = cmd + command

        if parsable:
            cmd = cmd + ' no-show-headers'

        syscall = self.syscall(cmd, more=True)
        self.debug_variables(*syscall)
        return syscall if more else syscall[0]

    def format(self, message, color):
        """
        Prints a formatted string with both a timestamp and a Color to the
        console, following the format: [<TIME>] <MESSAGE> \n

        :param message: The message to be printed.

        :param color: The color constant of the message.

        :return: ---
        """
        print color + "[%s] " % self.time().time() + message + self.CLEAR

    def message(self, type, content):
        """
        Handles messaging to the console and/or _logfile.

        :param type: The type of message to be printed.
            debug: prints to the debugger and logs to the _logfile
            error: prints an error to the console and logs it to the _logfile
            pass: prints in green
            fail: prints in red
            console: prints in the console default
            log: logs message to the _logfile

        :param content: The message you want printed or logged

        :return: ---
        """
        # TODO use an enum or tuple?
        if type == 'debug':
            if self.debugger:
                self.format(content, self.BLUE)

        if type == 'error':
            self.format(content, self.RED)

        if type == 'pass':
            self.format(content, self.GREEN)

        if type == 'fail':
            self.format(content, self.RED)

        if type == 'console':
            self.format(content, self.CLEAR)

        self.log(content)

    def detailed_diagnostics(self, name, expectation, reality, time, error,
                             exit, output, metadata, manifest, command):
        """
        :param name:
        :param expectation:
        :param reality:
        :param time:
        :param error:
        :param exit:
        :param metadata:
        :param manifest:
        :return:
        """
        string ="----------------------------------------------------------" + \
        """-----------------------

Assertion: '%s' took %s seconds to run

Executed command: %s

Expected to pass: %s
Test passed:      %s

Output:
%s
Error:
%s
Exit: %s

Metadata:
    manifest location:
        %s
    manifest dict:
        %s
    options array:
        %s

Manifest:
    %s

""" % (name, time, command, expectation, reality, output, error, exit,
        '', '', '', manifest) + \
        "------------------------------------------------------------------" + \
        "--------------"

        if self.detailed_debugging:
            print string

    def debug_variables(self, v, e, ex, cmd):
        """
        Helper method that is designed specifically to be used in syscall. It
        prints the syscall values to the debugger, Splat the value from syscall:
        self.debug_variables(*syscall).

        :param v: Returned value.

        :param e: Returned error.

        :param ex: Returned exit code.

        :param cmd: Called command.

        :return: ---
        """
        if self.debugger:

            self.message(
                'debug', "cmd %s returned output: %s" % (cmd, v) if
                v and v != '' else "cmd %s returned no output" % cmd
            )

            self.message(
                'debug', "cmd %s returned error: %s" % (cmd, e) if
                e and e != '' else "cmd %s returned no error" % cmd
            )

            self.message(
                'debug', "cmd %s returned exit status: %s" %
                (cmd, ex) if ex and ex != '' else
                "cmd %s returned exit status: 0" % cmd
            )

    def clean_setup(self, killall=False, vrouters=True, vlans=True, vlags=True,
                    trunks=True, clusters=True):
        """
        Cleans out things that are setup by Puppet like vLANs, vRouters, ect.
        After cleaning up the setup you can run tests on a fresh setup. You
        should run this before every set of tests*. *There are a ton of special
        cases where you won't run this before a test.

        :param killall: Kill the fabric too (not implemented)

        :param vrouters: Boolean, clean vrouters if True, don't if False.

        :param vlans: Boolean, clean vlans if True, don't if False.

        :param vlags: Boolean, clean vlags if True, don't if False.

        :param trunks: Boolean, clean trunks if True, don't if False.

        :param clusters: Boolean, clean clusters if True, don't if False.

        :return: ---
        """
        # TODO implement killall
        for switch in self.switches:
            self.message('debug', "%s: Starting cleanup" % switch)

            if vrouters:
                # Remove vRouters, Don't need to remove vRouter interfaces
                # because they will die when the vRouter is deleted
                self.message('debug', "%s: Removing vrouters" % switch)
                present_vrouters = self.cli('vrouter-show format name')
                if present_vrouters:
                    vrouters = present_vrouters.split("\n")
                    for vrouter in vrouters:
                        if vrouter != '':
                            self.message('debug', "%s: Removing vrouter %s" %
                                         (switch, vrouter))
                            self.cli("vrouter-delete name %s" % vrouter,
                                     parsable=False)

            if vlans:
                self.message('debug', "%s: Removing vLANs" % switch)
                present_vlans = self.cli('vlan-show format id', switch)
                if present_vlans:
                    vlans = set(present_vlans.split("\n"))
                    for vlan in vlans:
                        vlan = re.sub("[^0-9]", "", vlan)
                        if vlan.isdigit() and 4092 > int(vlan) > 2:
                            self.message('debug',
                                         "%s: Removing vlan %s" %
                                         (switch, vlan))
                            self.cli("vlan-delete id %s" % vlan, switch,
                                     parsable=False)

            if vlags:
                self.message('debug', "%s: Removing vLAGs" % switch)
                present_vlags = self.cli('vlag-show format name')
                if present_vlags:
                    vlags = present_vlags.split("\n")
                    for vlag in vlags:
                        vlag = re.sub(' ', '', vlag)
                        if vlag != '':
                            self.message('debug',
                                         "%s: Removing vLAG %s" %
                                         (switch, vlag))
                            self.cli("vlag-delete name %s" % vlag, switch,
                                     parsable=False)

            if trunks:
                self.message('debug', "%s: Removing trunks" % switch)
                present_trunks = self.cli('trunk-show format name', switch)
                if present_trunks:
                    trunks = present_trunks.split("\n")
                    for trunk in trunks:
                        trunk = re.sub('[ %]', '', trunk)
                        if trunk != '' and trunk != 'auto-128' and \
                                trunk != 'vxlan-loopback-trunk':
                            self.cli('trunk-delete name %s' % trunk, switch,
                                     parsable=False)

            if clusters:
                self.message('debug', "%s: Removing clusters" % switch)
                present_clusters = self.cli('cluster-show format name', switch)
                if present_clusters:
                    clusters = present_clusters.split("\n")
                    for cluster in clusters:
                        cluster = re.sub(' ', '', cluster)
                        if cluster != '':
                            self.cli('cluster-delete name %s' % cluster,
                                     switch, parsable=False)

            self.message('debug', "Finished cleaning %s" % switch)

    def wipe_puppet(self):
        """
        Wipe Puppet off of the switch too, this should be used for testing the
        install scripts.

        :return: ---
        """
        # TODO IMPLEMENT THIS METHOD
        self.clean_setup()

    def exec_conditions(self, conditions, ignore_failures=False):
        """
        Executes commands without calling for more _assertions, this is
        useful for running tear-down scripts where you may want to set things up
        prior to tearing them down.

        {
            'manifest' : String,
            'syscall' : [
                ['command', False],
                ['command2', False],
                ['command3', False],
            ]
            'clicall' : [['command', ...]],
        }

        :param conditions: A hash containing all of the conditions that should
        be executed.

        :param ignore_failures: Boolean, ignore any failures that occur during
        the application of the conditions. Normally an error will cause the
        script to abort but if this value is True the program will continue to
        run.

        :return: ---
        """
        self.message('debug', "Executing external conditions")

        for key in conditions:

            value = conditions[key]

            if key == 'syscall' or key == 'sys_call' or key == 'sys':
                for command in value:
                    self.syscall(*command)

            if key == 'clicall' or key == 'cli_call' or key == 'cli':
                for command in value:
                    self.cli(*command)

            if key == 'manifest':
                self.write_run(value)
                self.close_run()
                (v, e, ex, cmd) = self.syscall(
                    'puppet apply --detailed-exitcodes run.pp', more=True)
                if ex != 0 and ex != 2:
                    if not ignore_failures:
                        self.message('debug', "V: %s E: %s EX: %s CMD: %s" %
                                     (v, e, ex, cmd))
                        self.message('console', "Condition %s failed" % key)
                        return -1

            else:
                self.message('console', "Condition %s was not recognized" % key)
                return -1

        self.message('debug', "Finished executing external conditions")

        return 0

    def assertion_init(self, manifest):
        """
        Initializes a new assertion. Does handy things like cleaning the setup,
        incrementing the _assertions, and opening the run.pp file for writing.
        You know, stuff that you can't really run tests without.

        :param: test: The test that will be used for the test, needed so that
        you can access the test.manifest property for writing to run.pp.

        :return: ---
        """
        if not self.no_clean_on_entry:
            self.clean_setup()

        self._assertions += 1
        self.write_run(manifest)
        self.close_run()

    def assertion_summary(self, name, status, output=False):
        """
        Prints out a nice summary of the _assertions that were made during
        the test runs. Well, maybe not that nice, prints 'name passed' or
        'name failed'. Pretty simple stuff.

        :param name: The name of the test, usually grabbed with
        'test.description'.

        :param status: 'pass' or 'fail' for if the test, you guessed it, passed
        or failed.

        :param output: The output from the failed command. Pass as a string.

        :return: ---
        """
        if status == 0 or status == 'pass':
            self._passes += 1
            self.message('pass', "'%s' passed" % name)
        else:
            self._failures += 1
            if output:
                self.message('debug', "%s returned: \n%s" %
                             (name, output.rstrip()))
            self.message('fail', "'%s' failed" % name)

    def assert_runs(self, manifest, name, expect=True, pre_conditions=None,
                    post_conditions=None):
        """
        Assert that the manifest will run on the target. This just checks
        that when Puppet applies a manifest it returns no error codes.

        :param manifest: The test object being verified.

        :param name: The name of the specific test, shows up when the test is
        run, in the _logfile, debugger and the console.

        :param expect: Boolean, is the test expected to pass or fail. True for
        pass, False for fail. Default is True.

        :param pre_conditions: A hash containing the pre-conditions to be
        applied to this test. Pre-conditions are run before the assertion is
        initialized. They are the very first piece of code to run.

        :param post_conditions: A hash containing the post-conditions to be
        applied to this test. Post conditions are applied AFTER the assertion
        summary is printed. Post-conditions are the very last thing to be run
        during an assertion.

        :return: ---
        """
        start = self.time()
        actual = False

        if pre_conditions:
            self.exec_conditions(pre_conditions)

        self.assertion_init(manifest)

        self.message('debug', "assert_runs expected to %s" %
                     ('pass' if expect else 'fail'))
        (v, e, ex, cmd) = self.syscall(
            'puppet apply --detailed-exitcodes run.pp', more=True)
        if ex != 0 and ex != 2:
            self.message('debug', "assert_runs: fail")
            self.assertion_summary(name, 'fail', e) if expect \
                else self.assertion_summary(name, 'pass')
        else:
            self.message('debug', "assert_runs: pass")
            actual = True
            self.assertion_summary(name, 'pass') if expect \
                else self.assertion_summary(name, 'fail', e)

        if post_conditions:
            self.exec_conditions(post_conditions)

        end = self.time() - start

        self.detailed_diagnostics(name, expect, actual, end, e, ex, v, '',
                                  manifest, cmd)

    def assert_exec_equals(self, manifest, name, assertions, expect=True,
                           strict=False, explicit=False, pre_conditions=None,
                           post_conditions=None):
        """
        Assert that the execution of the manifest returns this string
        runner.assert_exec_equals(test, ['vlan 101-110 ensure: present']).
        Essentially all this method is doing is composing a regular expression
        and comparing it to the output from a system call.

        :param manifest: A test object to apply the test to.

        :param name: The name of the specific test, shows up when the test is
        run, in the _logfile, debugger and the console.

        :param assertions: An array of values that the output should contain.
        The number of output lines specified must match the output to pass.
        :param expect: Boolean, expect True if the test should pass, False if it
        is designed to fail.

        :param strict: This checks the output to see if it matches exactly what
        is passed in _assertions. When the regex is composed it will concatenate
        the array elements with '\s' instead of '|' and check that there is one
        match instead of an equal number of matches and array elements.

        :param explicit: Boolean, allows you to pass a specific regular
        expression to the method. Setting this to true uses the first element of
        _assertions as the regular expression pattern. The supplied pattern is
        not escaped or otherwise modified by the method.

        :param pre_conditions: A hash containing the pre-conditions to be
        applied to this test. Pre-conditions are run before the assertion is
        initialized. They are the very first piece of code to run.

        :param post_conditions: A hash containing the post-conditions to be
        applied to this test. Post conditions are applied AFTER the assertion
        summary is printed. Post-conditions are the very last thing to be run
        during an assertion.

        :return: ---
        """
        start = self.time()
        actual = False

        if pre_conditions:
            if self.exec_conditions(pre_conditions):
                self.assertion_summary(name, 'fail', "Pre-conditions failed")
                self._assertions += 1
                return

        self.assertion_init(manifest)

        self.message('debug', "assert_exec_equals expected to %s" %
                     ('pass' if expect else 'fail'))

        if explicit:
            pattern = assertions[0]
            matcher = re.compile(pattern)
        else:
            pattern = r".*("
            for i in range(0, len(assertions)):
                pattern += re.escape(assertions[i])
                if i != len(assertions) - 1:
                    pattern += r"\s" if strict else r"|"
            pattern += r").*"
            matcher = re.compile(pattern)

        (v, e, ex, cmd) = self.syscall(
            'puppet apply --detailed-exitcodes run.pp', more=True)

        ansi_escape = re.compile(r'\x1b[^m]*m')
        v = ansi_escape.sub('', v)

        if not (e == '') or (ex != 0 and ex != 2):
            if expect:
                self.assertion_summary(name, 'fail',
                                       "Returned error where none was expected")
            else:
                self.assertion_summary(name, 'pass')

        elif (len(matcher.findall(v)) == len(assertions)) or \
                (strict and len(matcher.findall(v)) == 1):
            self.message('debug', "assert_exec_equals: pass")
            actual = True
            self.assertion_summary(name, 'pass') if expect \
                else self.assertion_summary(name, 'fail', v +
                                            "\n matches:\n%s" %
                                            matcher.pattern)
        else:
            self.message('debug', "assert_exec_equals: fail")
            self.assertion_summary(name, 'fail', v +
                                   "\n doesn't match:\n%s" % 
                                   matcher.pattern) if expect \
                else self.assertion_summary(name, 'pass')

        if post_conditions:
            self.exec_conditions(post_conditions)

        end = self.time() - start

        self.detailed_diagnostics(name, expect, actual, end, e, ex, v, '',
                                  manifest, cmd)

    def assert_state_equals(self, manifest, assertion, expect=True):
        """
        Assert that the execution of the manifest changed the state
        runner.assert_state_equals(test, 'vlan 101 present')

        :param manifest: A test object.

        :param assertion: The assertable state. Present or absent

        :return: ---
        """

        # TODO IMPLEMENT THIS METHOD

        pass

    def auto_gen_tests(self, manifests_dict=None, path=None, idempotency=True,
                       preconditions=None, postconditions=None,
                       pre_cleaning=False, post_cleaning=False):
        """
        Automatically generate and run tests based off of the contents of a
        manifest file. While generating tests, auto_gen_test will create a test
        for the manifest AND an idempotency test as well. There is no need to
        explicitly specify idempotency tests unless the flag is set to False.

        :param manifests_dict: A dictionary containing all of the tests to be
        preformed. It is recommended that you use the method tr.manifest_dict()
        to generate the test dictionary that will be passed to the method. See
        manifest_dict() for more on test dictionary formatting. If a path and a
        manifest dictionary are supplied the manifest at the path will override
        the supplied dictionary.

        :param path: Path to a manifest. If this is specified it will override a
        supplied manifest dictionary.

        :param idempotency: Boolean, enable or disable idempotency testing.

        :param preconditions: A pre-conditions hash to be passed to the tests.
        These behave in the exact same way that they do on a normal test.

        :param postconditions: A post-conditions hash to be passed to the tests.
        These behave in the exact same way that they do on a normal test.

        :param pre_cleaning: Boolean, enable or disable pre-cleaning for the
        tests, this value will not change the TestRunner's pre_cleaning value.
        Non auto-generated tests are un-affected by this parameter. You can have
        cleaning for specific tests while this is False or visa versa by
        specifying test options in the manifest file.

        :param post_cleaning: Boolean, enable or disable post-cleaning for the
        tests. This value does not change the TestRunner's post_cleaning value.
        Non auto-generated tests are un-affected by this parameter. You can have
        cleaning for specific tests while this is False or visa versa by
        specifying test options in the manifest file.

        :return: ---
        """
        if path:
            manifests_hash = TestRunner.manifest_dict(path)
        elif manifests_dict:
            manifests_hash = manifests_dict
        else:
            raise ArgumentError('Must specify either a path or dictionary')

        no_clean_on_entry = self.no_clean_on_entry
        no_clean_on_exit = self.no_clean_on_exit

        self.no_clean_on_entry = not pre_cleaning
        self.no_clean_on_exit = not post_cleaning

        for key in manifests_hash:

            if key == 'setup':
                if not preconditions:
                    preconditions = {}

                manifest = self.populate_switches(manifests_hash[key])
                preconditions['manifest'] = manifest
                break

        for key in manifests_hash:

            if key != 'setup' and key != 'tear down':

                options = manifests_hash[key][2]

                idempotency_option = idempotency
                matchers_option = 'default'
                pre_conditions = None

                if options is not None:
                    options = re.match(r'^\|(.*)\|', options)
                    options = options.group(1).split(', ')
                    for option in options:
                        idem_opt = re.match('idempotency=(.*)', option)
                        if idem_opt:
                            idempotency_option = idem_opt.group(1)
                            if idempotency_option == 'False':
                                idempotency_option = False
                            else:
                                idempotency_option = True
                        match_opt = re.match('matchers=(.*)', option)
                        if match_opt:
                            matchers_option = match_opt.group(1)
                        pre_clean_opt = re.match('pre-clean=(.*)', option)
                        if pre_clean_opt:
                            if pre_clean_opt.group(1) == 'False':
                                self.no_clean_on_entry = False
                            else:
                                self.no_clean_on_entry = True
                            self.no_clean_on_entry = not pre_cleaning
                        post_clean_opt = re.match('post-clean=(.*)', option)
                        if post_clean_opt:
                            if post_clean_opt.group(1) == 'False':
                                post_clean = False
                            else:
                                post_clean = True
                            self.no_clean_on_entry = not post_cleaning
                        no_set = re.match('setup=(.*)', option)
                        if no_set:
                            if no_set.group(1) == 'False':
                                pre_conditions = {}

                if pre_conditions is None:
                    pre_conditions = preconditions

                expect = True if manifests_hash[key][0] == 'PASS' else False
                manifest = manifests_hash[key][1]

                manifest = self.populate_switches(manifest)

                explicit = False

                if matchers_option == 'default':
                    matchers = TestRunner.all_matchers(manifest)
                elif matchers_option == 'none' or matchers_option == 'None':
                    matchers = self.no_changes
                    explicit = True
                else:
                    matchers = [matchers_option]

                self.assert_exec_equals(manifest, key,
                                        matchers, expect=expect,
                                        explicit=explicit,
                                        pre_conditions=pre_conditions,
                                        post_conditions=postconditions)

                if idempotency and idempotency_option:
                    self.no_clean_on_entry = True
                    self.assert_exec_equals(manifest, key + " idempotency",
                                            self.no_changes, explicit=True,
                                            expect=expect,
                                            pre_conditions=pre_conditions,
                                            post_conditions=postconditions)

                # self.assert_state_equals(expect, '')

        self.no_clean_on_entry = no_clean_on_entry
        self.no_clean_on_exit = no_clean_on_exit

    def end_tests(self):
        """
        Run after you run your tests to clean everything up. Destroys the
        temporary run.pp file, cleans the setup and prints a summary of the
        tests that have been run.

        :return: ---
        """
        if self._runfile:
            self.purge_run()

        if not self.no_clean_on_exit:
            self.clean_setup()

        if self._failures:
            self.message('fail', "%i tests failed" % self._failures)

        else:
            self.message('pass', "All tests passed")

        self.message(('fail' if self._failures else 'pass'),
                     "There were %i assertions, %i passes and %i failures." %
                     (self._assertions, self._passes, self._failures))

    def populate_switches(self, manifest):
        """
        Populate a manifest with the Runner's switches so that variables may be
        used in manifest files. $SWITCH1 and $SWITCH2 are replaced.

        :param manifest: The string manifest to be populated.

        :return: The populated string.
        """
        switch1, switch2 = self.switches[0], self.switches[1]

        first = re.compile('(\$SWITCH1)|(\$switch1)')
        second = re.compile('(\$SWITCH2)|(\$switch2)')

        manifest = first.sub("'%s'" % switch1, manifest)

        return second.sub("'%s'" % switch2, manifest)


class Test:
    def __init__(self, description, manifest="node default {}"):
        """
        Creates a Test object to be used in conjunction with a TestRunner.

        :param description: Description of the test manifest.

        :param manifest: The manifest (.pp) file that the test will apply.

        :return: ---
        """
        self.description = description
        self.manifest = manifest

    def add_manifest_from_file(self, path):
        """
        Adds a manifest to the Test object from a file path rather than from a
        string. This is used to load examples as tests.

        :param path: A string, the path to the file to be loaded, no error
        checking so be careful.

        :return: ---
        """
        manifest_file = open(path, "r")
        self.manifest = manifest_file.read()
        manifest_file.close()
