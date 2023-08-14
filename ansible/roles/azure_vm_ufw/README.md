- [azure-vm-ufw](#azure-vm-ufw)
  - [Role Variables](#role-variables)
  - [Example Playbook](#example-playbook)
  - [License](#license)
  - [Author Information](#author-information)

azure-vm-ufw
============

The [`azure_vm_ufw`](./roles/azure_vm_ufw/) role is designed to manage the Uncomplicated Firewall (UFW) on Azure virtual machines. This role ensures that the required ports are open and rules are set according to your specifications.

Role Variables
--------------

Following variable table is supported within this ansible role.

| Name               | Description                                                                                                                                               | Type      | Default           |
|--------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|-------------------|
| `azure_service_ip` | Azure Service IP , ref to[`what-is-ip-address-168-63-129-16`](`https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16`) | `string`  | `"168.63.129.16"` |
| `tcp_port_range`   | TCP Port Range allowed in Firewall between VM and Azure Service IP for inbound and oubound traffic                                                        | `string`  | `80:65535`        |
| `udp_port_range`   | UDP Port Range allowed in Firewall between VM and Azure Service IP for inbound and oubound traffic                                                        | `string`  | `53:53`           |
| `enable_firewall`  | Whether to enable OS level Ufw (firewall) or not                                                                                                          | `boolean` | `false`           |



Example Playbook
----------------

```yaml
- name: Set up Basic Ufw on Azure Ubuntu machine
  gather_facts: true
  remote_user: "{{ remote_user }}"
  hosts: "{{ hosts }}"
  become: true
  connection: ssh
  ## Variables If you want to over-ride defaults..
  # vars:
  #   azure_service_ip: "168.63.129.16"
  #   tcp_port_range:
  #   linkedin_username:
  #   udp_port_range:
  #   enable_firewall:
  roles:
   - azure-vm-ufw
```

License
-------

MIT

Author Information
------------------

Checkout my portfolio site at [here](https://ishan.learndevops.in/)