# EC2 Instance Creation
provider "aws" {
  region = var.region
}

resource "aws_instance" "ec2_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  user_data     = <<-EOF
    #!/bin/bash
    sudo mkdir /home/ubuntu/${var.app_name}
    cd /home/ubuntu/${var.app_name},
    sudo apt-get update,
    sudo systemctl start docker,
    sudo docker-compose up -d
  EOF

  tags = {
    Name = "hv-terraform-instance"
  }
}

resource "null_resource" "copy_code" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.private_key_path}")
    host        = aws_instance.ec2_instance.public_ip
  }

  provisioner "file" {
    source      = "${var.local_code_path}"
    destination = "/home/ubuntu/${var.app_name}"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ubuntu/${var.app_name}",
      "sudo apt-get update",
      "sudo apt-get install python3 -y",
      "sudo apt-get install python3-pip -y",
      "sudo apt-get install docker.io -y",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo apt-get install -y docker-compose",
      "sudo docker-compose up -d"
    ]
  }
}

# Elastic IP

resource "aws_eip" "eip" {
  vpc      = true
  instance = aws_instance.ec2_instance.id

  tags = {
    Name = "hv-static-ip"
  }
}

output "elastic_ip" {
  value = aws_eip.eip.public_ip
}

#----------------------------------EC2 instance created and codebase uploaded to ec2 --------------------------------

#load balancer creation

resource "aws_lb" "my-loadbalancer" {
  name               = "hv-app-loadbalancer"
  internal           = false
  load_balancer_type = "application"

  subnet_mapping {
    subnet_id = var.lb_subnet_ids[0]
  }

  subnet_mapping {
    subnet_id = var.lb_subnet_ids[1]
  }

  tags = {
    Name = "hv-app-lb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my-loadbalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_aws_lb_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "my_aws_lb_target_group" {
  name_prefix      = "hv-tg"
  port             = 80
  protocol         = "HTTP"
  target_type      = "instance"
  vpc_id           = var.vpc_id
  deregistration_delay = 10

  health_check {
    path     = "/health"
    protocol = "HTTP"
  }

  depends_on = [
    aws_lb.my-loadbalancer
  ]
}

resource "aws_lb_target_group_attachment" "my-target-group-instances" {
  target_group_arn = aws_lb_target_group.my_aws_lb_target_group.arn
  target_id        = aws_instance.ec2_instance.id
  port             = 80
}

output "Elastic_Load_Balancer_DNS" {
  value = aws_lb.my-loadbalancer.dns_name
}

#-----------------------------Loadbalancer attached with ec2 and added ec2 to the target group ---------------


#Creating SNS topic for unhealthy host alerts
resource "aws_sns_topic" "my-sns-topic" {
  name = "hv-sns-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.my-sns-topic.arn
  protocol  = "email"
  endpoint  = var.email_alerts
}

resource "aws_cloudwatch_metric_alarm" "my-cloudwatch-metric-alarm" {
  alarm_name          = "hv-ec2detailer-unhealthy-host-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "hv-UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors the count of unhealthy hosts in the target group."
  alarm_actions       = [aws_sns_topic.my-sns-topic.arn]

  dimensions = {
    LoadBalancer = "${aws_lb.my-loadbalancer.arn_suffix}"
    TargetGroup  = "${aws_lb_target_group.my_aws_lb_target_group.arn_suffix}"
  }

}

output "SNS_topic_used" {
  value = aws_sns_topic.my-sns-topic.arn
}