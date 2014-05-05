# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "precise64"

  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # config.vm.box_check_update = false

  config.ssh.forward_agent = true

  config.vm.network "forwarded_port", guest: 8983, host: 8983
  config.vm.network "forwarded_port", guest: 3306, host: 3306
  config.vm.network "forwarded_port", guest: 80, host: 8001
  config.vm.network "forwarded_port", guest: 8002, host: 8002
  config.vm.network "forwarded_port", guest: 8003, host: 8003
  config.vm.network "forwarded_port", guest: 8004, host: 8004
  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.network "private_network", ip: "10.10.10.20"
  config.vm.hostname = "vagrant.dev-box.com"


  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.vm.define 'localhost-box' do |node|
    node.vm.hostname = 'localhost'
    node.vm.network :private_network, ip: '127.0.0.1'
    node.hostmanager.aliases = %w(dev.spangleapi)
  end


  config.vm.synced_folder "shared/", "/shared"
  config.vm.synced_folder "puppet/files/", "/etc/puppet/files", :mount_options => ["dmode=777,fmode=777"]

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.manifest_file  = "site.pp"
    puppet.options = "--fileserverconfig=/vagrant/puppet/fileserver.conf"
    puppet.facter = {
        "fqdn" => "vagrant.dev-box.com",
    }
  end

  config.vbguest.auto_update = false

end
