# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # config.vbguest.auto_update = false
  # Attempt to cache downloaded files (only if plugin is present).
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.enable :yum
    config.cache.enable :gem
  end
  # https://en.wikipedia.org/wiki/CentOS (6.6 = Redhat 6.6)
  config.vm.box = "box-cutter/ubuntu1604-desktop"
  config.ssh.insert_key = false
  config.vm.boot_timeout = 500
  config.vm.provision :shell, path: "bootstrap.sh"
  # Disable automatic box update checking. If you dbisable this, then
  # config.vm.box_download_insecure = true
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant"
  config.vm.provider "virtualbox" do |vb|
      vb.name = "vagrant-vodap-system"
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", 4096]
      vb.customize ["modifyvm", :id, "--vram", 64]
      # vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
      vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
      # Customize the amount of memory on the VM:
      vb.memory = "4096"
  end
end
