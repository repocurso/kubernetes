sudo apt install -y tree

ssh-keygen -q -t rsa -f ~/.ssh/id_rsa -N "" <<< y
ssh-copy-id 192.168.100.11 -f 
ssh-copy-id 192.168.100.12 -f

sudo sed -i '$a 192.168.100.10\tmaster\tmaster\n192.168.100.11\tnode1\tnode1\n192.168.100.12\tnode2\tnode2' /etc/hosts

