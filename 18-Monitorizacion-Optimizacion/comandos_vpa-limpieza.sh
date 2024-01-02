#!/bin/bash

kubectl delete -f deployment_complex-vpa.yml
kubectl delete -f vpa_complex-autoscaler.yml
kubectl delete -f deployment_basic-vpa.yml
kubectl delete -f vpa_basic-autoscaler.yml
~/vpa/autoscaler/vertical-pod-autoscaler/hack/vpa-down.sh
