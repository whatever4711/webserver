# -*- mode: ruby -*-
# vi: set ft=ruby :


DB_HOST="localhost"
DB_NAME="dbname"
DB_USER="dbuser"
DB_USER_PWD="123"
DB_ROOT_PWD="456"
PHPMYADMIN_PORT="81"
APP_NAME="webdjango"
APP_USER_AND_DB="webdjango"
APP_DB_PWD="258"

Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "debian/jessie64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |v|
      v.name = "webserver"
      v.gui=true
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "75"]
      v.customize ["modifyvm", :id, "--memory", "4096"]
  end
  config.vm.provision :shell, privileged: false, :path => "setup/basic-setup.sh"
  config.vm.provision :shell, privileged: false, :path => "setup/mysql.sh", args: [DB_ROOT_PWD, DB_NAME, DB_USER, DB_USER_PWD, APP_USER_AND_DB, APP_DB_PWD]
  config.vm.provision :shell, privileged: false, :path => "setup/phpmyadmin.sh", args: [DB_ROOT_PWD, DB_USER_PWD]
  config.vm.provision :shell, privileged: false, :path => "setup/lamp.sh", args: [PHPMYADMIN_PORT, DB_HOST, APP_NAME, APP_USER_AND_DB, APP_DB_PWD]
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
