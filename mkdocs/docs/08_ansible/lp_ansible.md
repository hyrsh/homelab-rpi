# Ansible

To configure multiple hosts I figured out over my years working with distributed infrastructure that [Ansible](https://docs.ansible.com/ansible/latest/index.html) is the leader in this segment and I am very happy with it.

The general idea of it is to write human readable blocks of configuration in a very simple syntax and execute it on a host using SSH connections. The target host only has to be reachable by SSH and has python installed (which is shipped by default with nearly all available Linux OS).

## Structure

I use a structure that is not the official and "correct" way, since the official way is focused on a single host that has all sorts of default roles and variables pre-configured and just uses these information outside the actual directory where the magic happens.

My way is something I call "self-contained" Ansible. It does not rely on external or pre-configured roles and variables but has everything within one "main directory" to execute all respective playbooks (this is the name of the file that describes what Ansible should do). With this approach all my Ansible projects become portable and can be shared.

>*This information uses terms not yet explained so maybe come back to it later:*

>There is one thing that is "unusual" in this setup. In all of my playbooks there is a role called ["expose_ssh_keys"](https://github.com/hyrsh/homelab-rpi/blob/main/ansible/roles/expose_ssh_keys/tasks/main.yml) and sadly it is necessary to add. This role converts the private ssh keys of the respective host (or group of hosts) that is called within a playbook from our vault to a file at "/tmp/ansible_exposed_keys/<HOST>.ssh_key". After the playbook run a post-run handler gets invoked to delete this directory so the keys do not exist on your machine anymore.

>It is ugly but necessary since Ansible cannot work with private ssh keys sourced from a variable.

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