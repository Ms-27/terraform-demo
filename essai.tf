# Connexion au provider, ici Amazon
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

# Création d'une vm VM1
# elle effectue une commande à la création qui écrit son adresse ip dans un fichier sur l'hôte
# on détermine les security group dans lesquelles la vm est
# elle est créée après la création du bucket
resource "aws_instance" "VM1" {
    ami             = "ami-007fae589fdf6e955"
    instance_type   = "t2.micro"

    provisioner "local-exec" {
        command = "echo ${aws_instance.VM1.public_ip} > ip_address.txt"
    }
    key_name        = "obo-key-eu-west-3"
    security_groups = ["ssh", "default"]
    # Tells Terraform that this EC2 instance must be created only after the
    # S3 bucket has been created.
    depends_on      = ["aws_s3_bucket.example"]
}

# Répertoire partagé, avec un nom unique (mondial)
resource "aws_s3_bucket" "example" {
  bucket = "terraform-getting-started-guide-obo"
  acl    = "private"
}

# Création de le vm VM2
resource "aws_instance" "VM2" {
    ami             = "ami-007fae589fdf6e955"
    instance_type   = "t2.micro"
    key_name        = "obo-key-eu-west-3"
    security_groups = ["ssh", "default", "${aws_security_group.web.name}"]
}

# Création d'un groupe de sécurité "web", qui ouvre le port 8080,
# uniquement à l'ip 195.68.64.154 (ip connexion unique EQL)
resource "aws_security_group" "web" {
    name        = "web"
    description = "acces sur le port 8080"
    vpc_id      = "vpc-06265b6f"

    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["195.68.64.154/32"]
    }
}
