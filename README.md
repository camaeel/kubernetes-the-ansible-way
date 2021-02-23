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
This project uses ansible configuration in `ansible` directory to configure virtual machines and install kubernetes. Ansible retrives AWS EC2 instances using dynamic inventory (configured in `ansible/inventory/inventory.aws_ec2.yml` and `ansible/inventory/group_vars/*`)

## Initial setup
Install requirements:
1. Install ansbible
1. Install kubectl v1.20+
1. Install python libraries: boto3, botocore
1. Provide AWS credentials to ansible
1. (optional) install pdmenu

## Setup helpers on your local machine
1. You can generate additional file for pdmenu. You can add it to your menu or use it as your main menu to easily access instances without copy-pasting ip addresses.
    1. Run `ansible-playbook -i inventory/inventory.aws_ec2.yml 0_helpers.yml`
    1. Add to your menu in `.pdmenurc` file: `show:_K8s ansible way..::k8s_ansible_way`
    1. Add at the end of your `.pdmenurc` file: `/home/kamil/.k8s_ansible_way_pdmenurc` (don't forget to adjust username in the path)

## Prepare EC2 instances
This step updates VMs OS, installs required packages, disables swap. 

Run `ansible-playbook -i inventory/inventory.aws_ec2.yml 1_prepare_vms.yml`

## Prepare loadbalancer
This step provisions simple nginx TCP loadbalancer on dedicated host. It could be replaced by cloud providers native solution. 

Run: `ansible-playbook -i inventory/inventory.aws_ec2.yml 2_prepare_lb.yml`

## Install controlplane and worker nodes

Run: `ansible-playbook -i inventory/inventory.aws_ec2.yml 3_install_k8s.yml`

# Smoke tests

1. Test secret encryption
    1. Create secret: `kubectl create secret generic kubernetes-the-hard-way --from-literal="mykey=mydata"`
    1. Test if secret is encrypted (on controlplane node): `ETCDCTL_API=3 etcdctl get --endpoints=https://127.0.0.1:2379 --cacert=/etc/pki/k8s/ca.crt   --cert=/etc/pki/k8s/etcd-server.crt   --key=/etc/pki/k8s/etcd-server.key  /registry/secrets/default/kubernetes-the-hard-way  | grep 'k8s:enc:aescbc'` - should return 0
1.  Test deployments:
    1. Create deployment: `kubectl create deployment nginx --image=nginx`
    1. `kubectl get pods -l app=nginx`

1. Services:
    1. Expose port: `kubectl expose deploy nginx --type=NodePort --port 80`
    1. Get node port: `PORT_NUMBER=$(kubectl get svc -l app=nginx -o jsonpath="{.items[0].spec.ports[0].nodePort}")`
    1. Test request (on each worker node): `curl http://worker-1:$PORT_NUMBER`
1. Logs: `kubectl logs $(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")`
1. Exec: `kubectl exec -ti $(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}") -- nginx -v | grep -E "^nginx version: nginx/.*"` - should return 0

# Cleanup
The easiest way to cleanup the project is to use terraform to destroy de infrastructure. In `terraform` directory run `terraform destroy`

