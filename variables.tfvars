region = "ap-south-1"   #Put region
ami_id = "ami-02eb7a4783e7e9317" #Ubuntu Instance
instance_type = "t2.micro"  #Enter the instance type and tier
private_key_path = "/home/ubuntu/ub/random-key.pem" #Put the path of the current key-pair you have. eg: /home/ubuntu/ub/dev-key.pem
key_name = "random-key"  #Enter any present EC2 key-pair you have access of.Check your current key pairs at : https://ap-south-1.console.aws.amazon.com/ec2/home?region=ap-south-1#KeyPairs:
vpc_id = "vpc-abcd123"   #Get your VPC id from here : https://ap-south-1.console.aws.amazon.com/vpc/home?#vpcs:
lb_subnet_ids = ["subnet-123a","subnet-456b"]  #Enter list of subnets from 2 different AZ for more redundancy
subnet_id = "subnet-123a" #Enter any public subnet 
security_group_ids = ["sg-805000443"] #Enter the security group ID , make sure it has 80,5000,443 port open for inbounds
local_code_path = "/home/ubuntu/ub/ec2-detailer-terraform" #Put the local code path 
app_name = "ec2-detailer" #Give a name for your app
email_alerts = "u.b.maity@hpvg.com" #Enter organizational emails of techies whom you want to send the alerts in case of failures