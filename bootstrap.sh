#!/bin/bash

echo -e "\e[39mVagrant...is it present?"

if ! command -v vagrant &> /dev/null
then

    echo -e "\e[31mVagrant not present...\n\e[39mInstalling..."
    
    version_vg=$(curl -s https://releases.hashicorp.com/vagrant/ | grep href | grep -v '\.\.' | head -1 | awk -F/ '{ print $3 }')
    
    curl -SLO https://releases.hashicorp.com/vagrant/${version_vg}/vagrant_${version_vg}_linux_amd64.zip
    
    curl -sSLO https://releases.hashicorp.com/vagrant/${version_vg}/vagrant_${version_vg}_SHA256SUMS
    
    checksum_vg=$(sha256sum -c vagrant_${version_vg}_SHA256SUMS 2>&1 | grep OK | awk -F:' ' '{ print $2 }')

    if [ "$checksum_vg" != "OK" ]
    then
        exit 1
    fi

    unzip vagrant_${version_vg}_linux_amd64.zip && rm vagrant_${version_vg}_linux_amd64.zip vagrant_${version_vg}_SHA256SUMS
    
    sudo mv vagrant /usr/bin/vagrant

    echo -e "\e[32mDone!"

else
    
    echo -e "\e[32mVagrant is present!"

fi

echo -e "\e[39mProvider..."

if ! command -v virtualbox &> /dev/null
then

    echo -e "\e[31mVirtualBox not present...\nPlease, install a stable version of Oracle VirtualBox"

    exit 1

else

    echo -e "\e[32mVirtualBox is present!"

fi

echo -e "\e[39mInitializing...\nPlease, be aware this could take several minutes."

vagrant up --provider=virtualbox

until [ $(vagrant status | sed 1,2d | head -n3 | grep -o 'running' | wc -l) == 3 ]
do
    sleep 3 && echo "...waiting for status: running"
done

echo -e "\e[32mUp and Running!"

echo -e "\e[39mkubectl...is it present?"

if ! command -v kubectl &> /dev/null
then

    echo -e "\e[31mkubectl not present\n\e[39mDownloading..."
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    
    checksum_kctl=$(echo "$(<kubectl.sha256) kubectl" | sha256sum --check | awk -F:' ' '{ print $2 }')

    if [ "$checksum_kctl" != "OK" ]
    then
        exit 1
    fi

    echo -e "\e[39mInstalling kubectl"
    
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && mkdir ~/.kube && rm kubectl.sha256

else

    echo -e "\e[32mkubectl is present!"

fi

echo -e "\e[39mConfiguring..."

vagrant ssh master -- -t 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config

echo -e "\e[32mDone!\nEnjoy your new cluster"