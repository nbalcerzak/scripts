#!/bin/bash
# Set the variables for your environment, vpc_dns should always be x.x.x.2 of your subnet.
vpc_dns=10.40.136.2

# Domain / security context: (lab, corp, prod, pci)
sec_context=corp

domain1=domain1.com
domain1_dns=ldap.${sec_context}.domain1.com

domain2=domain2.com
domain2_dns=ldap.${sec_context}.domain2.com

# Install updates and dependencies
yum update -y
yum install -y gcc openssl-devel expat-devel unbound bind-utils

# Backup original conf file
mv /etc/unbound/unbound.conf /etc/unbound/unbound.conf.bak

# Write Unbound configuration file with values from variables
cat <<EOF | tee /etc/unbound/unbound.conf
server:
        interface: 0.0.0.0
        access-control: 0.0.0.0/0 allow
forward-zone:
        name: "."
        forward-addr: ${vpc_dns}
forward-zone:
        name: "${domain1}"
        forward-host: ${domain1_dns}
forward-zone:
        name: "${domain2}"
        forward-host: ${domain2_dns}
EOF

systemctl enable unbound
systemctl restart unbound
