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

require File.expand_path(
          File.join(File.dirname(__FILE__),
                    '..', '..', 'puppet_x', 'pn', 'type_helper.rb'))

include PuppetX::Pluribus::TypeHelper


Puppet::Type.newtype(:pn_command) do

  @doc = "Executes arbitrary CLI commands when the manifest is applied to the
target node. This resource type should be used with caution as its very
existance is cause for some alarm. Because this has no error checking, the
command given to it will be passed verbatium to the CLI. This means any errors
in syntax will not be caught except by the CLI at runtime. This resource always
returns `False` on its existance, meaning if it is ensured `present` it will
execute the command **EVERY** time the catalog is applied, meaning there is no
idempotency for this resource.

The recommended alternative to using this command is to manually type the CLI
commands into the CLI. This ensures that the commands are not executed too often,
and allows a greater degree of control over the use of command, and you will have
access to the error checking that is provided by the CLI.

#### Properties

name is the command that will be run on the target node.

ensure specifes if the command should be applied or not whenthe manifest is
applied.

switch specifies the switch where the command will be executed.

Example:
```
node your-pluribus-switch {

    pn_command { 'lldp-show':
        ensure => present,
    }

}
```
"

  ensurable
  switch()

  newparam(:name) do
    desc 'Name of the command that will be sent to the CLI'
  end

end
