Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/focal64"
    config.vm.define "bastion" do |bastion|
      bastion.vm.provider :virtualbox do |vb|
        vb.name = "tally-ho-bastion"
        vb.memory = 2048
        vb.cpus = 1
      end

      bastion.vm.network "private_network", ip: "10.0.0.2"
      bastion.vm.provision "shell", inline: "git clone https://github.com/onaio/tally-ho-sample-deployment"
      bastion.ssh.forward_agent = true
    end
  end