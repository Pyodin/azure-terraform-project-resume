"# azure-terraform-project-resume" 
# azure-terraform-project-resume

## Description

This project automates the creation of a Virtual Machine (VM) on Microsoft Azure for development purposes using Terraform. It includes the creation of the following components:

- A **resource group**
- A **virtual network**
- A **subnet**
- A **security group**
- A **security rule**
- A **public IP**
- A **VM**

The `~/.ssh/config` file on your computer is also automatically updated to enable easy access to the VM using Visual Studio Code (VSCode).

The goal of this project is to save you time and effort in setting up a development environment on Azure. With just a few commands, you can have a fully functional VM up and running, ready for you to start coding.


## Prerequisites

Before you begin, make sure you have the following:

- [Microsoft Azure account](https://azure.microsoft.com/)
- [Terraform](https://www.terraform.io/downloads.html) installed (make sure it is in your PATH if you are on windows)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- [Visual Studio Code](https://code.visualstudio.com/) installed with the [Remote-SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) installed and enabled

You will also need to generate a public/private key pair to SSH into the VM. By default, it uses `~/.ssh/id_rsa` If you don't already have one, use:
```
ssh-keygen -t rsa
```


## Getting Started

To get started, follow these steps:

1. Clone the repository, navigate to the project directory and open the repository in Visual Studio Code:

```
git clone https://github.com/Pyodin/azure-terraform-project-resume.git
cd azure-terraform-project-resume
code .
```


2. Set up your Azure credentials by running the following command and following the prompts:


```
az login
```

3. Initialize the Terraform configuration:

```
terraform init
```

4. Modify the `terraform.tfvars` file to suit your needs. This file includes variables such as the VM size, the number of VMs to create, and the location of the Azure datacenter.

5. Apply the Terraform configuration to create the VM:

```
terraform apply --auto-approve
```

6. Once the VM is created, the ~/.ssh/config file on your computer will be updated automatically. You can now use VSCode to connect to the VM by using the Remote-SSH extension.

7. For destruction, use:

```
terraform destroy --auto-approve
```


## Security

By default, the security group allows inbound traffic on port 22 (SSH) from any IP address. To restrict SSH access to specific IP addresses, you can modify the security rule in main.tf. For example, you can change the source_address_prefix parameter to allow inbound traffic only from a specific IP range.

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
