# key pair
resource aws_key_pair "my_key" {
    key_name   = "terra-key-ansible"
    public_key = file("terra-key-ansible.pub")
}

# VPC & Security Group

resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "my_security_group" {
    name        = "automate-sg"
    description = "Allow SSH inbound traffic"
    vpc_id      = aws_default_vpc.default.id

# ingrress rule to allow SSH access from anywhere

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "SSH access from anywhere"
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP access from anywhere"
    }
    
# egress rule to allow all outbound traffic

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "All access outbound traffic"
    }

    tags = {
        Name = "automate-sg"
    }
}

# ec2 instance

resource "aws_instance" "my_instance" {
    for_each = tomap({
        "TWS-Junnon-Master" = "ami-04fcb263575fa04fb",      #Ubuntu
        "TWS-Junnon-1" = "ami-04fcb263575fa04fb",           #Ubuntu
        "TWS-Junnon-2" = "ami-01126d0bab29817a7",           #Redhat
        "TWS-Junnon-3" = "ami-0add9dc62cfab3c11"            #Amazon Linux
    })
    
    depends_on = [aws_security_group.my_security_group, aws_key_pair.my_key]

    key_name      = aws_key_pair.my_key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = "t3.micro"
    ami           = each.value

    root_block_device {
        volume_size = 10
        volume_type = "gp3"
    }

    tags = {
        Name = each.key
    }
}