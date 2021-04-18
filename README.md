# vsan-prometheus-docker

This repo will help you set up a solution for monitoring a vSAN cluster with Prometheus and Grafana.

**The scripts are currently tested ONLY against a Photon OS 3 VM and a vSAN cluster running vSphere 7.0 U1**

## Get started

- Deploy a Photon OS 3 VM
- Copy the setup.sh script to the VM
- Run the script
- Fill in the details of the environment
  - vCenter FQDN
  - Interval for running the service discovery (i.e. how often to check for new hosts)
  - Cluster name
  - Username/password

## Startup

- cd to /root/vsan-prometheus
- run docker-compose up

## Configure dashboards

- Open a browser to the IP of the VM and port 3000
  - The Prometheus server is available on port 9090
- Log in with the default Grafana admin credentials (admin/admin)
- Set a new password for the Admin account
- Start creating dashboards

## Roadmap

- Include default dashboards
