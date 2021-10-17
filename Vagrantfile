IMAGE_NAME = "bento/ubuntu-20.04"
N = 2

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box_download_insecure = true

    config.vm.define "master" do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network "private_network", ip:"192.168.50.10"
        master.vm.hostname = "master"
        master.vm.provision "ansible_local" do |ansible|
            ansible.compatibility_mode = "2.0"
            ansible.playbook = "kubernetes-setup/master-playbook.yml"
            ansible.extra_vars = {
                node_ip:"192.168.50.10",
            }
        end
        master.vm.provider "virtualbox" do |v|
            v.memory = 2048
            v.cpus = 2
        end
    end

    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip:"192.168.50.#{i + 10}"
            node.vm.hostname = "node-#{i}"
            node.vm.provision "ansible_local" do |ansible|
                ansible.compatibility_mode = "2.0"
                ansible.playbook = "kubernetes-setup/node-playbook.yml"
                ansible.extra_vars = {
                    node_ip:"192.168.50.#{i + 10}",
                }
            end
            node.vm.provider "virtualbox" do |v|
                v.memory = 1024
                v.cpus = 2
            end
        end
    end
end