locals {
  subnet_tier = "app"
  role        = "bastion"
  application = "bastion"
  user_data   = <<-EOT
  #!/bin/bash
  set -ex
  DEBIAN_FRONTEND=noninteractive sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
  echo 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongod.list
  DEBIAN_FRONTEND=noninteractive sudo apt-get -y update
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y mongodb-org-shell libmemcached-tools postgresql-client redis-tools mysql-client python3-pip
  python3 -m pip install --upgrade awscli ansible pip
  sudo snap start amazon-ssm-agent
  EOT
}

