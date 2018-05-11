# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/xenial64"
    config.vm.box_check_update = false
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false

    config.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
        vb.gui = false

        # Customize the amount of memory on the VM:
        vb.memory = "2048"
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
    end
    config.vm.define :profiling do |profiling|
        profiling.vm.host_name = "local-sample-profiling"
        profiling.hostmanager.aliases = [
            "demo.wordpress.local",
            "demo.publify.local",
            "demo.flamescope.local",
            "demo.hlebushek.local",
        ]
        profiling.vm.network "private_network", ip: "172.16.61.2"
    end

    config.vm.provision "shell", inline: <<-SHELL
        set -xeuo pipefail
        export DEBIAN_FRONTEND=noninteractive
        sysctl net.ipv6.conf.all.forwarding=1
        apt-get update
        apt-get install -y apt-transport-https software-properties-common apache2-utils git

        # docker
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8D81803C0EBFCD88
        add-apt-repository "deb https://download.docker.com/linux/ubuntu xenial edge"

        apt-get update
        apt-get install -y docker-ce
        apt-get install -y htop ethtool mc iotop
        apt-get install -y python-pip
        pip install -U docker-compose requests

        echo "local sampling pro PROVISIONING DONE, use folloding scenario for developing"
        echo "#  vagrant ssh profiling"
        echo "for docker build run following command"
        echo "#  cd /vagrant && sudo ./run_docker.sh"
        echo "Good Luck ;)"
    SHELL
end
