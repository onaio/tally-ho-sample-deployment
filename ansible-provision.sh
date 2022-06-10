# /bin/bash

export PATH="$HOME/.local/bin:$PATH"
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=$HOME/.local/bin/virtualenv
source $HOME/.local/bin/virtualenvwrapper.sh

workon ansible
# Check whether ansible is installed
if ! hash ansible; then
    echo "ansible needs to be installed"
    exit 1
fi

# Install ansible-galaxy requirements
ansible-galaxy install -r ansible/dependencies/requirements.yml

# Run the postgresql playbook
ansible-playbook -i ansible/inventories/production ansible/postgresql.yml

# Run the tally-ho playbook
ansible-playbook -i ansible/inventories/production ansible/tally-ho.yml