## Tally-Ho Sample Deployment

### Architecture
The sample deployment runs on two application servers and one database server with an attached network storage.
![](/Docs/img/tally_ho_loadbalanced_architecture.png)

### Deployment

To create the sample architecture we use [vagrant](https://www.vagrantup.com/) which helps us create a virtual machine for each of the components.

To run the sample architecture, you will need to have [virtualbox](https://www.virtualbox.org/) installed before using vagrant.

Once you have Vagrant installed, make sure you have [Ansible](https://www.ansible.com/) installed. We use ansible to provision the sample deployment.

Once you have all the prerequisites installed, you can run the following commands to create the sample infrastructure.

```
./bring-up.sh
```

This will create the sample deployment by running `vagrant up`. The script creates the virtual machines on virtualbox and provisions them with our ssh keys, then creates an `ubuntu` user with sudo privileges.

This user can then run the `ansible-playbook` command to provision the sample deployment.

After the sample infrastructure is created, you can run the following commands to see the status of the infrastructure.

```
vagrant status
```

This is a sample output of the `vagrant status` command.

```
Current machine states:

app1                      running (virtualbox)
app2                      running (virtualbox)
database                  running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

## Provisioning the sample deployment

Once we have the sample infrastructure created, we can provision the sample deployment using Ansible.

Make sure to install the ansible-galaxy requirements in the [ansible/requirements.yml](ansible/requirements.yml) file.

```
ansible-galaxy install -r ansible/requirements.yml
```

