#!/bin/bash
printf "\n"
printf "\nNOTE! A working installation of both docker and docker-compose is required for this solution to work!"
printf "\n"
printf "\n"
printf "\n**************"
printf "\nRunning update"
printf "\n**************\n"
cd /etc/yum.repos.d/
sed  -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/$releasever/g' photon.repo photon-updates.repo photon-extras.repo photon-debuginfo.repo
#tdnf update -y
printf "\n**************"
printf "\nInstalling required stuff"
printf "\n**************"
tdnf install -y git
curl -s -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

printf "\n************"
printf "\nCheck docker"
printf "\n************"
SRV_STATUS=$(systemctl is-active docker)
echo $SRV_STATUS
if [ "$SRV_STATUS" = "active" ]; then
  printf "\nDocker is running, continuing"
else
  printf "\nDocker is NOT running. Cannot continue"
  printf "\nFix the problem (try a reboot) and run the script again\n"
  exit
fi
printf "\n"

printf "\n*****************************************"
printf "\nPlease provide info about the environment"
printf "\n*****************************************"
printf "\n"

read -p "vCenter fqdn: " VC_HOST
#read -p "Scheme [HTTPS/http]: " VC_SCHEME
read -p "Discovery interval (seconds) [600]: " VC_INTERVAL
read -p "Cluster name: " VC_CLUSTER
read -p "User: " VC_USER
read -s -p "Password: " VC_PASS

VC_INTERVAL="${VC_INTERVAL:-600}"

#if [[ "$VC_SCHEME" == "http" ]]; then
#  $VC_SCHEME=http
#else
#  $VC_SCHEME=https
#fi
VC_SCHEME=https

printf "\n******************************"
printf "\nCreating VC Token, please wait"
printf "\n******************************"
VC_TOKEN=$(docker run -it vmware/vsan-prometheus-setup:v20210225 --host $VC_HOST --username $VC_USER --password $VC_PASS --cluster $VC_CLUSTER | tail -1)

printf "\n*****************"
printf "\nDownloading files"
printf "\n*****************"

mkdir -p /root/vsan-prometheus/vol
cd /root/vsan-prometheus
chown nobody:nogroup vol/
touch vol/targets.json
chown nobody:nogroup vol/targets.json

mkdir -p prometheus
curl -s -o docker-compose.yml https://raw.githubusercontent.com/rumart/vsan-prometheus-docker/main/docker-compose.yml
curl -s -o prometheus/prometheus.yml https://raw.githubusercontent.com/rumart/vsan-prometheus-docker/main/prometheus.yml
chown nobody:nogroup prometheus/prometheus.yml
chmod 644 prometheus/prometheus.yml
#curl -s -o prometheus/Dockerfile https://raw.githubusercontent.com/rumart/vsan-prometheus-docker/main/prom-Dockerfile

mkdir -p grafana/datasources
curl -s -o grafana/datasources/datasources.yaml https://raw.githubusercontent.com/rumart/vsan-prometheus-docker/main/grafana-datasources.yaml

curl -s -o /etc/systemd/system/vsan-monitor.service https://raw.githubusercontent.com/rumart/vsan-prometheus-docker/main/vsan-monitor.service
systemctl daemon-reload

printf "\n********************"
printf "\nGenerating env files"
printf "\n********************"

echo $VC_TOKEN > token_file
chown nobody:nogroup token_file
chmod 775 token_file
#cp token_file prometheus/
#chown nobody:nogroup prometheus/token_file

echo 'VCENTER = '"$VC_HOST"'' > vars.env
echo 'SCHEME = '"$VC_SCHEME"'' >> vars.env
echo 'INTERVAL_SEC = '"$VC_INTERVAL"'' >> vars.env
echo 'BEARER_TOKEN = '"$VC_TOKEN"'' >> vars.env
echo 'CONFIG_DIR = /vol/targets.json' >> vars.env

printf "\n********************"
printf "\nGetting things ready"
printf "\n********************"

#iptables -A INPUT -p tcp --dport 3000 -j ACCEPT
#iptables -A INPUT -p tcp --dport 9090 -j ACCEPT



printf "\n"
printf "Script finished! You can start your vSAN monitoring by running:\n"
printf '\e[1;32m%-6s\e[m' "cd /root/vsan-prometheus"
printf "\n"
printf '\e[1;32m%-6s\e[m' "docker-compose up"
printf "\nOr you can run the following to run this as a service"
printf '\e[1;32m%-6s\e[m' "systemctl enable vsan-monitor"
printf "\n"
printf '\e[1;32m%-6s\e[m' "systemctl start vsan-monitor"
printf "\nEnjoy!\n"
