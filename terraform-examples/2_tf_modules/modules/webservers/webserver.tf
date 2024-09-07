resource "aws_security_group" "webWebServerSecurityGroup" {
  name        = "allow_ssh_http"
  description = "Allow SSH http inbound traffic"
  vpc_id      = var.web_vpc_id

  tags = {
    Name    = "webWebServerSecurityGroup"
    Project = var.project
  }

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  //egress rules
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1" //all
    cidr_blocks = ["0.0.0.0/0"] //All
  }
}


resource "aws_alb" "webLoadBalanacer" {

  name = "webLoadBalanacer"
  load_balancer_type = "application"
  subnets            = [var.web_public_subnets[0], var.web_public_subnets[1]]
  security_groups    = [aws_security_group.webWebServerSecurityGroup.id]
  tags = {
    Name    = "webLoadBalancer"
    Project = var.project
  }
}
resource "aws_alb_listener" "webLbListner" {

  load_balancer_arn = aws_alb.webLoadBalanacer.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.webALBTargetGroup.id
    type             = "forward"
  }
}
resource "aws_alb_target_group" "webALBTargetGroup" {
  name     = "web-ALB-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.web_vpc_id

  health_check {
    path                = "/var/www/html/hc.html"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 10
    unhealthy_threshold = 10
    port = 80
  }

  tags = {
    Name    = "web Load Balancer TargetGroup"
    Project = var.project
  }
}
resource "aws_alb_target_group_attachment" "webserver1TG" {
  target_group_arn = aws_alb_target_group.webALBTargetGroup.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}
resource "aws_alb_target_group_attachment" "webserver2TG" {
  target_group_arn = aws_alb_target_group.webALBTargetGroup.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_instance" "webserver1" {
  
  ami                         = var.web_server.web_ami_id
  instance_type               = var.web_server.instance_type
  key_name                    = var.web_server.key_name
  subnet_id                   = var.web_public_subnets[0]
  security_groups             = [aws_security_group.webWebServerSecurityGroup.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash -xe
              sudo su
              yum update -y
              yum install -y httpd
              yum install amazon-cloudwatch-agent
              echo "<h1>Hello, World</h1>servere: webServer1" > /var/www/html/index.html
              echo "healthy" > /var/www/html/hc.html
              # start httpd 
              service start httpd
              chkconfig httpd on
              EOF

  tags = {
    Name    = "Public Web Server 1"
    Project = var.project
  }
}

resource "aws_instance" "webserver2" {
  ami                         = var.web_server.web_ami_id
  instance_type               = var.web_server.instance_type
  key_name                    = var.web_server.key_name
  subnet_id                   = var.web_public_subnets[1]
  security_groups             = [aws_security_group.webWebServerSecurityGroup.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash -xe
              sudo su
              yum update -y
              yum install -y httpd
              echo "<h1>Hello, World</h1>servere: webServer2" > /var/www/html/index.html
              echo "healthy" > /var/www/html/hc.html
              # start httpd 
              /etc/init.d/httpd start
              EOF

  tags = {
    Name    = "Public Web Server 2"
    Project = var.project
  }
}