# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/bionic64"
    config.vm.box_check_update = false
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = false

    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
    end

    config.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
        vb.gui = false

        # Customize the amount of memory on the VM:
        vb.memory = "4096"
        vb.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/vagrant", "1"]
    end
    config.vm.define :profiling do |profiling|
        profiling.vm.host_name = "local-sample-profiling"
        profiling.hostmanager.aliases = [
            "demo.wordpress.local",
            "demo.wordpress-liveprof.local",
            "demo.bitrix.local",
            "setup.bitrix.local",
            "demo.liveprof-ui.local",
            "demo.publify.local",
            "demo.flamescope.local",
            "demo.hlebushek.local",
            "demo.python3.local",
            "demo.nodejs.local",
            "demo.blogifier.local",
        ]
        profiling.vm.network "private_network", ip: "172.16.61.2"
    end

    # Enable provisioning with a shell script.
    if ENV['SCRIPT']
        config.vm.provision "shell", :privileged => true, path: ENV['SCRIPT']
    else
       config.vm.provision "shell", :privileged => true, path: "vagrant/install-docker.sh"
    end

    config.vm.provision "shell", :privileged => true, inline: <<-SHELL
        echo "local sampling pro PROVISIONING DONE, use folloding scenario for developing"
        echo "#  vagrant ssh profiling"
        echo "for docker build run following command"
        echo "#  cd /vagrant && sudo ./run_docker.sh"
        echo "Good Luck ;)"
    SHELL

end
