#!/bin/bash

echo =========== Create an ubuntu pod ==================
kubectl run ubuntu-dns --image=repocurso/ubuntu -- bash -c "while true; do echo hello; sleep 10;done"

# Wait for the pod "ubuntu" to contain the status condition of type "Ready"
kubectl wait --for=condition=Ready pod/ubuntu-dns

# Save a sorted list of IPs of all of the k8s SVCs:
kubectl get svc -A|egrep -v 'CLUSTER-IP|None'|awk '{print $4}'|sort -V > ips

# Copy the ip list to owr Ubuntu pod:
kubectl cp ips ubuntu-dns:/

echo =========== Installing dig tool into the pod ===============
kubectl exec -it ubuntu-dns -- apt-get update &> /dev/null
kubectl exec -it ubuntu-dns -- apt install -y dnsutils &> /dev/null

# Print 2 blank lines
yes '' | sed 2q

echo =========== Print all k8s SVC DNS records ====================
for ip in $(cat ips); do echo -n "$ip "; kubectl exec -it ubuntu-dns -- dig -x $ip +short; done
echo ====== End of list =====================

# Print 2 blank lines
yes '' | sed 2q

echo ========= Cleanup  ===============
kubectl delete pod ubuntu-dns
rm ips
exit 0