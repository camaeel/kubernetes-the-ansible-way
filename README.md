# Intro
Install kubernetes "the hard way" using ansible playbooks. 

Project was inspired on [Kelsey Hightower's: Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) repository.

It was created only for educational purposes and it should **NOT** be considered as production ready.

## Infrastructure provider

This project uses AWS as default infrastructure provider. If you prefer to use another infrastructure provider, you should configure access keys, infrastructure (manually or using terraform) and ansible inventory by yourself. Feel free to fork this project and add your prefered infrastructure.

# Initial setup
Before you start you should provide some configuration
1. Provide AWS credentials as described in: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
1. TODO: specify terraform backend
1. override variables defined in terraform

# Provision infrastructure

The first step is to prepare infrastructure for the Kubernetes cluster. I chose AWS as a cloud provider. Infrastructure can be easily created by using included terraform project (in `terraform` directory)

## Configure infrastructure
Infrastructure can be customized by defining variables (from in `terraform/variables.tf`) in `terraform/*.tfvars` files. For example you can override number of controlplane instances. As a default backend I'm using S3. You can configure your bakend by creating `terraform/backend.tf` file (from provided template: `terraform/backend.tf.template`) or with terraform parameters according to https://www.terraform.io/docs/language/settings/backends/configuration.html. 


# Cleanup
The easiest way to cleanup the project is to use terraform to destroy de infrastructure. In `terraform` directory run `terraform destroy`

