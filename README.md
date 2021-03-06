![Puppet Image](https://csccommunity.files.wordpress.com/2016/05/puppet-logo-amber-black-lg.jpg?w=610)

# Puppet Test

Investigating configuring an Ubuntu Linux server using Puppet. 


- .tf files for Puppet Master server: `puppet_master.tf`, `puppet_master_variables.tf`.
- .tf files for Puppet Agent node server: [here](https://github.com/nick-otter/terraform-azure-virtual-machine[]).

## Requirements

Authenticate Azure via the CLI as documented [here](https://www.terraform.io/docs/providers/azurerm/authenticating_via_azure_cli.html).

A Puppet Agent node server which can be created using `Terraform` [here](https://github.com/nick-otter/terraform-azure-virtual-machine[]).

## Usage

Build Puppet Master server:

```aidl
$ terraform apply
```

`SCP` (Secure Copy) installation commands to Puppet Master server:
```aidl
$ scp -i /path/id_rsa install_puppet_server_commands.sh azureuser@< Puppet Master server IP >:
```

`SCP` (Secure Copy) installation commands to Puppet Agent server:
```aidl
$ scp -i /path/id_rsa install_puppet_agent_commands.sh azureuser@< Puppet Agent server IP >:
```

To run installation commands use `$ bash`.



## Notes on Process

As I haven't used Puppet before, I have highlighted parts of the process to use Puppet that are interesting or differ from Ansible.

- I am currently facing an issue with sigining certs - which I have configured via the `/etc/hosts` file.<br><br>
On the Puppet Master server, despite adding the master IP to the agent's `/etc/hosts` file. No certificate requests are evident:
![Puppet Master Certificate Failure](images/Puppet_Master_No_Certificates_To_Sign.png)  <br><br>
On the Puppet Agent server, `ping` to the Puppet Master is not successful (hanging) - this could be the issue:
![Puppet Agent Ping Failure](images/Puppet_Agent_Ping_to_Puppet_master.png)

 

## Links 

- [How To Install Puppet 4 On Ubuntu 16 04](https://www.digitalocean.com/community/tutorials/how-to-install-puppet-4-on-ubuntu-16-04)
- [Why is the /etc/hosts file not working?](https://askubuntu.com/questions/347152/why-is-the-etc-hosts-file-not-working)