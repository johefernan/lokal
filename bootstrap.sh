#!/bin/bash

darwin=false;
linux=false;

case "$(uname)" in
    Linux*)
        linux=true
        ;;
    Darwin*)
        darwin=true
        ;;
esac

echo -e "\033[1;39mVagrant...is it present?"

if ! command -v vagrant &> /dev/null; then
    echo -e "\033[1;31mVagrant not present...\n\033[1;39mInstalling..."
    if $linux; then
        version_vg=$(curl -s https://releases.hashicorp.com/vagrant/ | grep href | grep -v '\.\.' | head -1 | awk -F/ '{ print $3 }')
        curl -SLO https://releases.hashicorp.com/vagrant/${version_vg}/vagrant_${version_vg}_linux_amd64.zip
        curl -sSLO https://releases.hashicorp.com/vagrant/${version_vg}/vagrant_${version_vg}_SHA256SUMS
        checksum_vg=$(sha256sum -c vagrant_${version_vg}_SHA256SUMS 2>&1 | grep OK | awk -F:' ' '{ print $2 }')
        if [ "$checksum_vg" != "OK" ]; then
            exit 1
        fi
        unzip vagrant_${version_vg}_linux_amd64.zip && rm vagrant_${version_vg}_linux_amd64.zip vagrant_${version_vg}_SHA256SUMS
        sudo mv vagrant /usr/bin/vagrant
    elif $darwin; then
        brew install vagrant
    else
        echo -e "\033[1;31mOS not supported"
        exit 1
    fi
    echo -e "\033[1;32mDone!"
else
    echo -e "\033[1;32mVagrant is present!"
fi

echo -e "\033[1;39mProvider..."

if ! command -v virtualbox &> /dev/null; then
    echo -e "\033[1;31mVirtualBox not present...\nPlease, install a stable version of Oracle VirtualBox"
    exit 1
else
    echo -e "\033[1;32mVirtualBox is present!"
fi

echo -e "\033[1;39mInitializing...\nPlease, be aware this could take several minutes."

vagrant up --provider=virtualbox

until [ $(vagrant status | sed 1,2d | head -n3 | grep -o 'running' | wc -l) == 3 ]
do
    sleep 3 && echo "...wait for status: running"
done

echo -e "\033[1;32mUp and Running!"

echo -e "\033[1;39mkubectl...is it present?"

if ! command -v kubectl &> /dev/null; then
    echo -e "\033[1;31mkubectl not present\n\033[1;39mInstalling..."
    if $linux; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
        checksum_kctl=$(echo "$(<kubectl.sha256) kubectl" | sha256sum --check | awk -F:' ' '{ print $2 }')
        if [ "$checksum_kctl" != "OK" ]; then
            exit 1
        fi
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && mkdir ~/.kube && rm kubectl.sha256
    elif $darwin; then
        brew install kubectl
    else
        echo -e "\033[1;31mOS not supported"
        exit 1
    fi
    echo -e "\033[1;32mDone!"
else
    echo -e "\033[1;32mkubectl is present!"
fi

echo -e "\033[1;39mConfiguring..."
vagrant ssh master -- -t 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config
echo -e "\033[1;32mDone!\nEnjoy your new cluster"