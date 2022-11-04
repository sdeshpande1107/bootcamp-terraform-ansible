# Configuration management using ansible with terraform module

## Using terraform to create infrastructure on azure cloud: 

The repository contains two branches, i.e terraform and ansible. The terraform branch include a module that can be used to create infrastructure on azure. The module contain terraform files to create following infrastructure: 

1. Linux machine availibility set
2. Load balancer
3. Security groups
4. Network
5. Postgres sql server

The terraform branch also include terraform files for two different environments:

1. Staging
2. Production

Both of these environments with their associated parameters can be created by going to their respective directory. In order to view 
the infrastucture that the terraform file will create: 
```bash
terraform plan
```


In order to create the infrastucture: 
```bash
terraform apply
```


When we use above command, terraform will prompt to type "yes" for the confirmation. In order to proceed without the prompt:
```bash
terraform apply -auto-approve
```


In order to destroy the infrastructure;
```bash
terraform destroy
```



## Using ansible to configure group of azure instances to run nodejs weight-tracker application: 

The 'ansible' branch of this repository include playbooks for both the environments which include roles to configure the instances with following applications:

1. NodeJS
2. Weight tracker application. 
   The weight tracker application can be cloned from below github repo:
```bash
https://github.com/reverentgeek/node-weight-tracker.git
```
3. pm2

### Usage

As a first step of configuring remote servers, we need to update the server details such as ip address, okta url and credentials in the variable files. In order to run the playbook: 

```bash
ansible-playbook main.yml -i environments/staging --ask-vault-pass
```

Here we have used the argument '--ask-vault-pass' in order to prompt the playbook to ask for the ansible-vault password. This is provisioned in order to decrypt
the credentials present in the variable files. 

To run the playbook for production environment:

```bash
ansible-playbook main.yml -i environments/production --ask-vault-pass
```



