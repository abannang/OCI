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

  # provisioner "file" {
  #   source      = "flask/main.py"
  #   destination = "~"
  # }
}

resource "oci_core_instance" "Memcached1AD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Memcached1AD1"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.MemcachedShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet2AD1.id}"

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data           = "${base64encode(file(var.MemcachedBootStrap))}"
  }
}

resource "oci_core_instance" "Memcached2AD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Memcached2AD1"
  image               = "${var.InstanceImageOCID[var.region]}"
  shape               = "${var.MemcachedShape}"
  subnet_id           = "${oci_core_subnet.PrivSubnet2AD1.id}"

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
