#create the security group
resource "aws_security_group" "SG" {
  name = var.security_group_name
  description = "Allow inbound and outbound traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS"
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP"
  }

  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow prometheus"
  }
  
  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Grafana"
  }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow all traffic"
    }
tags = {
    Name = "SG"
  }
}

#create the aws instance
resource "aws_instance" "jenkins" {
  ami = var.ami
  instance_type = t2.medium
  key_name = var.key_name
  security_groups = [aws_security_group.SG.name]
  
  user_data = <<-EOF
            #!/bin/bash
              set -e
              sudo apt update -y
              sudo apt install openjdk-17-jre -y
              java --version

            # Install Jenkins
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install jenkins -y
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              jenkins --version
              sudo cat /var/lib/jenkins/secrets/initialAdminPassword


            # Install Docker
              sudo apt-get install -y ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker jenkins

            # Install trivy for vulnerability scanning
              sudo apt-get update -y
              sudo apt-get install -y wget gnupg
              wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
              sudo apt-get update -y
              sudo apt-get install trivy -y
              trivy --version
              EOF

  tags = {
    Name = "Jenkins_EC2"
  }
}

resource "aws_instance" "sonarqube" {
    ami = var.ami
    instance_type = t2.medium
    key_name = var.key_name
    security_groups = [aws_security_group.SG.name]

    user_data = <<-EOF
            #!/bin/bash
                sudo apt update -y
                sudo apt install openjdk-17-jre -y
                java --version

            # Install Docker
              sudo apt-get install -y ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker jenkins

            # Install Sonarqube using docker
                sudo docker run -d --name sonarqube -p 9090:9000 sonarqube
                EOF
    tags = {
        Name = "Sonarqube_EC2"
    }
}

resource "aws_instance" "nexus" {
    ami = var.ami
    instance_type = t2.medium
    key_name = var.key_name
    security_groups = [aws_security_group.SG.name]

    user_data = <<-EOF
            #!/bin/bash
                sudo apt update -y
                sudo apt install openjdk-17-jre -y
                java --version

            # Install Docker
              sudo apt-get install -y ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker jenkins

            # Install nexus using docker
                sudo docker run -d -p 8081:8081 --name nexus sonatype/nexus3
                EOF
    tags = {
        Name = "Nexus_EC2"
    }
}

resource "aws_instance" "monitoring" {
    ami = var.ami
    instance_type = t2.medium
    key_name = var.key_name
    security_groups = [aws_security_group.SG.name]

    user_data = <<-EOF
            #!/bin/bash
                sudo apt update -y
                sudo apt install openjdk-17-jre -y
                java --version

            # Install Docker
              sudo apt-get install -y ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker jenkins

            # Install nexus using docker
                sudo docker pull prom/prometheus
                sudo docker run -d --name prometheus -p 9090:9090 prom/prometheus
                sudo docker pull grafana/grafana
                sudo docker run -d --name grafana -p 3000:3000 grafana/grafana
                EOF
    tags = {
        Name = "Monitoring_EC2"
    }
}

resource "aws_instance" "Docker" {
    ami = var.ami
    instance_type = t2.medium
    key_name = var.key_name
    security_groups = [aws_security_group.SG.name]

    user_data = <<-EOF
            #!/bin/bash
                sudo apt update -y
                sudo apt install openjdk-17-jre -y
                java --version

            # Install Docker
              sudo apt-get install -y ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              sudo systemctl enable docker
              sudo systemctl start docker
              sudo usermod -aG docker jenkins
              EOF

    tags = {
        Name = "Docker_EC2"
    }
}
