# -*- mode: ruby -*-
# vi: set ft=ruby :

module LocalHelper
  def self.module_dir
    File.dirname(__FILE__)
  end
end

$script = <<SCRIPT
if [ -e /etc/redhat-release ]; then
  yum -y install http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
fi

yum -y groupinstall 'Development Tools' 2>/dev/null
yum -y install mock rpm-build redhat-rpm-config rpmdevtools

cat > /home/vagrant/.rpmmacros <<EOF
%_topdir    %(echo ${RPM_TOPDIR:-/home/vagrant/rpmbuild})
EOF

usermod -a -G mock vagrant && newgrp mock

SCRIPT

Vagrant.configure("2") do |config|
  # CentOS base box
  config.vm.box = 'centos-64-x64-vbox4210-nocm'
  config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/centos-64-x64-vbox4210-nocm.box'
  # Fedora base box
  #config.vm.box = 'fedora-18-x64-vbox4210-nocm'
  #config.vm.box_url = 'http://puppet-vagrant-boxes.puppetlabs.com/fedora-18-x64-vbox4210-nocm.box'

  config.vm.hostname = 'rpmbuild.vm'

  config.vm.synced_folder LocalHelper.module_dir, "/home/vagrant/rpmbuild"

  config.vm.provider :virtualbox do |vb|
    # Boot with GUI mode
    vb.gui = true

    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision :shell, :inline => $script
end
