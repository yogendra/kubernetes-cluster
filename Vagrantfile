# -*- mode: ruby -*-
# vi: set ft=ruby :
$box = "yogendra/k8s-base"
$box_version = "20190408.0.0"
servers = [
    {
        :name => "k8s-head",
        :type => "master",
        :box => $box,
        :box_version => $box_version,
        :eth1 => "192.168.205.10",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-1",
        :type => "node",
        :box => $box,
        :box_version => $box_version,
        :eth1 => "192.168.205.11",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-2",
        :type => "node",
        :box => $box,
        :box_version => $box_version,
        :eth1 => "192.168.205.12",
        :mem => "2048",
        :cpu => "2"
    }
]

# This script to install k8s using kubeadm will get executed after a box is provisioned
$configureBox = <<-SCRIPT
    # set node-ip
    export IP_ADDR=$(ip -4 addr show enp0s8 |  grep inet  | awk {'print $2'} | cut -d/ -f1)    

    # ip of this box
    
    if [ ! -f /etc/default/kubelet ];
    then
        sudo echo KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR > /etc/default/kubelet
    else
        sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/default/kubelet
    fi
    sudo systemctl restart kubelet
SCRIPT

$configureMaster = <<-SCRIPT
    echo "This is master"
    # ip of this box
    export IP_ADDR=$(ip -4 addr show enp0s8 |  grep inet  | awk {'print $2'} | cut -d/ -f1)

    echo IP_ADDR=$IP_ADDR
    # install k8s master
    HOST_NAME=$(hostname -s)
    kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR  --node-name $HOST_NAME --pod-network-cidr=172.16.0.0/16

    #copying credentials to regular user - vagrant
    sudo --user=vagrant mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config
    
    cp /home/vagrant/.kube/config /vagrant/shared/config
    echo "On the host machine you can run following to connect to k8s cluster:"
    echo "    export KUBECONFIG=\$(pwd)/shared/config"
    echo "    kubectl get-cluster"

    # install Calico pod network addon
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f https://raw.githubusercontent.com/ecomm-integration-ballerina/kubernetes-cluster/master/calico/rbac-kdd.yaml
    kubectl apply -f https://raw.githubusercontent.com/ecomm-integration-ballerina/kubernetes-cluster/master/calico/calico.yaml

    kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh
    cp -f /etc/kubeadm_join_cmd.sh /vagrant/shared/kubeadm_join_cmd.sh
SCRIPT

$configureNode = <<-SCRIPT
    echo "This is worker"
    cp /vagrant/shared/kubeadm_join_cmd.sh ./kubeadm_join_cmd.sh
    chmod a+x ./kubeadm_join_cmd.sh
    ./kubeadm_join_cmd.sh
SCRIPT

Vagrant.configure("2") do |config|
    servers.each do |opts|
        config.vm.define opts[:name] do |config|

            config.vm.box = opts[:box]
            config.vm.box_version = opts[:box_version]
            config.vm.hostname = opts[:name]
            config.vm.network :private_network, ip: opts[:eth1]

            config.vm.provider "virtualbox" do |v|
                v.linked_clone = true
                v.name = opts[:name]
                v.customize ["modifyvm", :id, "--groups", "/Ballerina Development"]
                v.customize ["modifyvm", :id, "--memory", opts[:mem]]
                v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]

            end

            # we cannot use this because we can't install the docker version we want - https://github.com/hashicorp/vagrant/issues/4871
            #config.vm.provision "docker"

            config.vm.provision "shell", name: "bootstrap", inline: $configureBox

            config.vm.provision "shell", name: "k8s", inline:  opts[:type] == "master" ? $configureMaster: $configureNode
          

        end

    end

end 
