#!/bin/bash

BOX_VERSION=${1:-$(date +%Y%m%d).0.0}
BOX_PROVIDER=virtualbox BOX_NAME=yogendra/k8s-base BOX_FILE=k8s-base.box BOX_MACHINE=k8s-base
cat <<EOF
File    : $BOX_FILE
Name    : $BOX_NAME
Version : $BOX_VERSION
Provider: $BOX_PROVIDER
Machine : $BOX_MACHINE
EOF

echo "Creating and Provisioning"
vagrant up $BOX_MACHINE

echo "Stop Machine"
vagrant halt $BOX_MACHINE

echo "Package box"
[[ -f $BOX_FILE ]] && rm $BOX_FILE
vagrant package --output $BOX_FILE $BOX_MACHINE

echo "Putting box to local cache"
vagrant box add -f --provider $BOX_PROVIDER --name $BOX_NAME ./$BOX_FILE
