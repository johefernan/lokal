#!/usr/bin/env bash

set -e

CLEAR="\033[1;0m"
BOLD="\033[1;39m"
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"

darwin=false;
linux=false;

destroy () {
    vagrant destroy
    echo -e "👋 ${GREEN}All gone. 'Til the next time!"
    exit 0
}

return_help () {
    echo "Usage: $0 [option...]"
    echo "  -n    set number of nodes (default=1), choose 0 to disable nodes."
    echo "  -d    use this flag to destroy the cluster."
    echo "  -h    return this help."
    exit 0
}

case "$(uname)" in
    Linux*)
        linux=true
        ;;
    Darwin*)
        darwin=true
        ;;
esac

nodes=1

while getopts n:dh opt
do
    case "${opt}" in
        n) nodes=${OPTARG}
        ;;
        d) destroy
        ;;
        h) return_help
        ;;
    esac
done

echo -e "🔍 ${BOLD}Check if Vagrant is present..."

if ! command -v vagrant &> /dev/null; then
    echo -e "🫥 ${RED}Vagrant not present...\n${BOLD}Installing..."
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
        echo -e "❌ ${RED}OS not supported."
        exit 1
    fi
    echo -e "✅ ${GREEN}Done."
else
    echo -e "👍 ${GREEN}Vagrant is present."
fi

echo -e "🔍 ${BOLD}Check if the provider (VirtualBox) is present..."

if ! command -v virtualbox &> /dev/null; then
    echo -e "🫥 ${RED}VirtualBox not present...\nPlease, install a stable version of Oracle VirtualBox (https://www.virtualbox.org/).\nAborting..."
    exit 1
else
    echo -e "👍 ${GREEN}VirtualBox is present."
fi

echo -e "🚀 ${BOLD}Initializing...\nPlease, be aware this could take several minutes."

env NODES=$nodes vagrant up --provider=virtualbox

until [ $(vagrant global-status | sed 1,2d | head -n$(expr 1 + $nodes) | grep -o 'running' | wc -l) == $(expr 1 + $nodes) ]
do
    sleep 3 && echo "...waiting for status from Vagrant"
done

echo -e "✅ ${GREEN}Done."

echo -e "🔍 ${BOLD}Check if kubectl is present..."

if ! command -v kubectl &> /dev/null; then
    echo -e "🫥 ${RED}kubectl not present\n${BOLD}Installing..."
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
        echo -e "❌ ${RED}OS not supported."
        exit 1
    fi
    echo -e "✅ ${GREEN}Done."
else
    echo -e "👍 ${GREEN}kubectl is present."
fi

echo -e "🚦 ${BOLD}Setup kubeconfig..."
vagrant ssh control-plane -- -t 'sudo cat /etc/kubernetes/admin.conf' > ./kubeconfig
KUBECONFIG_PATH="$(pwd)/kubeconfig"
export KUBECONFIG=$KUBECONFIG_PATH
echo -e "✅ ${GREEN}Done.${CLEAR}"

if [[ $nodes -ge 1 ]]; then
    while true; do
        read -r -p "Do you want to enable Kubernetes Dashboard? (y/n): " answer
        case $answer in
            [Yy]* )
                kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
                kubectl apply -f dashboard-adminuser.yaml
                echo -e ""
                kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
                echo -e "${BOLD}\nPlease, use the token above to log into Dashboard UI."
                kubectl proxy &> /dev/null &
                echo -e "${BOLD}To access Dashboard UI, click the next URL:"
                echo -e "${YELLOW}http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
                echo -e "${BOLD}In case of error, please open a new terminal session and type ${YELLOW}kubectl proxy"; break;;
            [Nn]* ) break;;
            * ) echo -e "${BOLD}Please, answer Y or N.";;
        esac
    done
else
    echo -e "${YELLOW}Skipping Kubernetes Dashboard. Add at least one additional node to install Kubernetes Dashboard."
fi

echo -e "✨ ${GREEN}All set. Enjoy your orchestration!"