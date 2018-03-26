resource "oci_core_virtual_network" "MemcachedDemo" {
  cidr_block     = "${var.VCN-CIDR}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MemcachedDemo"
  dns_label      = "MemcachedDemo"
}

resource "oci_core_internet_gateway" "MemcachedDemoIG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "MemcachedDemoIG"
  vcn_id         = "${oci_core_virtual_network.MemcachedDemo.id}"
}

resource "oci_core_route_table" "MemcachedDemoRT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.MemcachedDemo.id}"
  display_name   = "MemcachedDemoRT"

  route_rules {
    cidr_block        = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.MemcachedDemoIG.id}"
  }
}

resource "oci_core_security_list" "PublicSubnet" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Public"
  vcn_id         = "${oci_core_virtual_network.MemcachedDemo.id}"

  egress_security_rules = [{
    protocol    = "all"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 80
      "min" = 80
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = 443
        "min" = 443
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

resource "oci_core_security_list" "PrivateAppSubnets" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Security list for App servers"
  vcn_id         = "${oci_core_virtual_network.MemcachedDemo.id}"

  egress_security_rules = [{
    protocol    = "all"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 80
      "min" = 80
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = 443
        "min" = 443
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

resource "oci_core_security_list" "PrivateCacheSubnets" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Security list for Cache servers"
  vcn_id         = "${oci_core_virtual_network.MemcachedDemo.id}"

  egress_security_rules = [{
    protocol    = "all"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 80
      "min" = 80
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = 443
        "min" = 443
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

resource "oci_core_security_list" "PrivateDBSubnets" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Security list for DB servers"
  vcn_id         = "${oci_core_virtual_network.MemcachedDemo.id}"

  egress_security_rules = [{
    protocol    = "all"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 80
      "min" = 80
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  },
    {
      tcp_options {
        "max" = 443
        "min" = 443
      }

      protocol = "6"
      source   = "0.0.0.0/0"
    },
  ]
}

resource "oci_core_security_list" "BastionSubnet" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "Bastion"
  vcn_id         = "${oci_core_virtual_network.MemcachedDemo.id}"

  egress_security_rules = [{
    protocol    = "6"
    destination = "0.0.0.0/0"
  }]

  ingress_security_rules = [{
    tcp_options {
      "max" = 22
      "min" = 22
    }

    protocol = "6"
    source   = "0.0.0.0/0"
  }]
}

resource "oci_core_subnet" "PublicSubnetAD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "${var.PubSubnetAD1CIDR}"
  display_name        = "PublicSubnetAD1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PublicSubnet.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"
}

resource "oci_core_subnet" "PublicSubnetAD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block          = "${var.PubSubnetAD2CIDR}"
  display_name        = "PublicSubnetAD2"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PublicSubnet.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"
}

resource "oci_core_subnet" "PrivSubnet1AD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "${var.PrivSubnet1AD1CIDR}"
  display_name        = "AppSubnetAD1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PrivateAppSubnets.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"

  # prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_subnet" "PrivSubnet1AD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block          = "${var.PrivSubnet1AD2CIDR}"
  display_name        = "AppSubnetAD2"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PrivateAppSubnets.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"

  # prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_subnet" "PrivSubnet2AD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "${var.PrivSubnet2AD1CIDR}"
  display_name        = "MemcachedAD1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PrivateCacheSubnets.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"

  # prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_subnet" "PrivSubnet2AD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block          = "${var.PrivSubnet2AD2CIDR}"
  display_name        = "MemcachedAD2"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PrivateCacheSubnets.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"

  # prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_subnet" "PrivSubnet3AD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "${var.PrivSubnet3AD1CIDR}"
  display_name        = "MysqlDBAD1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PrivateDBSubnets.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"

  # prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_subnet" "PrivSubnet3AD2" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[1],"name")}"
  cidr_block          = "${var.PrivSubnet3AD2CIDR}"
  display_name        = "MysqlDBAD2"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.PrivateDBSubnets.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"

  # prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_subnet" "BastionSubnetAD1" {
  availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[0],"name")}"
  cidr_block          = "${var.BastSubnetAD1CIDR}"
  display_name        = "BastionSubnetAD1"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.MemcachedDemo.id}"
  route_table_id      = "${oci_core_route_table.MemcachedDemoRT.id}"
  security_list_ids   = ["${oci_core_security_list.BastionSubnet.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.MemcachedDemo.default_dhcp_options_id}"
}
