# EC2-Detailer

Terraform code for deploying a flask application which retrieves EC2-metadata associated with it.
Example:
1. Instance ID
2. IP address
3. Mac Address

These are the following actions this repository does:

- Creates an EC2 instance with static IP
- Uploads the Flask code , Dockerizes it along with nginx reverse-proxy at port 80 and initialzes the application
- Creates a load balancer to handle the traffic with /health as health-endpoint
- Connects load balancer to the EC2 as target group
- Creates an SNS topic
- Creates a Cloudwatch metric alarm and connects it with the SNS for alerts

## Contents

Terraform:
- variables.tfvars: Configure and change the variables on the variable.tfvars file according to your cloud Resources. 
- variables.tf: to add new variables , add it in variables.tf first
- main.tf: To add a new resources , check main.tf

 Application/Code: 
- app.py : contains basic flask app for retrieviing ec2-metadata and also has a /health endpoint
- Dockerfile: packages the flask app
- docker-compose: contains configurations for building the flask image with nginx connected
- nginx.conf : responsible for reverse proxying the flask app alive on 5000 to port 80 of both loadbalancer as well as ec2-publicIP
- requirements.txt: for installing dependencies 


## Usage
Prequisites: 
1. Install Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. Change the variables from variables.tfvars file

    - Initialize Terraform: ```Terraform init```
    - Preview Terraform changes: ```terraform plan -var-file=variables.tfvars ```
    - Apply Terraform changes: ```terraform apply -var-file=variables.tfvars```
    - Destroy Terraform infrastructure: ```terraform destroy -var-file=variables.tfvars```
    - Show Terraform state: ```terraform show```
    - Validate Terraform configuration files: ```terraform validate```
    - Format Terraform configuration files: ```terraform fmt```
    - Refresh Terraform state: ```terraform refresh```

## Endpoints to reach for the application

1. Health endpoint : ```http://<load-balancer-public-ip>/health```
2. Application: ```http://<load-balancer-public-ip>```  or  ```http://<ec2-static-public-ip>```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9 |

## Modules

No modules.


## License

MIT Licensed. See [LICENSE](https://github.com/ec2-detailer-terraform/tree/main/LICENSE) for full details.

## Author
 
 Module is maintained by [Uddhabendra Maity](linktr.ee/ub_maity)