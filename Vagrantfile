require 'yaml'

IMAGE_NAME = "bento/ubuntu-24.04"
BOX_VERSION = "202404.26.0"
INSECURE = ENV["INSECURE"] == "true"
CLUSTER_VALUES = YAML.load_file('values.yml')
CP_CPU = CLUSTER_VALUES["resources"]["cp"]["cpu"]
CP_MEM = CLUSTER_VALUES["resources"]["cp"]["mem"]
N = ENV["NODES"].to_i
N_CPU = CLUSTER_VALUES["resources"]["nodes"]["cpu"]
N_MEM = CLUSTER_VALUES["resources"]["nodes"]["mem"]

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.box_download_insecure = true

    config.vm.define "control-plane" do |cp|
        cp.vm.box = IMAGE_NAME
        cp.vm.box_version = BOX_VERSION
        cp.vm.network "private_network", ip:"192.168.56.10"
        cp.vm.hostname = "control-plane"
        cp.vm.provision "ansible_local" do |ansible|
            ansible.compatibility_mode = "2.0"
            ansible.playbook = "kubernetes-setup/control-plane-playbook.yml"
            ansible.extra_vars = {
                node_ip:"192.168.56.10",
            }
            ansible.skip_tags = INSECURE ? "with-hardening" : ""
        end
        cp.vm.provider "virtualbox" do |v|
            v.memory = CP_MEM
            v.cpus = CP_CPU
        end
    end

    if N != 0
        (1..N).each do |i|
            config.vm.define "node-#{i}" do |node|
                node.vm.box = IMAGE_NAME
                node.vm.box_version = BOX_VERSION
                node.vm.network "private_network", ip:"192.168.56.#{i + 10}"
                node.vm.hostname = "node-#{i}"
                node.vm.provision "ansible_local" do |ansible|
                    ansible.compatibility_mode = "2.0"
                    ansible.playbook = "kubernetes-setup/node-playbook.yml"
                    ansible.extra_vars = {
                        node_ip:"192.168.56.#{i + 10}",
                    }
                    ansible.skip_tags = INSECURE ? "with-hardening" : ""
                end
                node.vm.provider "virtualbox" do |v|
                    v.memory = N_MEM
                    v.cpus = N_CPU
                end
            end
        end
    end
end