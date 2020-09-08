#!/bin/bash
# This file /etc/atl required by ansible script, contains the vars
# Azure file storage to be created beforehand

IS_REDHAT=$(cat /etc/os-release | egrep '^ID' | grep rhel)


apt update > /dev/null 2>&1
jq=`which jq`
if [ "X$jq" == "X" ]
then
    if [[ -n ${IS_REDHAT} ]]
    then
        yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
        yum install jq -y
    else
        apt-get install -y jq
    fi
fi

BASE64_ENCODED=$1

# Decode the encoded string into a JSON string
echo $BASE64_ENCODED | base64 --decode | jq . > args.json
value=`cat args.json`

for row in $(echo "${value}" | jq -r '.[] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

   echo "$(_jq '.name')=$(_jq '.value')" >> /etc/atl
done


sleep 10m
# Install ansible dependancies
mkdir -p /usr/lib/systemd/system
mkdir -p /opt/atlassian

apt-get install -y python3.7 git > /dev/null 2>&1
# Clone playbook repo (azure-crowd branch instead of master)
git clone -b azure_deployments https://bitbucket.org/atlassian/dc-deployments-automation.git /opt/atlassian/dc-deployments-automation/
# Install ansible & execute playbook
cd /opt/atlassian/dc-deployments-automation/ && ./bin/install-ansible && ./bin/ansible-with-atl-env inv/azure_node_local azure_crowd_dc_node.yml /var/log/ansible-bootstrap.log