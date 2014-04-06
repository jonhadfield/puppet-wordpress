# -*- mode: ruby -*-
# vi: set ft=ruby :

# You can create more than one Vagrant node for use with this repository by
# inserting new entries in to the `nodes` codeblock. Any values which you leave
# unset, and which have a default value in the `node_defaults` codeblock, will
# be set by the value in the `node_defaults` codeblock. If you define a value in
# the context of a specific node, this will override the default value for that
# node.

nodes = {
  'node0' => {:ip => '172.16.10.10', :memory => 512},
}

node_defaults = {
  :domain => 'internal',
  :memory => 384,
}

# Vagrant uses the concept of a machine image to boot a virtual machine - think
# of them like AMIs on AWS or, a more retro example, as the output of tools like
# Norton Ghost, Parallels Image Tool etc.

Vagrant.configure("2") do |config|
  config.vm.box     = "puppet-debian73-64"
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/debian-73-x64-virtualbox-puppet.box"

# Creating a forwarded port mapping, as below, allows access to specific ports
# on the Vagrant VM from the host. In this instance, we're redirecting :80 on
# the guest (Vagrant VM) to :8080 on the host.

  config.vm.network :forwarded_port, guest: 80, host: 8080

# Given that the use of Vagrant locally is to check that our Puppet manifests
# work, we're now going to specify exactly where our manifests lie. In this
# repository's case, `init.pp` imports *.pp from within the `manifests`
# directory, and can trigger the other manifests as appropriate, therefore we
# only need to specify `init.pp` as our `manifest_file`.

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "manifests",
    puppet.manifest_file  = "init.pp",
  end
end
