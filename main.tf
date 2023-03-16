#
# Provider: OCI
#
# See https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm
# 
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
  region           = var.region
}

#
# Resource: Virtual Network
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_vcn
#
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = var.vcn_cidr_blocks
  display_name   = "MW Virtual Network"
  dns_label      = "mwvcn"
}

#
# Resource: Internet Gateway
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_internet_gateway
#
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "MW Internet Gateway"
  vcn_id         = oci_core_vcn.vcn.id
}

#
# Resource: Route Table
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_route_table
#
resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_ocid
  display_name   = "MW Route Table"
  vcn_id         = oci_core_vcn.vcn.id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

#
# Resource: Security List
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list
#   TCP = 6
#   UDP = 17
#
resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "MW SecurityList"
  vcn_id         = oci_core_vcn.vcn.id
  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "SSH"
    tcp_options {
      min = "22"
      max = "22"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP"
    tcp_options {
      min = "80"
      max = "80"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS"
    tcp_options {
      min = "443"
      max = "443"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Port 1521 - Oracle"
    tcp_options {
      min = "1521"
      max = "1521"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Port 3306 - MySQL"
    tcp_options {
      min = "3306"
      max = "3306"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Port 8080"
    tcp_options {
      min = "8080"
      max = "8080"
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Port 8081 - Mongo Express"
    tcp_options {
      min = "8081"
      max = "8081"
    }
  }
  ingress_security_rules {
    protocol    = "17"
    source      = "0.0.0.0/0"
    description = "Mosh"
    udp_options {
      min = "60000"
      max = "61000"
    }
  }
}

#
# Resource: Subnet
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet
#
resource "oci_core_subnet" "subnet" {
  cidr_block        = var.subnet_cidr_block
  compartment_id    = var.compartment_ocid
  dhcp_options_id   = oci_core_vcn.vcn.default_dhcp_options_id
  display_name      = "MW Subnet"
  dns_label         = "mwsubnet"
  route_table_id    = oci_core_route_table.route_table.id
  security_list_ids = [oci_core_security_list.security_list.id]
  vcn_id            = oci_core_vcn.vcn.id
}

#
# Data Source: Availability Domain
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domain
#
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

#
# Data Source: Images
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_images
# See https://docs.oracle.com/iaas/images/
#
data "oci_core_images" "images" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.operating_system
  operating_system_version = var.operating_system_version
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

#
# Resource: SSH Key
#
# See https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key`
#
resource "tls_private_key" "compute_ssh_key" {
  count     = var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}
output "generated_private_key_pem" {
  value     = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key[0].private_key_pem
  sensitive = true
}

#
# Resource: Instance
#
# See https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance
#
resource "oci_core_instance" "instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "MW Instance"
  shape               = var.instance_shape
  create_vnic_details {
    assign_private_dns_record = true
    assign_public_ip          = true
    display_name              = "primaryvnic"
    hostname_label            = "mwvm"
    subnet_id                 = oci_core_subnet.subnet.id
  }
  metadata = {
    ssh_authorized_keys = (var.ssh_public_key != "") ? file(var.ssh_public_key) : tls_private_key.compute_ssh_key[0].public_key_openssh
  }
  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }
  source_details {
    source_id   = lookup(data.oci_core_images.images.images[0], "id")
    source_type = "image"
  }
}
output "compute_instance_ip" {
  value = oci_core_instance.instance.public_ip
}
