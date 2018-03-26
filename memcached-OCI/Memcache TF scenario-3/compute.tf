resource "oci_core_instance" "Bastion" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Bastion"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.BastionShape}"
  subnet_id           = "${oci_core_subnet.BastionSubnetAD1.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.BastionBootStrap))}"
  }

  timeouts {
    create = "30m"
  }
}

resource "oci_core_instance" "AppAD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "AppAD1"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.AppShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet1AD1.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.AppBootStrap))}"
  }

  provisioner "file" {
    source      = "flask/main.py"
    destination = "~"
  }
}

resource "oci_core_instance" "AppAD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "AppAD2"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.AppShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet1AD2.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.AppBootStrap))}"
  }

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "flask/main.py"
    destination = "~"
  }
}

resource "oci_core_instance" "MemcachedAD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MemcachedAD1"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.MemcachedShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet2AD1.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.MemcachedBootStrap))}"
  }
}

resource "oci_core_instance" "MemcachedAD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MemcachedAD2"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.MemcachedShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet2AD2.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.MemcachedBootStrap))}"
  }
}

resource "oci_core_instance" "MysqlDBAD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MysqlDBAD1"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.MysqlDBShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet3AD1.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.MysqlDBBootStrap))}"
  }

  timeouts {
    create = "30m"
  }
}

resource "oci_core_instance" "MysqlDBAD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "MysqlDBAD2"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.MysqlDBShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet3AD2.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.MysqlDBBootStrap))}"
  }

  timeouts {
    create = "30m"
  }
}

/* Load Balancer */

resource "oci_load_balancer" "PubLB" {
  shape          = "100Mbps"
  compartment_id = "${var.compartment_ocid}"

  subnet_ids = [
    "${oci_core_subnet.PublicSubnetAD1.id}",
    "${oci_core_subnet.PublicSubnetAD2.id}",
  ]

  display_name = "PubLB"
}

resource "oci_load_balancer_backendset" "lb-bes1" {
  name             = "lb-bes1"
  load_balancer_id = "${oci_load_balancer.PubLB.id}"
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_certificate" "lb-cert1" {
  load_balancer_id = "${oci_load_balancer.PubLB.id}"

  ca_certificate     = "-----BEGIN CERTIFICATE-----\nMIIBNzCB4gIJAKtwJkxUgNpzMA0GCSqGSIb3DQEBCwUAMCMxITAfBgNVBAoTGElu\ndGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0xNzA0MTIyMTU3NTZaFw0xODA0MTIy\nMTU3NTZaMCMxITAfBgNVBAoTGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDBcMA0G\nCSqGSIb3DQEBAQUAA0sAMEgCQQDlM8lz3BFJA6zBlsF63k9ajPVq3Q1WQoHQ3j35\n08DRKIfwqfV+CxL63W3dZrwL4TrjqorP5CQ36+I6OWALH2zVAgMBAAEwDQYJKoZI\nhvcNAQELBQADQQCEjHVQJoiiVpIIvDWF+4YDRReVuwzrvq2xduWw7CIsDWlYuGZT\nQKVY6tnTy2XpoUk0fqUvMB/M2HGQ1WqZGHs6\n-----END CERTIFICATE-----"
  certificate_name   = "certificate1"
  private_key        = "-----BEGIN RSA PRIVATE KEY-----\nMIIBOgIBAAJBAOUzyXPcEUkDrMGWwXreT1qM9WrdDVZCgdDePfnTwNEoh/Cp9X4L\nEvrdbd1mvAvhOuOqis/kJDfr4jo5YAsfbNUCAwEAAQJAJz8k4bfvJceBT2zXGIj0\noZa9d1z+qaSdwfwsNJkzzRyGkj/j8yv5FV7KNdSfsBbStlcuxUm4i9o5LXhIA+iQ\ngQIhAPzStAN8+Rz3dWKTjRWuCfy+Pwcmyjl3pkMPSiXzgSJlAiEA6BUZWHP0b542\nu8AizBT3b3xKr1AH2nkIx9OHq7F/QbECIHzqqpDypa8/QVuUZegpVrvvT/r7mn1s\nddS6cDtyJgLVAiEA1Z5OFQeuL2sekBRbMyP9WOW7zMBKakLL3TqL/3JCYxECIAkG\nl96uo1MjK/66X5zQXBG7F2DN2CbcYEz0r3c3vvfq\n-----END RSA PRIVATE KEY-----"
  public_certificate = "-----BEGIN CERTIFICATE-----\nMIIBNzCB4gIJAKtwJkxUgNpzMA0GCSqGSIb3DQEBCwUAMCMxITAfBgNVBAoTGElu\ndGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0xNzA0MTIyMTU3NTZaFw0xODA0MTIy\nMTU3NTZaMCMxITAfBgNVBAoTGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDBcMA0G\nCSqGSIb3DQEBAQUAA0sAMEgCQQDlM8lz3BFJA6zBlsF63k9ajPVq3Q1WQoHQ3j35\n08DRKIfwqfV+CxL63W3dZrwL4TrjqorP5CQ36+I6OWALH2zVAgMBAAEwDQYJKoZI\nhvcNAQELBQADQQCEjHVQJoiiVpIIvDWF+4YDRReVuwzrvq2xduWw7CIsDWlYuGZT\nQKVY6tnTy2XpoUk0fqUvMB/M2HGQ1WqZGHs6\n-----END CERTIFICATE-----"
}

resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = "${oci_load_balancer.PubLB.id}"
  name                     = "http"
  default_backend_set_name = "${oci_load_balancer_backendset.lb-bes1.id}"
  port                     = 80
  protocol                 = "HTTP"
}

# resource "oci_load_balancer_listener" "lb-listener2" {
#   load_balancer_id         = "${oci_load_balancer.PubLB.id}"
#   name                     = "https"
#   default_backend_set_name = "${oci_load_balancer_backendset.lb-bes1.id}"
#   port                     = 443
#   protocol                 = "HTTP"

#   ssl_configuration {
#     certificate_name        = "${oci_load_balancer_certificate.lb-cert1.certificate_name}"
#     verify_peer_certificate = false
#   }
# }

resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = "${oci_load_balancer.PubLB.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "${oci_core_instance.AppAD1.private_ip}"
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb-be2" {
  load_balancer_id = "${oci_load_balancer.PubLB.id}"
  backendset_name  = "${oci_load_balancer_backendset.lb-bes1.id}"
  ip_address       = "${oci_core_instance.AppAD2.private_ip}"
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
