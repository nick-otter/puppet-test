!#/bin/bash

# Install Puppet agent - to be run on Puppet agent server

wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo apt-get update
sudo apt-get install puppet-agent
sudo systemctl enable puppet
sudo systemctl start puppet
