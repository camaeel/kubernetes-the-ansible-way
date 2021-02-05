# Intro
Install kubernetes "the hard way" using ansible playbooks. 

Project was inspired by [Kelsey Hightower's: Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) and [Mumshad Mannambeth's: Kubernetes the hard way](https://github.com/mmumshad/kubernetes-the-hard-way) repositories.

It was created only for educational purposes and it should **NOT** be considered as production ready.

## Infrastructure provider

This project uses AWS as default infrastructure provider. If you prefer to use another infrastructure provider, you should configure access keys, infrastructure (manually or using terraform) and ansible inventory by yourself. Feel free to fork this project and add your prefered infrastructure.

# Initial setup
Before you start you should provide some configuration
1. Provide AWS credentials as described in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
1. Install terraform
1. specify terraform backend to store terraform state in `terraform/backend.tf` (sample template file in `terraform/backend.tf.template`)
1. provide in file `terraform/terraform.tfvars` your public key used to authorize connections to instances (sample template in `terraform/terraform.tfvars.template`)
1. (optionally) override variables defined in terraform in `terraform/*.tfvars` files
1. Run `terraform init` to initialize terraform

# Provision infrastructure

The first step is to prepare infrastructure for the Kubernetes cluster. I chose AWS as a cloud provider. Infrastructure can be easily created by using included terraform project (in `terraform` directory)

## Configure infrastructure
Infrastructure can be customized by defining variables (from in `terraform/variables.tf`) in `terraform/*.tfvars` files. For example you can override number of controlplane instances. As a default backend I'm using S3. You can configure your bakend by creating `terraform/backend.tf` file (from provided template: `terraform/backend.tf.template`) or with terraform parameters according to https://www.terraform.io/docs/language/settings/backends/configuration.html. 

## Execute 
1. Run: `terraform plan`
1. Review the changes
1. Apply then by running: `terraform apply` and answer 'yes'

# Install kubernetes
This project uses ansible configuration in `ansible` directory to configure virtual machines and install kubernetes. Ansible retrives AWS EC2 instances using dynamic inventory (configured in `ansible/inventory.aws_ec2.yml` and `ansible/group_vars/*`)

## Initial setup
Install requirements:
1. Install ansbible
1. Install kubectl v1.20+
1. Install python libraries: boto3, botocore
1. Provide AWS credentials to ansible

## Prepare EC2 instances
This step updates VMs OS, installs required packages, disables swap. 
TODO...

Run `ansible-playbook -i inventory.aws_ec2.yml 1_prepare_vms.yml`

## Install controlplane and worker nodes

# Cleanup
The easiest way to cleanup the project is to use terraform to destroy de infrastructure. In `terraform` directory run `terraform destroy`

