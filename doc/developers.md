# Developers

### Table of Contents
1. [Developer Introduction](#introduction)
1. [Installing a Development Puppet Enviroment](#installing-puppet)
1. [The Puppet Module Structure](#module-structure)
1. [Introduction to Ruby](#ruby)
1. [Types and Providers](#types-and-providers)
   - [Types](#types)
   - [Providers](#providers)
1. [git and GitHub](#git-and-github)
   - [Setting up git](#setting-up-git-and-github)
   - [Project git Workflow](#project-git-workflow)
   - [Pushing and Pull Requests](#pushing-and-pull-requests)
   - [Rebasing](#rebasing)
1. [Testing](#testing)
1. [Documenting](#documenting)
1. [Additional Readings](#additional-readings)

## Introduction

This document is for people who are planning on contributing to the Pluribus Puppet module. Whether you work for Pluribus or use our software, or even are just looking for a project to contribute to, this page is for you. The goal for this document is to familiarize you with the source code well enough that you are able to contribute to the project. The Pluribus Puppet module adds functionality that allows features that are configurable from the CLI to be configured and managed from a Puppet manifest. 


## Installing Puppet

The first step in developing any Puppet module is installing Puppet in a way that is friendly to development. The Puppet agents tend to be fairly easy to install but I have found that the master servers are a pain to get up and running. For this reason, I prefer to use the `puppet apply` command to run my code on an agent node rather than trying to get the master to communicate with the agents. Otherwise you can use a testing framework to run your tests on the Puppet agent. Since the manifest commands will only ever be run on the Puppet agent there is no reason to test on a full deployment. For this reason only the agents actually need to be installed on the testing setup. 

## Module Structure

The Pluribus Puppet module follows more or less the project structure outlined by Puppet. If you are unfamiliar with Puppet modules the structure can seem somewhat daunting at first. To get familiar with the structure we will go through all of the important files and folders and explain what they do and the reasons you would be developing within them.

### `./`
The root directory is the directory that you see when you clone into the Pluribus Puppet module. This directory is a sort of home page for the project and includes lots of important files and directories.

1. [`metadata.json`](#metadatajson)
1. [`README.md`](#readmemd)
1. [`LICENSE`](#license)
1. [`doc/`](#doc)
1. [`examples/`](#examples)
1. [`files/`](#files)
1. [`lib/`](#lib)
1. [`manifests/`](#manifests)
1. [`templates/`](#templates)
1. [`tests/`](#tests)
1. [`tools/`](#tools)

#### `metadata.json`
This file contains the module metadata that Puppet Forge uses to publish modules. Fields include the current version, the name of the module, authors, informataion about where the source code is located and some other information fields. If you want to know more about the `metadata.json` file, Puppet has a great summary which can be found [here](https://docs.puppet.com/puppet/latest/reference/modules_metadata.html). 

#### `README.md`
This is the modules main README file, it follows the Puppet module README guide. This file is mainly for non-developer users of Puppet and is designed to walk a user through the process of using the Pluribus Puppet module and also serve as a one stop reference guide for all of the Types that the module adds to the Puppet DSL. The Puppet module README design guide can be found [here](https://docs.puppet.com/puppet/latest/reference/modules_documentation.html).

#### `LICENSE`
This file is simply a container for the abbreviated LICENSE file, this is the same license that gets appended to the headers of source files. This should reflect the current license of the project. We are currenly using the Apache v2 licence in the Pluribus Puppet module. The full version of the project license is located in [`./doc/apache`](#apache).

#### `Gemfile`
This file contains the gems that the module needs to be run. There are not many gem dependancies as Pluribus Puppet is mostly self contained.

#### `.gitignore`
This is a standard gitignore file, if you have never used a `.gitignore` file you can read about them [here](https://git-scm.com/docs/gitignore) and [here](https://help.github.com/articles/ignoring-files/). 

---
### `doc/`
This directory contains documentation like the read-me that you are currently reading (or writing) and files like the full text project license.

1. [`apache`](#apache)
1. [`developers.md`](#developersmd)

#### `apache`
This file contains the full, un-abridged version of the Apache v2 license.

#### `developers.md`
This is the read-me for developers and the file that you are currently reading. This file walks new developers through every step in the development process and get them accoustomed to the Puppet module development environment. This file contains useful information that developers can use to learn the Puppet module infastructure or to use as a reference guide later on in the development process.

---
### `examples/`
The examples directory, un-surprisingly, contains examples of how to use the Pluribus Puppet module, examples are broken up into three groups, Type examples, testbed examples, and demos.

1. [`type/example.pp`](#typeexamplepp)
2. [`testbed/testbed-name/setup.pp`](#testbedtestbed-namesetupteardownpp)
3. [`demos/demo.pp`](#demodemopp)

#### `type/example.pp`
Example files for tests follow the naming convention of `<type-name>/<test-name>.pp`. Each example should show a different aspect of the Type and be commented so that a user can look up the examples folder if they want to see examples of working implementations of the various types. Make sure that an example works on your system before you push it to the Git repository. All of the examples in the examples directory should be well formatted so that the example types look nice and are readable to a user.

#### `testbed/testbed-name/<setup|teardown>.pp`
The files in the testbed folders follow the naming convention `testbed/<testbed-name>/setup.pp` and `testbed/<testbed-name>/teardown.pp`. All testbeds should have both a setup file and a tear down file. These can be used internally to do baseline configurations of test setups so that the tests run on those setups can be consistently monitored and compared. The files in this directory should accurately reflect the current state of the testbed and actually work for setting up the testbed they refer to.

#### `demos/demo.pp`
These files represent internal or customer facing demos designed for specific setups. These should **ALWAYS** work with any current build in the development branch so that if at any time you are asked to do a demo there is a usable demo in the demo folder. **NEVER** push a demo file unless it has been successfully run on a current version of the development branch.

---
### `files/`

---
### `lib/`

1. [`type/type-name.rb`](#typetype-namerb)
2. [`provider/type-name/netvisor.rb`](#providerrypenamenetvisorrb)

#### `type/type-name.rb`
This is where the module types are defined. The Types detail how the various resource declerations can be made in a manifest file. Types provide basic error checking, and can set default values for parameters. The naming convention is to name the type after what it does, with a prefix of `pn`, for example `pn_vlan.rb` or `pn_cluster.rb`. See [Types](#types) for a more detailed guide.

#### `provider/type-name/netvisor.rb`
Providers do the heavy lifting for Puppet, these files actually execute CLI commands on the destination switch and are responsible for controlling how Puppet decides what commands to execute. For a complete guide to Providers see [Providers](#providers).

---
### `manifests/`

1. [`init.pp`](#initpp)
1. [`install.pp`](#installpp)

#### `init.pp`
`init.pp` is a manifest that is loaded and run when the module is first installed by a user.

#### `install.pp`
`install.pp` is a manifest that contains decelerations related to the installation of a module, if a module needed a dependency this is where you would write the decelerations to install that dependency.

---
### `templates/`

1. [`component.epp`](#componentepp)
1. [`component.erb`](#componenterb)

#### `component.epp`

The `.epp` template.

#### `component.erb`
The `.erb` template.

---
### `tests/`

1. [`runs/<type>.pp`](#runstypepp)
1. [`test_runs.py`](#test_runspy)

#### `runs/<type>.pp`
The `runs/` folder contains test runs for each of the types that you are testing. Each test run file will apply a manifest that is between comments as its own manifest. Look at the existing test runs for an example.

#### `test_runs.py`
This script runs a runs file on the switch where the script was called from.

---
### `tools/`
This directory serves as a home for anything that is used to aid in development, but isn't related to Puppet as a service. Examples would include install scripts and scripts to do things like append Licenses to the top of files.

1. [`generate_type_provider_template.sh`](#generate_type_provider_templatesh)
1. [`header_LICENSE`](#header_license)
1. [`pre-commit.py`](#pre-commitpy)

#### `generate_type_provider_template.sh`
This script will generate all of the new files related to creating a new type. (type.rb, type/netvisor.rb, ect.)

#### `header_LICENSE`
This file contains a license that will be appended if `pre-commit` is run with the options to append licenses is turned on.

#### `pre-commit.py`
This script checks things like line lengths and can function as a very simple linter. You can un-comment some lines and have this script append a license to the top of each file.

## Ruby
If you have never used Ruby before, don't worry, they syntax is very friendly and it is an easy language to pick up. Once you understand the various language quirks development in Ruby is fairly painless. From the [Ruby language site](https://www.ruby-lang.org/en/): 

> Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write.

Ruby programmers will be quick to tell you that everything in Ruby is an object, this is true, and Ruby has taken 'object-oriented' to the next level. Every thing, including data types is an object. This has some benefits, like being able to call any method from Ruby's `object` class on a variable, but it can sometimes be confusing. If you don't want to do the [Ruby Codecadmy course](https://www.codecademy.com/learn/ruby) (which will focus on basic programming skills rather than Ruby specific syntax) than I recommend the book [Eloquent Ruby](https://www.amazon.com/Eloquent-Ruby-Addison-Wesley-Professional/dp/0321584104) by Russ Olson, which doesn't bother with basic programming stuff and does a good job of explaining Ruby specific programming features and quirks. Some other good resources for learning Ruby are [Codecademy](https://www.codecademy.com/learn/ruby) and [Ruby in 20 minutes](https://www.ruby-lang.org/en/documentation/quickstart/).

### IDEs
Some good IDEs to look into are [RubyMine](https://www.jetbrains.com/ruby/) or [Emacs](https://www.gnu.org/software/emacs/). I recommend RubyMine because keeping track of all of the types and providers becomes messey to deal with and a heavy GUI IDE like RubyMine makes managing the huge amount of files a breeze. RubyMine has remote file editing capabilities, and integrated markdown rendering with a plugin called 'Markdown Navigator'. It includes syntax high-lighting, code-completions, spacing checkers and a host of other great and useful features to aid in development.

## Types and Providers

At the core of Pluribus Puppet (and indeed most Puppet modules) are files called Types and Providers. The Types are located in `lib/puppet/types/` and are responsible for defining the parameters and properties available to a specific resource type. The Providers are located in `lib/puppet/providers/` and control the actual interaction between Puppet and the Netvisor CLI.

### Types

Types define how resources are defined in Puppet manifests and can do some simple error checking on the various parameters defined by the user. Any error checking that can be preformed by the Type should be preformed by the type, as errors thrown by Types will halt compilation, while errors thrown by the Provider will halt execution. (which is a much less desirable, but sometimes un-avoidable outcome).

Types are defined with `Puppet::Type.newtype(<type-name>)`. Note that `<type-name>` must be a symbol, so a resource like `pn_vlan` is defined with `Puppet::Type.newtype(:pn_vlan)`. Not all types need a namevar, or need to be ensurable, but for Pluribus Puppet we like all of the managed resources to have some sort of unique identifier and be ensurable, even if this complicates the namevar somewhat. To declare a Type is ensurable use the Puppet method `ensurable` and to give the Type a name use `newparam(:name)`. There are other ways to declare a variable as a namevar, however `newparam(:name)` is the preferred method for this module.

Here us a sample bare-bones Type: (For declaring type `sample_type`)
```ruby
Puppet::Type.newtype(:sample_type) do
    ensurable
    newparam(:name) do
    end
end
```

This would not do much in a manifest file, you could declare the type, but it would only have its namevar and the ensure property avaliable to it. Its namevar could be any string because there is no error-checking. A sample declearation in a Puppet manifest for our new type would look something like this:
```puppet
sample_type { 'th1s 1s ! the$%nam3var @ th4t can b3 anyth1ng':
    ensure => present,
}
```

We will talk about Type error checking later on, but first lets add a new property for `sample_type`. Properties can be defined in manifests, error checked, and passed to the Provider as parameters for various operations defined in the Provider. Property declerarions follow the format `newproperty(<property-name>)` where `<property-name>` is a symbol in the same way that the namevar `name` is defined as `:name`. Lets create a sample property for our sample type.
```ruby
Puppet::Type.newtype(:sample_type) do
    ensurable
    newparam(:name) do
    end
    newproperty(:sample_prop) do
    end
end
```

Now we can pass values to the sample type using the `sample_prop` property in the Puppet manifest like so. (Remeber, still no error checking)
```puppet
sample_type { 'th1s 1s ! the$%nam3var @ th4t can b3 anyth1ng':
    ensure      => present,
    sample_prop => 'still no error checking :/',
}
```

This is the stage where we should start doing some error checking. Error checking can be done with the `validate` command and will access the value supplied by the user to check against known values. Normally this is done with regular expressions, but any logic can be written in. If the checking fails, the Type should raise an `ArgumentError`. Here is a fairly common validation on the namevar. Since a lot of CLI commands only accept letters, numbers, _, ., :, and - we use the regular expression `[^\w.:-_]` to check if the value contains illegal values. A simple namevar vaidation following CLI naming rules looks like this:
```ruby
Puppet::Type.newtype(:sample_type) do
    ensurable
    newparam(:name) do
        validate do |value|
            if value =~ /[^\w.:-_]/
                raise ArgumentError, 'Namevar can only contain letters, numbers, ' +
                    '_, ., :, and -'
            end
        end
    end
    newproperty(:sample_prop) do
    end
end
```

There are other forms of validation other than `validate`. If the property can be only one of a few defined values you can use `newvalues`. Lets pretend that the only legal values for `:sample_prop` are `on` and `off`. Lets define `:sample_prop` as only accepting those two values:
```ruby
Puppet::Type.newtype(:sample_type) do
    ensurable
    newparam(:name) do
        validate do |value|
            if value =~ /[^\w.:-_]/
                raise ArgumentError, 'Namevar can only contain letters, numbers, ' +
                    '_, ., :, and -'
            end
        end
    end
    newproperty(:sample_prop) do
        newvalues(:on, :off)
    end
end
```

We have defined the values as symbols but a string would work just as well, however for the purposes of this module we will always define `newvalues` with symbols. This makes it so the possible values are simple enough to be entered as one word. Think of how much better `sample_prop => on` is to the end user than `sample_prop => 'turn on and allow access'`. The new definition of our samle type may look something like this:
```puppet
sample_type { 'legal-name':
    ensure      => present,
    sample_prop => off,
}
```

Types also support defualt values, which can be symbols strings or even numbers. To declare a defualt value for a property use the method `defaultto`. Namevars cannot have a default, only the resource properties can. Lets say that the property `sample_prop` should default to `off`:
```ruby
Puppet::Type.newtype(:sample_type) do
    ensurable
    newparam(:name) do
        validate do |value|
            if value =~ /[^\w.:-_]/
                raise ArgumentError, 'Namevar can only contain letters, numbers, ' +
                    '_, ., :, and -'
            end
        end
    end
    newproperty(:sample_prop) do
        defaultto(:off)
        newvalues(:on, :off)
    end
end
```

Default values can be set to strings, which can be helpful sometimes for declaring a value as being `none` even when the property is something like an IP. For example, in the `pn_vrouter_if` Type (`lib/puppet/type/pn_vrouter_if.rb`) the default is `none` but the expected value is an integer, so in the regular expression conditional we must add an 'out' for the value `none` and handle the actual logic of dealing with the value `none` in the Provider. Here is an excerpt from `lib/puppet/type/pn_vrouter_if.rb`:
```ruby
    ...
    defaultto('none')
    validate do |value|
      unless value =~ /^(2[0-5][0-5]|1[0-9][0-9]|[0-9][0-9]|[0-9])$/ or
          value == 'none'
        raise ArgumentError, 'vrrp_priority must be a number between 0 and 255'
      end
    end
    ...
```

That concludes our introduction to Types, if you want to see more solid examples you are encouraged to look through the source files in `lib/puppet/type/`.

### Providers

While the type defines how the resource is declares, the Provider declares how the resource values will be enforced. Normally providers are used to execute the same resource type accross multiple OS providers (hence why they are called providers). Since Pluribus Puppet only deals with one OS, ONVL with Netvisor (Although the nature of the module does allow for commands to be excecuted in a Solaris environment) we only need one provider per type, called `netvisor.rb`. `netvisor.rb` is located in `lib/puppet/provider/<type-name>/` where `<type-name>` is the name of the previously defined Type.

The Provider of a type is responsible with the actual interfaceing with the CLI and is responsible for defining the logic that controls how resources will be applied to Netvisor. Sometimes this logic can be as simple as checking for values, and other times it involves complex descision making and control structures. (Take a look at `lib/puppet/provider/pn_vrouter_if/netvisor.rb`)

Providers are declared with `Puppet::Type.type(<type-name>).provide(:netvisor)`. Ensurable resource must contain at least 3 methods, `exists?`, `create`, and `destory` to be a valid provider, and must contain a way of checking property values, in methods named `<property-name>`. Property setters are declared with `<property-name>=(value)`. The basic provider structure for the `sample_type` provider would look like this: (Keep in mind this isn't actually done YET and wouldn't actually work)
```ruby
Puppet::Type.type(:sample_type).provide(:netvisor) do
    def exists?
    end

    def create
    end

    def destroy
    end

    def sample_prop
    end

    def sample_prop=(value)
    end
end
```

Before we discuss what all these methods actually need to do we also need to add a way to interface with the CLI, this is actually pretty easy to do. Because all calls to the CLI can be excecuted from the Linux command line we can excecute a CLI command like `CLI (...) > vlan-show` by running `$ /usr/bin/cli --quiet vlan-show`. Because of this we can declare `/usr/bin/cli` or for simplicity `cli` as a command that the Provider has access to. We do this with the `commands` method and use a symbol for the name of the command. We can call the CLI with `cli('args', 'go', 'here')`. (The commands specified follow shell syntax and therefore each argument must be given seperatly.) Adding the CLI command to our provider looks like this:
```ruby
Puppet::Type.type(:sample_type).provide(:netvisor) do
    commands :cli => 'cli'
    ...
end
```

Now we can discuss what the various methods we created are for. The `exists?` method returns either `true` or `false` (which an experienced rubist may have gathered from the name) depending on wheter or not the queried resource exists or not on the system. You have to write this logic yourself, for `sample_type` you would need to query Netvisor (or the Linux command line) and write some logic to determine if the requested sample type exists on the system or not. Based on the result of `exists?` Puppet will decide how to handle the resource, if the resource exists and the user specified that it should exist Puppet will make sure all of the properties match. If the resource exists but the user specified that it shouldn't, Puppet will destroy the resource by calling `destroy`. Finally, if the resource doesn't exist but the user said that it should Puppet will call `create` to create the resource.

This is a good time to discuss accessing the values that were specified in the resource decleration in the manifest. When Puppet compiles the manifest and moves to the Provider, it creates a hash called `resource` which contains all of the values given to the Type in the manifest file. The keys to this hash are the symbols that were supplied as the names for the properties. So if we want to access the name of the resource that was specified in the manifest, in the provider we can use the value of `resource[:name]`. Lets use all this new knowledge to implement `exists?` for our sample type. (Assuming that it can be shown by the CLI)
```ruby
Puppet::Type.type(:sample_type).provide(:netvisor) do
    ...
    def exists?
        if cli('--quiet', 'sample-type-show', 'name', resource[:name]) != ''
            return true
        end
        return false
    end
    ...
end
```

Sometimes the `exists?` logic is this simple, but most of the time it isn't. We can move on to create, which is called when exists returns `false` but the resource should be present. A simple create method for our sample type might look something like this:
```ruby
Puppet::Type.type(:sample_type).provide(:netvisor) do
    ...
    def create
        cli('sample-type-create', 'name', resource[:name], 'sample-prop', resource[:sample_prop])
    end
    ...
end
```

Puppet will assume that the resource was actually created after it calls this method, so make sure that you implement it correctly. We can implement the destroy method next, which is called if `exists?` returns `true` and the rsource should't exist.
```ruby
Puppet::Type.type(:sample_type).provide(:netvisor) do
  ...
  def create
    cli('sample-type-delete', 'name', resource[:name])
  end
  ...
end
```

In addition to `exists?` `create` and `destroy` Puppet providers must also have getters and setters for all of the properties that were defined in the Type for the resource. The getters are used when a resource already exists on the system to check that all of the properties on the system match their declared values from the manifest. A typical getter looks something like this:
```ruby
Puppet::Type.type(:sample_type).provide(:netvisor) do
  ...
  def sample_prop
    cli('sample-type-delete', 'name', resource[:name])
  end
  ...
end
```

And a normal setter may look like this:
```ruby
Pupept::Type.type(:sample_type).provide(:netvisor) do
  ...
  def sample_prop=(value)
    cli('sample-type-modify', 'name', resource[:name], 'value', value)
  end
  ...
end
```

Un-modifiable CLI properties sometimes must be set by calling first destroy and than create:
```ruby
Puppet::Type.type(:sample_type).provide(:netvisor) do
  ...
  def sample_prop=(value)
    destroy
    create
  end
  ...
end
```

## git and GitHub

This project uses git for version control. (As you have probably figured out by now). We currently host the git repository on [GitHub](www.github.com) and that is where we deal with pull requests and issues. 

### Setting up git and GitHub
If you have never used git before look at [this guide](http://rogerdudler.github.io/git-guide/). Create a GitHub account if you don't already have one by cicking [here](https://github.com/join). If you work for Pluribus and don't expect to contribute to any other GitHub projects, or don't want to use a personal email, sign up with your Pluribus email address, otherwise feel free to use your personal email to sign up for GitHub.

Set up your global email to match your Github email with `$ git config --global user.email johndoe@example.com` and set your name if you haven't already `git config --global user.name "John Doe"`.

Clone the repository to your local machine with `git clone https://github.com/amitsi/pluribus-puppet.git`. Pluribus Puppet uses a branch development model rather than a fork model, if you don't know what that means don't worry, you will be lucky enough to avoid the ensuing branch vs. fork debate.

### Project git Workflow
As stated before, this project follows a branch model of git development. There are 2 main branches, `master` and `develop`. `master` contains tagged, stable releases that will be uploaded as the latest version of Pluribus Puppet on Forge. `develop` is where all of the development occurs. This is where you will branch off from. You can create a branch named `user/<your-name>` to have a personal development branch or `user/<feature-name>` if you are developing a specific feature. Either way this should branch from `develop`. (there are many scenarios where you may be branching off something other than develop, but don't worry about that until you reach one of those scenarios) Features are merged with develop and eventually develop will gain a `release vx.x.x` branch where final tweaks for a release will be done. The release branch is the one that will be merged into master rather than the develop branch itself.

### Pushing and Pull Requests
You can push to your own remote branch whenever you feel the need (`$ git push origin <your-name>`). When you are ready to merge your changes with develop create a Pull Request on GitHub and the PR will be reviewed and approved by your peers before you are allowed to merge your branch back into develop.

### Rebasing
Don't do it unless you are the current maintainer and have a good reason for needing a rebase :angry:

## Testing
To test new functionality, you can either use a full deployment setup and develop on the master server, or use a masterless setup and develop on either the target switch or your local machine. If you choose to develop on your local machine you will need to transfer the modified files, either by scp or some other file transfer method, to see the changes on a switch. 

## Documenting
One important thing to remember while contributing to this project is that the documentation needs to be current and informative. While writing documentation for engineers, write the documentation so that a new engineer could join the project and know where to start. When writing documentation for users, keep in mind that they may not be as familiar with the module as the authors are, for this reason, user documentation should be clear and informative. It should let the user know how to use a feature without over-whelming them with too many details.

### README.md
When you update a feature make sure that you update the README to match the new changes. All feature pushes should include diffs in the README.

## Additional Readings
There isn't much out there in terms of additional readings for Puppet. I have found a few good resources for Puppet modules, namely [Puppet Types and Providers](http://shop.oreilly.com/product/0636920026860.do) which goes into some depth about the types and providers that Puppet supplies. However, the book does not go as in depth as I would like and I wouldn't consider it a definitive guide. It introduces self.instances and pre-fetching which are two topics that I have yet to find mentioned in Puppet's documentation. The other resource I have found that is good for Type and Provider information, specifically self.instances and self.prefetch is this [blog](http://garylarizza.com), especially this series of articles. [1](http://garylarizza.com/blog/2013/11/25/fun-with-providers/), [2](http://garylarizza.com/blog/2013/11/26/fun-with-providers-part-2/), [3](http://garylarizza.com/blog/2013/12/15/seriously-what-is-this-provider-doing/). 