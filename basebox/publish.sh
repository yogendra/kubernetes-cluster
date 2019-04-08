#!/bin/bash

BOX_VERSION=${1:-$(date +%Y%m%d).0.0}
BOX_PROVIDER=virtualbox 
BOX_NAME=yogendra/k8s-base 
BOX_FILE=k8s-base.box 
BOX_MACHINE=k8s-base
cat <<EOF
File    : $BOX_FILE
Name    : $BOX_NAME
Version : $BOX_VERSION
Provider: $BOX_PROVIDER
Machine : $BOX_MACHINE
EOF

[[ ! -f $BOX_FILE ]] && ./build.sh $BOX_VERSION

vagrant cloud publish -r -f -s "k8s base box (linux, ubuntu, bionic, docker, kubeadm)" -d "k8s base box (linux, ubuntu, bionic, docker, kubeadm)" $BOX_NAME $BOX_VERSION $BOX_PROVIDER $BOX_FILE
