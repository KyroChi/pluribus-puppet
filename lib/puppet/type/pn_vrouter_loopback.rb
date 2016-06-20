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

Puppet::Type.newtype(:pn_vrouter_loopback) do

  ensurable

  newparam(:name) do
    validate do |d|
      vrouter, ip, overflow = d.split ' '
      if vrouter =~ /[^\w.:-]/
        raise ArgumentError, 'vRouter name can only contain letters, numbers,' +
            ' _, ., :, and -'
      end
      if ip !~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
        raise ArgumentError, 'Name must include an ip'
      end
      if overflow
        raise ArgumentError, 'Too many arguments'
      end
    end
  end

  newproperty(:switch) do
    defaultto('local')
  end

end