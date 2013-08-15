# zfs-arcstat rpmbuild

This repo is intended to provide a semi-automated method
to build RPMs for the zfsonlinux [arcstat](https://github.com/zfsonlinux/arcstat) Perl script. 

## Usage

These steps are to perform a mock based rpmbuild on a local Linux host.

Download this repository

    git clone https://github.com/treydock/rpmbuild-zfs-arcstat.git zfs-arcstat
    cd zfs-arcstat

Build RPMs for both EL6 and EL5

    ./build.sh

Use the `--help` option to see full usage.

## Vagrant Usage

Requirements:

* Vagrant >= 1.2.0

Optional: 

* vagrant-vbox-snapshot (`vagrant plugin install vagrant-vbox-snapshot`)

Download this repistory

    git clone https://github.com/treydock/rpmbuild-zfs-arcstat.git zfs-arcstat
    cd zfs-arcstat

Start the VM without provisioning.
This will download the vagrant box if run for the first time

    vagrant up --no-provision

Once this completes take the first, "base", snapshot.
Examples of snapshots below are with vagrant-vbox-snapshot.

    vagrant snapshot take 'base'

Now run the provision script.

    vagrant provision

Take another snapshot of the provisioned state.

    vagrant snapshot take 'provisioned'

Execute build script on the VM

    vagrant ssh -c '~/rpmbuild/build.sh'

## Additional Information

* [https://github.com/zfsonlinux/arcstat](https://github.com/zfsonlinux/arcstat)
* [Vagrant](http://www.vagrantup.com/)
* [vagrant-vbox-snapshot](https://github.com/dergachev/vagrant-vbox-snapshot)
* [Puppet Labs Vagrant Boxes](http://puppet-vagrant-boxes.puppetlabs.com/)
