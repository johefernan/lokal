# Lokal-Cluster
Local Production-Class Kubernetes Cluster using Vagrant and Ansible.

# Reference
This project was made following [Kubernetes Setup Using Ansible and Vagrant](https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/) as reference. Please, refer to that article for any further information.

# Prerequisites
- Vagrant should be installed on your machine. Installation binaries can be found [here](https://www.vagrantup.com/downloads.html).
- Oracle VirtualBox can be used as a Vagrant provider or make use of similar providers as described in Vagrant's official [documentation](https://www.vagrantup.com/docs/providers/).
- Ansible should be installed in your machine. Refer to the [Ansible installation guide](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) for platform specific installation.

# Getting Started
1. vagrant up && vagrant ssh master -- -t 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config