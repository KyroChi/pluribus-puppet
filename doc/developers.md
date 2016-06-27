# Developers

### Table of Contents
1. [Developer Introduction](#introduction)
1. [Installing a Development Puppet Enviroment](#installing-puppet)
1. [The Puppet Module Structure](#module-structure)
1. [Types and Providers](#types-and-providers)
   - [Types](#types)
   - [Providers](#providers)
1. [Viewing Changes]()
1. [git and GitHub](#git-and-github)
   - [Setting up git](#setting-up-git-and-github)
   - [Project git Workflow](#project-git-workflow)
   - [Pushing and Pull Requests](#pushing-and-pull-requests)
   - [Rebasing](#rebasing)
1. [Testing]()
1. [Documenting]()
   - [Types]()
   - [Providers]()
   - [Tests]()
   - [README.md]()
   - [Tools]()
   - [Other docs]()
1. [Style-guide]()
   - [Ruby]()
   - [Puppet]()
   - [Shell]()
   - [Python]()
1. [Additional Readings]()
1. [Future Maintainers](#future-maintainers)

## Introduction

This document is for people who are planning on contributing to the Pluribus Puppet module. Whether you work for Pluribus or use our software, or even are just looking for a project to contribute to, this page is for you. The goal for this document is to familirize you with the source code well enough that you are able to contribute to the project.

## Installing Puppet

The first step in developing any Puppet module is installing Puppet in a way that is friendly to development.

## Module Structure

The Pluribus Puppet module follows more or less the project structure outlined by Puppet

## Types and Providers

At the core of Pluribus Puppet (and indeed most Pupept modules) are files called Types and Providers. The Types are located in `lib/puppet/types/` and are responsible for defining the paramaters and properties avaliable to a specific resource type. The Providers are located in `lib/puppet/providers/` and control the actual interaction between Puppet and the Netvisor CLI.

### Types

Types define how resources are defined in Puppet manifests and can do some simple error checking on the various parameters defined by the user. Any error checking that can be preformed by the Type should be preformed by the type, as errors thrown by Types will halt compilation, while errors thrown by the Provider will halt excecution. (which is a much less desierable, but sometimes un-avoidable outcome).

Types are defined with `Puppet::Type.newtype(<type-name>)`. Note that `<type-name>` must be a symbol, so a resource like `pn_vlan` is defined with `Puppet::Type.newtype(:pn_vlan)`. Not all types need a namevar, or need to be ensurable, but for Pluribus Puppet we like all of the managed resources to have some sort of unique identifer and be ensurable, even if this complcates the namevar somewhat. To declare a Type is ensurable use the Puppet method `ensurable` and to give the Type a name use `newparam(:name)`. There are other ways to declare a variable as a namevar, however `newparam(:name)` is the prefered method for this module.

Here us a sample bare-bones Type. (For declaring type `sample_type`)
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

## Viewing Changes

## git and GitHub

This project uses git for version control. (As you have probably figured out by now)

### Setting up git and GitHub
If you have never used git before look at [this guide](http://rogerdudler.github.io/git-guide/). Create a GitHub account if you don't already have one by cicking [here](https://github.com/join). If you work for Pluribus and don't expect to contribute to any other GitHub projects, or don't want to use a personal email sign up with your Pluribus email address, otherwise feel free to use your personal email to sign up for GitHub.

Set up your global email to match your Github email with `$ git config --global user.email johndoe@example.com` and set your name if you haven't already `git config --global user.name "John Doe"`.

Clone the repository to your local machine with `git clone https://github.com/amitsi/pluribus-puppet.git`. Pluribus Puppet uses a branch development model rather than a fork model, if you don't know what that means don't worry, you will be lucky enough to avoid the ensuing branch vs. fork debate.

### Project git Workflow
As stated before, this project follows a branch model of git development. There are 2 main branches, `master` and `develop`. `master` contains tagged, stable releases that will be uploaded as the latest version of Pluribus Puppet on Forge. `develop` is where all of the development occurs. This is where you will branch off from. You can create a branch named `user/<your-name>` to have a personal development branch or `user/<feature-name>` if you are developing a specific feature. Either way this should branch from `develop`. (there are many scenarios where you may be branching off something other than develop, but don't worry about that until you reach one of those scenarios) Features are merged with develop and eventually develop will gain a `release vx.x.x` branch where final tweaks for a release will be done. The release branch is the one that will be merged into master rather than the develop branch itself.

### Pushing and Pull Requests
You can push to your own remote branch whenever you feel the need (`$ git push origin <your-name>`). When you are ready to merge your changes with develop create a Pull Request on GitHub and the PR will be reviewed and approved by your peers before you are allowed to merge your branch back into develop.

### Rebasing
Don't do it unless you are the current maintainer and have a good reason for needing a rebase :angry:

## Testing

## Documenting

## Style-guide

## Additional Readings

## Future Maintainers

Hello future maintainer, whoever you may be. My name is Kyle Chickering, and I am the current maintainer of the Pluribus Puppet module. I am the sole author of the original release of this module, and let me pass on what I have learned in the process of implementing Puppet on ONVL Switches.
