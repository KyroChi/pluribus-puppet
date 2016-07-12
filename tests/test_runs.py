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
import datetime
import threading
import itertools
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

# Python > Ruby... need I say more? Enjoy!


class TestRunner:
    """ This object is responsible for running tests on the target system. Spawn
        one test runner for each set of switches under test"""
    # TODO assertion sharing between runners (for regression)
    def __init__(self, switches, debugging=False, logging=True,
                 no_clean_on_exit=False, no_clean_on_entry=False,
                 keep_run=False):
        """
        :param switches: An array of switches to be handled by the TestRunner.
        :param debugging: Boolean, enable or disable debugging to the console.
            This is set to False by default
        :param logging: Boolean, enable or disable logging to the logfile. This
            is set to True by default
        :param no_clean_on_exit: Boolean, when set to True the runner won't
            clean the setup when it finishes all its tests, set this to True if
            you need to examine the state after the Runner finishes.
        :param no_clean_on_entry: Boolean, when set to True test setups will not
            be cleaned when a new test is created. If you want to clean the
            setup with this flag you must call the clean_setup() method
            explicitly.
        :param keep_run: Boolean, if this is set to True the run.pp file will
            not be purged after the tests are done running, this can allow for
            manual debugging after the tests have finished.
        """
        self.assertions = 0
        self.failures = 0
        self.warnings = 0
        self.passes = 0

        self.debugger = debugging
        self.logging = logging
        self.no_clean_on_exit = no_clean_on_exit
        self.no_clean_on_entry = no_clean_on_entry
        self.keep_run = keep_run
        self.switches = switches

        if self.logging:
            self.log_init()

        self.GREEN = '\033[32m'
        self.BLUE = '\033[36m'
        self.RED = '\033[31m'
        self.YELLOW = '\033[33m'
        self.WHITE = '\033[37m'
        self.CLEAR = '\033[0m'

        self.logfile = None
        self.runfile = None

        # include explicit=True when using no_changes
        self.no_changes = [(
            ".*(Notice\: Compiled catalog for .* in "
            "environment production in .* seconds\s*Notice\: Applied catalog in"
            " .* seconds).*"
        )]

    def syscall(self, command='', more=False):
        """ Calls a command on the target system command line.
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
        """ Executes a CLI command and returns the CLI's returned value. This
            method is a wrapper for self.syscall that adds the long cli command
            parts for you.
        :param command: A string command to be executed on the target.
        :param switch: The switch where the CLI command should be executed. If
            this value is '' no switch will be included in the call, if you
            include 'local' it will execute with 'switch-local'. Otherwise it
            will attempt to execute on whatever switch you specified. There is
            no error checking to see if that switch is on the fabric.
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

    def time(self):
        """ Got tired of writing 'datetime.datetime.now().time(). Can't be a
            constant because it would only be assigned once.
        :return: The current time as a string.
        """
        return datetime.datetime.now().time()

    def log_init(self):
        """ Open the logfile and start writing to it.
            Catches IOError and prints an error to console but will not halt
        execution. It will return -1 if unsuccessful so check for that.
        :return: 0 if successful and -1 if failed.
        """
        try:
            self.logfile = open('/var/log/pnpuppettester', "a")
            self.logfile.write("Log stream opened at %s\n" % self.time())
            return 0
        except (OSError, IOError):
            self.logging = False
            self.message('error',
                         'Log file could not be opened, disabling logging')
            return -1

    def log(self, content):
        """ Logs a message to the logfile if logging is enabled.
            Follows the format:

                        [<TIME>] <CONTENT> \n

        :param content: The content to be logged.
        :return:
        """
        if self.logging:
            self.logfile.write("[%s] %s \n" % (self.time(), content))

    def log_close(self):
        """ Closes the log file.
        :return: ---
        """
        self.logfile.close()

    def open_run(self):
        """ Init temp manifest run.
        :return: ---
        """
        self.runfile = open('./' + 'run.pp', "w")

    def close_run(self):
        """ Close the run file.
        :return: ---
        """
        self.runfile.close()

    def write_run(self, content):
        """ Write to the run file.
        :return: ---
        """
        self.open_run()
        for line in content.split("\n"):
            self.runfile.write(line + "\n")

    def purge_run(self):
        """ Remove the run file.
        :return: ---
        """
        if not self.keep_run:
            self.close_run()
            self.syscall('rm ./run.pp')
            self.runfile = False

    def format(self, message, color):
        """ Prints a formatted string with both a timestamp and a Color to the
            console. Follows the format:

                        [<TIME>] <MESSAGE> \n

        :param message: The message to be printed.
        :param color: The color constant of the message.
        """
        print color + "[%s] " % self.time() + message + self.CLEAR

    def message(self, type, content):
        """ Handles messaging to the console and/or logfile.
        :param type: The type of message to be printed.
            debug: prints to the debugger and logs to the logfile
            error: prints an error to the console and logs it to the logfile
            pass: prints in green
            fail: prints in red
            console: prints in the console default
            log: logs message to the logfile
        :param content: The message you want printed or logged
        """
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

    def debug_variables(self, v, e, ex, cmd):
        """ Helper method that is designed specifically to be used in syscall.
            It prints the syscall values to the debugger, Splat the value from
            syscall: self.debug_variables(*syscall).
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

    def clean_setup(self, killall=False):
        """ Cleans out things that are setup by Puppet like vLANs, vRouters,
            ect. After cleaning up the setup you can run tests on a fresh setup.
            You should run this before every set of tests.
        :param killall: Kill the fabric too (not implemented)
        """
        # TODO implement killall
        for switch in self.switches:
            self.message('debug', "%s: Starting cleanup" % switch)

            # Remove vRouters, Don't need to remove vRouter interfaces because
            # they will die when the vRouter is deleted
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

            self.message('debug', "%s: Removing vLANs" % switch)
            present_vlans = self.cli('vlan-show format id', switch)
            if present_vlans:
                vlans = set(present_vlans.split("\n"))
                for vlan in vlans:
                    vlan = re.sub("[^0-9]", "", vlan)
                    if vlan.isdigit() and 4092 > int(vlan) > 2:
                        self.message('debug',
                                     "%s: Removing vlan %s" % (switch, vlan))
                        self.cli("vlan-delete id %s" % vlan, switch,
                                 parsable=False)

            self.message('debug', "%s: Removing vLAGs" % switch)
            present_vlags = self.cli('vlag-show format name')
            if present_vlags:
                vlags = present_vlags.split("\n")
                for vlag in vlags:
                    vlag = re.sub(' ', '', vlag)
                    if vlag != '':
                        self.message('debug',
                                     "%s: Removing vLAG %s" % (switch, vlag))
                        self.cli("vlag-delete name %s" % vlag, switch,
                                 parsable=False)

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
        """ Wipe Puppet off of the switch too, this should be used for testing
            the install script.
        :return: ---
        """
        # TODO IMPLEMENT THIS METHOD
        self.clean_setup()

    def all_matchers(self, test, value='created'):
        """ Parse the .pp and create a matcher for every element in the
            manifest. This method will create a regular expression method for
            the entire file, DO NOT SPECIFY MATCHERS BY HAND, save yourself the
            time and headache and use all_matchers() instead.
            This can be used when creating assert_exec_equals() tests, for
            example:
                t.assert_exec_equals(test, 'desc', t.all_matchers(test))
            This will create all of the assertion matchers for the test.
        :param test: A Test object.
        :param value: The value to be checked, either 'created' or 'removed',
            the default value is 'created'.
        :return: An array of all the matchers for a manifest file
        """
        match_array = []
        matcher = re.compile(r"^(.*)(?= {)", re.M)
        matches = re.findall(matcher, test.manifest)
        for i in range(0, len(matches)):
            pattern = re.compile(re.escape(matches[i]) + r"\s*{\s*\'(.*)\'")
            resources = pattern.findall(test.manifest)
            for r in resources:
                s = ('Notice: /Stage[main]/Main/' +
                     string.capwords(matches[i]) + '[' + r + ']/ensure: ' +
                     value)
                if s not in match_array:
                    match_array.append(s)
        return match_array

    def assertion_init(self, test):
        """ Initializes a new assertion. Does handy things like cleaning the
            setup, incrementing the assertions, and opening the run.pp file for
            writing. You know, stuff that you can't really run tests without.
        :param: test: The test that will be used for the test, needed so that
            you can access the test.manifest property for writing to run.pp.
        :return: ---
        """
        if not self.no_clean_on_entry:
            self.clean_setup()
        self.assertions += 1
        self.write_run(test.manifest)
        self.close_run()

    def assertion_summary(self, name, status, output=False):
        """ Prints out a nice summary of the assertions that were made during
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
            self.passes += 1
            self.message('pass', "'%s' passed" % name)
        else:
            self.failures += 1
            if output:
                self.message('debug', "%s returned: \n%s" %
                             (name, output.rstrip()))
            self.message('fail', "'%s' failed" % name)

    def assert_runs(self, test, name, expect=True):
        """ Assert that the manifest will run on the target. This just checks
            that when Puppet applies a manifest it returns no error codes.
        :param test: The test object being verified.
        :param name: The name of the specific test, shows up when the test is
            run, in the logfile, debugger and the console.
        :param expect: Boolean, is the test expected to pass or fail. True for
            pass, False for fail. Default is True.
        :return: ---
        """
        self.assertion_init(test)
        self.message('debug', "assert_runs expected to %s" %
                     ('pass' if expect else 'fail'))
        (v, e, ex, cmd) = self.syscall(
            'puppet apply --detailed-exitcodes run.pp', more=True)
        if ex != 0 and ex != 2:
            self.message('debug', "assert_runs: fail")
            self.assertion_summary(name, 'fail', e) if expect \
                else self.assertion_summary(test.description, 'pass')
        else:
            self.message('debug', "assert_runs: pass")
            self.assertion_summary(name, 'pass') if expect \
                else self.assertion_summary(name, 'fail', e)

    def assert_exec_equals(self, test, name, assertions, expect=True,
                           strict=False, explicit=False):
        """ Assert that the execution of the manifest returns this string
            runner.assert_exec_equals(test, ['vlan 101-110 ensure: present']).
            Essentially all this method is doing is composing a regular
            expression and comparing it to the output from a system call.
        :param test: A test object to apply the test to.
        :param name: The name of the specific test, shows up when the test is
            run, in the logfile, debugger and the console.
        :param assertions: An array of values that the output should contain.
            The number of output lines specified must match the output to pass.
        :param expect: Boolean, expect True if the test should pass, False if it
            is designed to fail.
        :param strict: This checks the output to see if it matches exactly what
            is passed in assertions. When the regex is composed it will
            concatenate the array elements with '\s' instead of '|' and
            check that there is one match instead of an equal number of matches
            and array elements.
        :param explicit: Boolean, allows you to pass a specific regular
            expression to the method. Setting this to true uses the first
            element of assertions as the regular expression pattern. The
            supplied pattern is not escaped or otherwise modified by the method.
        :return: ---
        """
        self.assertion_init(test)
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

        if (len(matcher.findall(v)) == len(assertions)) or \
                (strict and len(matcher.findall(v)) == 1):
            self.message('debug', "assert_exec_equals: pass")
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

    def assert_state_equals(self, test, assertion):
        """ Assert that the execution of the manifest changed the state
        runner.assert_state_equals(test, 'vlan 101 present')
        :param test: A test object.
        :param assertion: The assertable state. Present or absent
        :return: ---
        """
        # TODO IMPLEMENT THIS METHOD
        self.assertion_summary(test.description, 'fail')

    def end_tests(self):
        """ Run after you run your tests to clean everything up. Destroys the
            temporary run.pp file, cleans the setup and prints a summary of the
            tests that have been run.
        :return: ---
        """
        if self.runfile:
            self.purge_run()
        if not self.no_clean_on_exit:
            self.clean_setup()
        if self.failures:
            self.message('fail', "%i tests failed" % self.failures)
        else:
            self.message('pass', "All tests passed")
        self.message(('fail' if self.failures else 'pass'),
                     "There were %i assertions, %i passes and %i failures." %
                     (self.assertions, self.passes, self.failures))


class Test:
    def __init__(self, description, manifest="node default {}"):
        """ Creates a Test object to be used in conjunction with a TestRunner.
        :param description: Description of the test manifest.
        :param manifest: The manifest (.pp) file that the test will apply.
        """
        self.description = description
        self.manifest = manifest

    def add_manifest_from_file(self, path):
        """ Adds a manifest to the Test object from a file path rather than from
            a string. This is used to load examples as tests.
        :param path: A string, the path to the file to be loaded, no error
            checking so be careful
        :return: ---
        """
        manifest_file = open(path, "r")
        self.manifest = manifest_file.read()
        manifest_file.close()
