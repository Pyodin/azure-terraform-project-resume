# azure-terraform-project-resume

## Description
This is a simple project combining terraform and azure.
The aim of this project is to create a dev environment using both these technologies.
This project runs both on linux and windows os.

## What you need
- Terraform (make sure it is in your PATH if you are on windows)
- An Azure account (I used the free subscription)
- Vscode IDE with remote-ssh plugin

## Technologies
To create this environment, I used:
- a linux virtual machine
- a resource group
- a virtual network
  - a subnet
  - a security group configured to provide a public ip
  - a network interface
  
## How to use
### For creation
`terrafor apply --auto-approve`
### For destruction
`terraform destroy --auto-approve`

Once the vm created, the public ip address appears on the screen. It is also added to the file `.ssh\config` (config file for the remote-ssh plugin of vscode).
You can then log into your vm uning this plugin.
