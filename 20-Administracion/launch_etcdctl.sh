ETCD_VERSION="v3.5.1"
wget https://github.com/etcd-io/etcd/releases/download/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz -O /tmp/etcd-$ETCD_VERSION-linux-amd64.tar.gz
tar xvf /tmp/etcd-$ETCD_VERSION-linux-amd64.tar.gz -C /tmp
sudo cp /tmp/etcd-$ETCD_VERSION-linux-amd64/etcd /tmp/etcd-$ETCD_VERSION-linux-amd64/etcdctl /usr/local/bin
