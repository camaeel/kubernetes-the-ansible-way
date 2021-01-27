# Intro
Install kubernetes "the hard way" using ansible playbooks. 

Project was inspired on [Kelsey Hightower's: Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way) repository.

It was created only for educational purposes and it should **NOT** be considered as production ready.

# Prepare cloud infrastruture
The first step is to prepare infrastructure for the Kubernetes cluster. I chose AWS as a cloud provider. Infrastructure can be easily created by using included terraform project (in `terraform` directory)



# Cleanup
The easiest way to cleanup the project is to use terraform to destroy de infrastructure. In `terraform` directory run `terraform destroy`

