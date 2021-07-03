![container](container.png)
<div>Icons made by <a href="https://creativemarket.com/eucalyp" title="Eucalyp">Eucalyp</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div><br/>

# Lokal
Local Production-Class Kubernetes Cluster using Vagrant and Ansible.

## Reference
This project was made following [Kubernetes Setup Using Ansible and Vagrant](https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/) as reference. Please, refer to that article for any further information.

## Prerequisites
- VirtualBox must to be present on your system. Vagrant will seek for a version of Oracle VirtualBox in your localhost to use it as a default [provider](https://www.vagrantup.com/docs/providers).
- Additionally for macOS users, install [Homebrew](https://brew.sh/index) previously.

### <span style="color:yellow">Disclaimer</span>
- This cluster is for learning and practical purposes only; be aware that it is not recommended for actual production workloads.
- `dashboard-adminuser.yaml` creates a sample user using Service Account mechanism and grants this user admin permissions. Granting admin privileges to Dashboard's Service Account might be a security risk. Please refer to [Creating sample user](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md) documentation for any concern.

### <span style="color:red">Warning</span>
- If you have any other cluster definition in `~/.kube/config`, please make a copy of your current `~/.kube/config` file.

## Getting Started
1. Run bootstrap.sh
