## Ansible

[Ansible](https://www.ansible.com/) is the tool Ona uses to automate software provisioning, configuration management, and application deployment. It offers several advantages over other IT automation tools similar to it; It's minimal in nature, you don't need to install anything on the servers you're deploying to (except Python 2), and has an easy learning curve[1].

The most atomic of components in Ansible is a _task_. A task can be viewed as a codified action. This could, for instance, be a codified action to make sure file A is copied to location B on the server Ansible is running against. More formally the Ansible documentation defines a task as _"a call to an ansible module"_. In the example I've given above, the call will be to the [copy](https://docs.ansible.com/ansible/latest/modules/copy_module.html) module.

We try as much as possible to follow Ansible best practices[2]. This document touches on some of these. Use it as your guide as you define Ansible playbooks for your deployment.

### Repository Directory Structure

UNICEF's Ansible git repository has the following files and directories in its root directory:

 - `roles/`: Directory containing [Ansible roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html) maintained by Ona. The next section will focus on how to define roles
 - `files/`: Directory containing files shared between the different playbooks.
 - `tasks/`: Directory containing tasks shared between the different playbooks. These files contain lists of tasks that
 - `docs/`: Contains documentation on our different deployments.
 - `inventories/`: Contains inventories used with the playbooks.
 - `dependencies/`: Contains Python Pip and Ansible Galaxy dependencies required to run the Ansible playbooks in the repository.
 - `*.yml`: These are mainly playbooks (some like .travis.yml are configuration files for CI).

### Roles

Ansible allows grouping of tasks into roles. Grouping tasks into roles:

1. Adds structure to the repository. This allows for easier maintaining of the repository.
2. Allows for easy reuse of the tasks in other roles and playbooks.

[This](https://github.com/onaio/ansible-role) GitHub repository template is available for you to use for your role repositories. Check its [documentation](https://github.com/onaio/ansible-role/blob/master/TEMPLATE.md) on how to create a GitHub repository from a repository template and what to do after creating your repository from the template.

Ansible roles have the following sub-directories:

#### 1. tasks/

This directory contains files with lists of tasks to be executed. The task file `tasks/main.yml` is required and is automatically executed by Ansible. All other task files have to be explicitly imported from the t. Though you could put all your tasks in `tasks/main.yml` it's recommended to group the tasks further into separate files. In a role for deploying an application you've written, you'd probably have three extra task files, `tasks/compile.yml`, `tasks/install.yml`, and `tasks/configure.yml` with these three task files called from the `tasks/main.yml` file using the [`include_tasks`](https://docs.ansible.com/ansible/2.4/include_tasks_module.html) Ansible module.

#### 2. defaults/

This directory contains files with default values for variables used by the role. All default values in the file `defaults/main.yml` are imported by default. You can, however, have extra variable files that get imported by an `[include_vars](http://docs.ansible.com/ansible/latest/modules/include_vars_module.html)` task in the role. As an example, if your role is to be deployed on either Debian and RHEL hosts (and some default variables differ between the two OS types), you'd have a `defaults/debian.yml` and a `defaults/rhel.yml` file the respective default values for the two OS types. You'd then have a task in `tasks/main.yml` importing either of the two files that looks like this:

```
- name: Include OS-specific default variables
  include_vars: "defaults/{{ ansible_os_family }}.yml"
```

#### 3. vars/

This directory is similar to `defaults/` in that it contains files with variable values to be used in the role. However, the values specified in this directory cannot be overridden. It's therefore recommended to put variables that don't need to be exposed to inventory files here.

#### 4. templates/

Put Jinja2 template files to be used by your role here. Since these are template files, make sure you set their file extension to `.j2`. A template file for `service.conf` would, therefore, be `service.conf.j2`. The directory structure of the templates directory should also be reflective of the destination directories on the ansible hosts. For example, if a template is to be copied over to `/etc/` on the ansible hosts, then it should be kept in `templates/etc/`.

#### 5. files/

Put files that are to be used by the role as is here. For files that are to be copied over to the ansible hosts, put them in subdirectories that are reflective of the destination directories on the ansible hosts. For example, if a file is to be copied over to `/var/lib/collectd` on the ansible host, it should be kept in `files/var/lib/collectd/`.

#### 6. handlers/

This directory stores files containing lists of handlers. By default all handlers in `handlers/main.yml` are available. Handlers are similar to tasks in that they can be assigned to names and they call Ansible modules. However, unlike tasks, handlers are not executed by default. They require a special notification to be sent for them to execute. Such notifications are sent from tasks using the `notify` directive. A handler is referenced from the notify directive using either its name or what the handler has specified in its `register` directive. For instance, if you define a handler:

```
- name: this is the handler name
  debug:
    msg: "Print something"
```

You can then notify the handler to execute from a task this way:

```
- copy:
    src: files/etc/somefile
    dest: /etc/somefile
  notify:
    - this is the handler name
```

Some things to note about handlers:

- A handler will execute only once, even if notified more than once.
- Handlers are, by default, executed at the end of executing a playbook (after all the tasks have executed).
- A handler will not execute if the task that notifies it does not make a change.
- If a handler is triggered to run, it will, even if a task during the process of running `ansible-playbook` fails.
- Handlers are available across roles. You can, therefore, notify a handler defined in role A from another role B.

Handlers work well for actions like service restarts since these are normally dependent on another action successfully executing. For instance, you only need to restart NGINX if any of its configuration files changes. Otherwise, restarting NGINX would have no benefit.

#### 7. meta/

The `meta/main.yml` contains the role's metadata:

1. The role's Ansible Galaxy information (author, description, license, supported platforms).
2. Any roles this role is dependent on. They'll be executed before the current role starts executing.

If a role is fetched from Ansible Galaxy (using the `ansible-galaxy` command), the file `meta/.galaxy_install_info` is created. It contains the role's version date the role is fetched from Ansible Galaxy.

### Inventories

Our inventories are split based on service owners, and their server environments.

Possible service owners include:

 - personal (for your personal inventories, this is ignored by source control)
 - unicef-eapro

And environments:

 - production
 - preview
 - stage

The inventory directory structure, hence, looks like:

```
inventories/
│── dynamic-inventory-scripts
│   └── ...
│── [Owner 1]
│   │── [Environment 1]
│   │   │── azure_rm.yml
│   │   │── group_vars
│   │   │── hosts
│   │   └── host_vars
│   .
│   .
│   .
│   └── [Environment m]
│       └ ...
.
.
.
└── [Owner n]
    └ ...
```

#### Hosts File

The hosts file (file named `hosts` in each of the environment directories) is where you would group your hosts into groups they belong to, and group groups into other larger groups. It follows the [INI file format](https://en.wikipedia.org/wiki/INI_file). You can, therefore, define variables that would apply to the host or group you've defined them against. However, please avoid defining variables (beyond which user and IP to use to connect to a host) here.

#### Inventory Plugins

> It is recommended, when you can, to use inventory plugins and not dynamic inventory scrips. The two Ansible features, however, work in a very similar way. Most of the following documentation also applies for dynamic inventory scripts.

The [inventory plugins]((https://docs.ansible.com/ansible/latest/plugins/inventory.html)), starting Ansible 2.8, are used by Ansible to enrich inventories using data from other sources. For example, Ansible can import IP addresses and domain names for Azure VM instances it should run against in an inventory from the Azure API using the azure_rm inventory plugin.

For you to use the azure_rm inventory plugin, make sure its enabled in the [ansible.cfg](../ansible.cfg) file in the inventory section using the enable_plugins variable:

```ini
[inventory]
enable_plugins = ..., azure_rm
```

In your inventory, place a file named `azure_rm.yml` that looks like this:

```yml
---
plugin: azure_rm
include_vm_resource_groups:
- production
auth_source: cli

keyed_groups:
- prefix: tag
  key: tags
```

Make sure to:
1. Leave the `keyed_groups` variable as is if you intend for the plugin to generate groups as described above.
2. Set `include_vm_resource_groups` with the resource groups you want to target
3. Leave `auth_source` as is to use Azure CLI to authenticate

### Requirements

We keep both our Python Pip and Ansible Galaxy requirements in the [ansible/requirements](../ansible/requirements) directory. Pip requirements are tracked in the [ansible/requirements/base.pip](../ansible/requirements/base.pip). If you ever update the pip requirements please make sure you update this file by running ` pip-compile --output-file ansible/requirements/base.pip ansible/requirements/base.in`.

Ansible Galaxy requirements are tracked in the [ansible/requirements/ansible-galaxy.yml](../ansible/requirements/ansible-galaxy.yml) file. When adding a new Ansible Galaxy requirement, please make sure to include the version or commit hash that you've installed. When tracking roles using commit hashes, use the following format for in the requirements file:

```
roles:
  - src: <Git URL for the repository>
    name: <Name to give the role>
    version: <Commit hash>
    scm: git
collections:
  - name: <Git URL for the repository>
    type: git
    version: <version for collection>
```

It is highly recommended that you install your pip requirements in a Python virtualenv. You can use wrap-around scripts like [virtualenvwrapper](https://pypi.org/project/virtualenvwrapper/) to create the virtualenv or run the following command to create a virtualenv called `infraunicef` using Python3:

```sh
mkdir ~/.virtualenvs
python3 -m venv ~/.virtualenvs/infraunicef
```

You can then activate the virtualenv by running:

```sh
source ~/.virtualenvs/infraunicef/bin/activate
```

While inside your virtualenv, install all the requirements by running:

```sh
pip install -r ansible/requirements/base.pip
ansible-galaxy role install -r ansible/requirements/ansible-galaxy.yml -p ~/.ansible/roles/infraunicef
ansible-galaxy collection install -r ansible/requirements/ansible-galaxy.yml -p ~/.ansible/collections/infraunicef
```

### Playbooks

At a bare minimum, a playbook file specifies which roles to run, and on which group of hosts to run the roles. We recommend that you define a playbook file for every deployed service. You'd, therefore, have a playbook for setting up Onadata and another for setting up Zebra.

You can specify in your playbook file a list of tasks to run before the roles are run and another list to run after. You can also do other neat tricks like force Ansible to run on one host at a time (when you want to do rolling releases) using the `serial` directive.

Here's an example playbook:

```
---
- hosts: service-a-servers
  serial: 1 # Runs playbook one server at at time (to achieve a rolling update)
  max_fail_percentage: 0 # Don't continue deploying on other hosts if playbook fails on one
  gather_facts: true
  become: true
  pre_tasks:
    - include_tasks: tasks/slack-start.yml
      when: slack_notifications
  roles:
    - service-a
  post_tasks:
    - include_tasks: tasks/slack-end.yml
      when: slack_notifications
```

Please note that in the example playbook above we've specified that the playbook can only run on hosts that are part of the `service-a-servers` group. Please avoid setting this value to names of groups that include hosts that you wouldn't want to install `service-a`.

We keep all our playbook files in the repository's root directory. This gives them access to the shared [files](../files) and [tasks](../tasks).

### References
1. [Ansible: Up and Running](https://drive.google.com/file/d/0B5XilAja9Ex5VDNKQUZxeUktMEU/view)
2. [Best Practices - Ansible Documentation](http://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
3. [Ansible User Guide](http://docs.ansible.com/ansible/latest/user_guide/)
