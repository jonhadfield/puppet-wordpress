require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['RS_PROVISION'] == 'no' or ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    if host['platform'] =~ /debian/
      on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
    end
    if host.is_pe?
      install_pe
    else
      # Install Puppet
      install_package host, 'rubygems'
      on host, 'gem install puppet --no-ri --no-rdoc'
      on host, "mkdir -p #{host['distmoduledir']}"
    end
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'wordpress')
    hosts.each do |host|
      on host, '/bin/touch /etc/puppet/hiera.yaml'
      # Required for mod_passenger tests.
      on host, puppet('module','install','puppetlabs-stdlib','--version','2.3.1'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-concat','--version','1.0.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-mysql', '--version','2.1.0'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-apache','--version','1.0.0'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
