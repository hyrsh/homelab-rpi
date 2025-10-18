# Ansible


<p align="center"><img src="../assets/ansible-logo.png" /></p>

To configure multiple hosts I ended up using [Ansible](https://docs.ansible.com/ansible/latest/index.html) and I am very happy with it.

The general idea:

- write human readable syntax that invokes specific [modules](https://docs.ansible.com/ansible/2.9/user_guide/modules_intro.html)
- let it run using a [playbook](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html)
- the target host only has to be reachable by [SSH](https://www.ssh.com/academy/ssh)
- the host only has to have [minimal packages installed](https://docs.ansible.com/ansible/latest/reference_appendices/python_3_support.html#using-python-3-on-the-managed-machines-with-commands-and-playbooks) an **no agent** (which is what I like)

<hr>

## Structure

I use a structure that is not the official and "correct" way, since the official way is focused on a single host that has all sorts of default roles and variables pre-configured and just uses these information outside the actual directory where the magic happens.

My way is something I call "self-contained" Ansible. It does not rely on external or pre-configured roles and variables but has everything within one "main directory" to execute all respective playbooks (this is the name of the file that describes what Ansible should do). With this approach all my Ansible projects become portable and can be shared.

>*This information uses terms not yet explained so maybe come back to it later:*

>There is one thing that is "unusual" in this setup. In all of my playbooks there is a role called ["expose_ssh_keys"](https://github.com/hyrsh/homelab-rpi/blob/main/ansible/roles/expose_ssh_keys/tasks/main.yml) and sadly it is necessary to add. This role converts the private ssh keys of the respective host (or group of hosts) that is called within a playbook from our vault to a file at "/tmp/ansible_exposed_keys/<HOST>.ssh_key". After the playbook run a post-run handler gets invoked to delete this directory so the keys do not exist on your machine anymore.

>It is ugly but necessary since Ansible cannot work with private ssh keys sourced from a variable.

<hr>

## Basics

The simplest structure of a working Ansible directory (written in my style) looks like this:

```shell
-/ansible
  - /group_vars
    - all <-- variable file
  - /roles
    - /debug/tasks
      - main.yml <-- task file for role "debug"
  - playbook.yml <-- Ansible Playbook
  - myvault <-- vault file
```

We will go through all files and see why they are necessary (with examples).

#### Variables

`File: /ansible/group_vars/all`

```yaml
myblock1:
  myvar1: "hello"
```

Ansible uses "variable sourcing" which is a way to consume custom configuration from a file, environment variable or extra-variable. The default path for ansible to look for such files is in the "group_vars" directory ([and many more places](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#understanding-variable-precedence), but we keep it simple for now).

The variables shown in the */ansible/group_vars/all* file can be accessed with the "dot-notation" (e.g. myblock1.myvar1) representing grouping/hierarchical structures. This is important, since we can make our instructions (tasks in roles) highly dynamic (we want that!).

#### Roles

`File: /ansible/roles/debug/tasks/main.yml`

```shell
- name: echo output
  debug:
    msg: "My message!"
```

Roles in Ansible are compact instruction sets of tasks that invoke modules to execute specific actions on a host. In this s