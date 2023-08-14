- [nginx-webserver](#nginx-webserver)
  - [Role Variables](#role-variables)
  - [Example Playbook](#example-playbook)
  - [License](#license)
  - [Author Information](#author-information)

nginx-webserver
===============

This role sets up an Nginx web server on Azure virtual machines (Ubuntu). It installs Nginx, configures it to serve  editable static content, and manages the service.

Role Variables
--------------

Following variable table is supported within this ansible role.

| Name                | Description                                                  | Default Value                                        | Type      | Required                                  |
|---------------------|--------------------------------------------------------------|------------------------------------------------------|-----------|-------------------------------------------|
| `dynamic_hosts`     | Hosts on which this role should run.                         | `role_slave_webservers`                              | `string`  | No, only relevant to dynamic inventories. |
| ``github_username`` | GitHub username associated with the Github logo on site.     | `ishuar`                                             | `string`  | No                                        |
| `linkedin_username` | LinkedIn username associated with the LinkedIn logo on site. | `ishuar`                                             | `string`  | No                                        |
| `webserver_message` | Webserver message visiable as the top heading.               | `Welcome to Demo site for Terraform Ansible project` | `string`  | No                                        |
| `enable_firewall`   | Whether to enable OS level Ufw (firewall) or not             | `false`                                              | `boolean` | No                                        |

Example Playbook
----------------

```yaml
- name: Set up Nginx Webserver on Ubuntu machine
  gather_facts: true
  remote_user: "{{ remote_user }}"
  hosts: "{{ hosts }}"
  become: true
  connection: ssh
  ## Variables If you want to over-ride defaults..
  # vars:
  #   dynamic_hosts:
  #   github_username:
  #   linkedin_username:
  #   webserver_message:
  #   enable_firewall:
  roles:
   - nginx-webserver
```

License
-------

MIT

Author Information
------------------

Checkout my portfolio site at [here](https://ishan.learndevops.in/)
