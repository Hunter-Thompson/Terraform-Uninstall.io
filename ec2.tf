# Setup our aws provider
provider "aws" {
  access_key  = "${var.aws_access_key_id}"
  secret_key  = "${var.aws_secret_access_key}"
  region      = "${var.vpc_region}"
}
# instances
resource "aws_instance" "Webserver" {
  count = 2
  ami = "${var.inst_ami}"
  availability_zone = "${lookup(var.availability_zone, var.vpc_region)}"
  instance_type = "${var.inst_type}"
  key_name = "Hunter"
  subnet_id = "${var.vpc_public_sn_id}"
  associate_public_ip_address = true
  source_dest_check = false

security_groups = [
    "${var.vpc_public_sg_id}"]


  tags = {
    Name = "Webserver${count.index}"
  }

  
}
resource "aws_ebs_volume" "data" {
    availability_zone = "${lookup(var.availability_zone, var.vpc_region)}"
    size = 10
    tags {
        Name = "Data"
    }
}
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdb"
  volume_id   = "${aws_ebs_volume.data.id}"
  instance_id = "${aws_instance.Webserver.0.id}"
}
resource "null_resource" "Webserver" {

  triggers {
    cluster_instance_ids = "${join(",", aws_instance.Webserver.*.id)}"
  }
  provisioner "remote-exec" {
    script = "/home/hunter/Videos/Terraform/prov_aws_ec2_terraform/mount_and_format.sh"

    connection{
      host = "${aws_instance.Webserver.0.public_ip}"
      user = "ec2-user"
      private_key = "${file("~/.ssh/id_rsa")}"
    }

  }
}
output "ec2_ins_0_ip" {
  value = "${aws_instance.Webserver.0.public_ip}"
}





