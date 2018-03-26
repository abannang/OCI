variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

variable "compartment_ocid" {}
variable "ssh_public_key" {}
variable "ssh_private_key" {}

variable "BastionShape" {
  description = "Shape of the bastion host"
  default     = "VM.Standard1.4"
}

variable "AppShape" {
  description = "Shape of the App instances"
  default     = "VM.Standard1.2"
}

variable "MemcachedShape" {
  description = "Shape of Memcache instances"
  default     = "VM.Standard1.2"
}

variable "MysqlDBShape" {
  description = "Shape of MySQL DB instances"
  default     = "VM.DenseIO1.4"
}

variable "HostUserName" {
  default = "ubuntu"
}

variable "InstanceImageOCID" {
  type        = "map"
  description = "Oracle image OCIDs"

  default = {
    // Oracle-provided image "Oracle-Linux-7.4-2017.12.18-0"
    // See https://docs.us-phoenix-1.oraclecloud.com/Content/Resources/Assets/OracleProvidedImageOCIDs.pdf
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaau5cadziy5ef777zqtv6ummayq2vtbez25lt67jaobiz3gmp3zbxq"

    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaafmyat7i5s7ae3aylwtvmt7v4dw4yy2thgzaqlbjzoxngrjg54xq"
  }
}

variable "VCN-CIDR" {
  description = ""
  default     = "10.0.0.0/16"
}

variable "PrivSubnet1AD1CIDR" {
  default = "10.0.0.32/28"
}

variable "PrivSubnet2AD1CIDR" {
  default = "10.0.0.64/28"
}

variable "PrivSubnet3AD1CIDR" {
  default = "10.0.0.96/28"
}

variable "BastSubnetAD1CIDR" {
  default = "10.0.0.128/28"
}

variable "BastionBootStrap" {
  default = "./userdata/bastion"
}

variable "AppBootStrap" {
  default = "./userdata/appServer"
}

variable "MemcachedBootStrap" {
  default = "./userdata/memcache"
}

variable "MysqlDBBootStrap" {
  default = "./userdata/mysqlDB"
}
