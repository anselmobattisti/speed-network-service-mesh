#!/bin/bash

install(){

    echo "Installing floating-vl3-basic usecase..."
    
    echo "Install APP vl3-ipam..."
    kubectl --context=kind-cluster1 apply -k ./apps/vl3-ipam
    kubectl --context=kind-cluster2 apply -k ./apps/vl3-ipam
    kubectl --context=kind-cluster3 apply -k ./apps/vl3-ipam

    return
    
    kubectl --context=kind-cluster3 apply -k ./cluster3

    kubectl --context=kind-cluster1 apply -k ./cluster1

    kubectl --context=kind-cluster2 apply -k ./cluster2

    kubectl --context=kind-cluster2 wait --for=condition=ready --timeout=1m pod -l app=alpine -n ns-floating-vl3-basic

    kubectl --context=kind-cluster1 wait --for=condition=ready --timeout=1m pod -l app=alpine -n ns-floating-vl3-basic
}

test(){
    echo "Starting test process..."

    echo "Fetching IP address from cluster2..."

    ipAddr2=$(kubectl --context=kind-cluster2 exec -n ns-floating-vl3-basic pods/alpine -- ifconfig nsm-1)
    ipAddr2=$(echo $ipAddr2 | grep -Eo 'inet addr:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| cut -c 11-)

    echo "Pinging cluster2 IP ($ipAddr2) from cluster1..."
    kubectl --kubeconfig=kind-cluster1 exec pods/alpine -n ns-floating-vl3-basic -- ping -c 4 $ipAddr2
}

menu() {
    while true; do
        echo "========== Menu =========="
        echo "1. Install"
        echo "2. Test"
        echo "3. Exit"
        echo "=========================="
        read -rp "Select an option [1-3]: " choice

        case $choice in
            1)
                install
                ;;
            2)
                test
                ;;
            3)
                echo "Exiting script. Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option. Please select 1, 2, or 3."
                ;;
        esac
    done
}

# Start the menu
menu


# Manual creation
kubectl --context=kind-cluster3 apply -k https://github.com/networkservicemesh/deployments-k8s/examples/interdomain/usecases/floating_vl3-basic/cluster3?ref=074947f2e902b17de98c9410c96cc09d3208e15a
kubectl --context=kind-cluster1 apply -k https://github.com/networkservicemesh/deployments-k8s/examples/interdomain/usecases/floating_vl3-basic/cluster1?ref=074947f2e902b17de98c9410c96cc09d3208e15a
kubectl --context=kind-cluster2 apply -k https://github.com/networkservicemesh/deployments-k8s/examples/interdomain/usecases/floating_vl3-basic/cluster2?ref=074947f2e902b17de98c9410c96cc09d3208e15a




kubectl --context=kind-cluster1 wait --for=condition=ready --timeout=1m pod -l app=alpine -n ns-floating-vl3-basic
