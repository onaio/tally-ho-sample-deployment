# /bin/bash

# Check whether ansible is installed
if ! hash ansible; then
    echo "ansible needs to be installed"
    exit 1
fi

# Run the postgresql playbook
ansible-playbook -i ansible/inventories/production ansible/postgresql.yml

# Run the tally-ho playbook
ansible-playbook -i ansible/inventories/production ansible/tally-ho.yml