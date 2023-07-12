#!/bin/bash

BOLD="\033[1;39m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"

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

echo -e "${BOLD}Check if Vagrant is present...${BOLD}"

if ! command -v vagrant &> /dev/null; then
    echo -e "${RED}Vagrant not present...\n${BOLD}Installing..."
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
        echo -e "${RED}OS not supported."
        exit 1
    fi
    echo -e "${GREEN}Done."
else
    echo -e "${GREEN}Vagrant is present."
fi

echo -e "${BOLD}Check if the provider (VirtualBox) is present...${BOLD}"

if ! command -v virtualbox &> /dev/null; then
    echo -e "${RED}VirtualBox not present...\nPlease, install a stable version of Oracle VirtualBox.\nAborting..."
    exit 1
else
    echo -e "${GREEN}VirtualBox is present."
fi

echo -e "${BOLD}Initializing...\nPlease, be aware this could take several minutes."

vagrant up --provider=virtualbox

until [ $(vagrant status | sed 1,2d | head -n3 | grep -o 'running' | wc -l) == 3 ]
do
    sleep 3 && echo "...waiting for status from Vagrant"
done

echo -e "${GREEN}Done."

echo -e "${BOLD}Check if kubectl is present..."

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl not present\n${BOLD}Installing..."
    if $linux; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
        checksum_kctl=$(echo "$(<kubectl.sha256) kubectl" | sha256sum --check | awk -F:' ' '{ print $2 }')
        if [ "$checksum_kctl" != "OK" ]; then
            exit 1
        fi
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl kubectl.sha256
    elif $darwin; then
        brew install kubectl
    else
        echo -e "${RED}OS not supported."
        exit 1
    fi
    echo -e "${GREEN}Done."
else
    echo -e "${GREEN}kubectl is present."
fi

echo -e "${BOLD}Configuring..."

if [ ! -d ~/.kube ]; then mkdir ~/.kube; else cp ~/.kube/config ~/.kube/config-$(date +"%Y-%m-%d-%H-%M-%S"); fi

vagrant ssh master -- -t 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config

echo -e "${GREEN}Done.${BOLD}"

while true; do
    read -r -p "Do you want to enable Kubernetes Dashboard? (y/n): " answer
    case $answer in
        [Yy]* )
            kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
            kubectl apply -f dashboard-adminuser.yaml
            echo -e ""
            kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
            echo -e "${BOLD}\nPlease, use the token above to log into Dashboard UI."
            kubectl proxy &> /dev/null &
            echo -e "${BOLD}To access Dashboard UI, click the next URL:"
            echo -e "${YELLOW}http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
            echo -e "${BOLD}In case of error, please open a new terminal session and type ${YELLOW}kubectl proxy"; break;;
        [Nn]* ) exit;;
        * ) echo -e "${BOLD}Please, answer Y or N.";;
    esac
done

echo -e "${GREEN}All set. Enjoy your orchestration!${BOLD}"