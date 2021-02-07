#!/bin/bash

pushd $(dirname "$0") > /dev/null

ansible-inventory -i inventory/inventory.aws_ec2.yml --list | jq '._meta.hostvars[] | {name: .tags.Name, public_ip_address: .public_ip_address, private_ip_address: .private_ip_address}'

popd > /dev/null
