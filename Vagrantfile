IMAGE_NAME = "bento/ubuntu-22.04"
N = ENV["NODES"].to_i

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box_download_insecure = true

    config.vm.define "control-plane" do |cp|
        cp.vm.box = IMAGE_NAME
        cp.vm.network "private_network", ip:"192.168.56.10"
        cp.vm.hostname = "control-plane"
        cp.vm.provision "ansible_local" do |ansible|
            ansible.compatibility_mode = "2.0"
            ansible.playbook = "kubernetes-setup/control-plane-playbook.yml"
            ansible.extra_vars = {
                node_ip:"192.168.56.10",
            }
        end
        cp.vm.provider "virtualbox" do |v|
            v.memory = 2048
            v.cpus = 2
        end
    end

    if N != 0
        (1..N).each do |i|
            config.vm.define "node-#{i}" do |node|
                node.vm.box = IMAGE_NAME
                node.vm.network "private_network", ip:"192.168.56.#{i + 10}"
                node.vm.hostname = "node-#{i}"
                node.vm.provision "ansible_local" do |ansible|
                    ansible.compatibility_mode = "2.0"
                    ansible.playbook = "kubernetes-setup/node-playbook.yml"
                    ansible.extra_vars = {
                        node_ip:"192.168.56.#{i + 10}",
                    }
                end
                node.vm.provider "virtualbox" do |v|
                    v.memory = 1024
                    v.cpus = 2
                end
            end
        end
    end
end