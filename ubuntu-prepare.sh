#!/bin/bash
# Install Python3 and pip3

sudo apt update && sudo apt install python3-pip -y
# set python3 as the default python and pip3 as the default pip
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 100
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 100

# install virtualenv and virtualenvwrapper
sudo pip install virtualenvwrapper

# add virtualenv config to .bashrc
cat >> ~/.bashrc << EOF
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
source /usr/local/bin/virtualenvwrapper.sh
EOF

# load the new config
source ~/.bashrc

# create a virtualenv
mkvirtualenv ansible

# use the virtualenv
workon ansible

# install ansible and its dependencies
pip install ansible
pip install ansible-vault
