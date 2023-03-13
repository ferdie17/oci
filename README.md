# OCI (Oracle Cloud Infrastructure)

## OBJECTIVE:
Make use of Oracle Free VMs to test MW apps.

## SECTIONS:
1. Set up your free Oracle Account
2. Provision VM (via Terraform)
3. Deployment   (via Ansible)
   3.1 Inventory
       3.1.1 Kafka
       3.1.2 Docker 
4. Test

   4.1 Kafka
   4.2 Docker
5. Decommission
6. References
7. Notes

## 1. Set up your free Oracle Account

### 1.1 Sign up for a free account in Oracle Cloud (https://signup.oraclecloud.com/)
Please follow the instructions as found on the following page: https://docs.oracle.com/en/cloud/paas/content-cloud/administer/create-and-activate-oracle-cloud-account.html.

### 1.2 Take note of the following values, as they will be needed for VM provisioning.

- Tenancy and User ID

  https://pitstop.manageengine.com/portal/en/kb/articles/where-to-get-the-tenancy-s-ocid-and-user-s-ocid#:~:text=Open%20the%20navigation%20menu%2C%20under,copy%20it%20to%20your%20clipboard.

- OCI API Private Key Path and Fingerprint

  https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm

- Compartment ID

  https://docs.oracle.com/en-us/iaas/Content/GSG/Tasks/contactingsupport_topic-Finding_the_OCID_of_a_Compartment.htm


## 2. Provision VM (via Terraform)

### 2.1 Clone the GitHub repo

```
    cd ~
    git clone https://github.com/ferdie17/oci.git
    cd oci
```

Note: change the GitHub URL to the correct one.  Above is only an example.

### 2.2 Create a script (tfvarsenv.sh) that defines the environment variables.  

Replace 'xxx...xxx' with the correct values.

```
  vi ../tfvarsenv.sh
  export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  export TF_VAR_user_ocid=ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  export TF_VAR_private_key_path=~/.oci/oci_api_key.pem
  #export TF_VAR_private_key_password=<put-here-private-key-password> # ONLY NEEDED IF KEY IS PASSWORD-PROTECTED
  export TF_VAR_fingerprint=xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx
  export TF_VAR_region=ap-sydney-1
  export TF_VAR_compartment_ocid=ocid1.compartment.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  export TF_VAR_vcn_cidr_blocks=[\"10.1.0.0/16\"]
  export TF_VAR_subnet_cidr_block="10.1.20.0/24"
  export TF_VAR_ssh_public_key=~/.ssh/id_rsa.pub
  #export TF_VAR_instance_shape="VM.Standard.A1.Flex"
  export TF_VAR_instance_shape="VM.Standard.E2.1.Micro"
  export TF_VAR_instance_ocpus=1
  export TF_VAR_instance_shape_config_memory_in_gbs=1
  export TF_VAR_operating_system="Oracle Linux"
  export TF_VAR_operating_system_version="8"
```

The file should reside outside of the git repo directory, so that it does not get saved in the repo (e.g. confidentail info).


### 2.3 Make the script (tfvarsenv.sh) executable, then execute it.

```
  chmod 755 ~/tfvarsenv.sh
  . ~/tfvarsenv.sh
```

### 2.3 Download the Terraform provider(s).

```
  terraform init
```

### 2.4 Perform Terraform pre-checks

```
  terraform plan
```

### 2.4 Executre Terraform Actions and take of the 'compute_instance_ip' IP address (this is the VM's IP Address)

```
  terraform apply --auto-approve
```

Take note of the 'compute_instance_ip'.   This is the IP address of the VM.   In this case, it is "140.238.199.73"

```
  Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

  Outputs:

  compute_instance_ip = "140.238.199.73"
  generated_private_key_pem = <sensitive>
```

Applying Terraform 'main.tf' file will perform the following:
- Download provider "oci".
- Create resource "oci_core_vcn" "vcn".
- Create resource "oci_core_internet_gateway" "internet_gateway".
- Create resource "oci_core_route_table" "route_table".
- Create resource "oci_core_security_list" "security_list".
- Create resource "oci_core_subnet" "subnet".
- Create resource "tls_private_key" "compute_ssh_key".
- Create resource "oci_core_instance" "instance".

### 2.5 Confirm that the VM is up and running.

```
  ssh opc@140.238.199.73
  exit
```


## 3. Deployment (via Ansible)
###   3.1 Inventory
Add the host IP address to Ansible Inventory File.
####        3.1.1 Kafka
```
    $ cat inventory 
    [kafka]
    140.238.199.73
```
####        3.1.2 Docker
```
    $ cat inventory 
    [docker]
    140.238.204.131
```

###   3.2 Playbook 
From CloudShell, install the Docker community Galaxy collection.
```
    ansible-galaxy collection install community.docker
```

####       3.2.1 (kafka.yml)
The Ansible playbook is defined to do the following:
- Update all packages to the latest version.
  NOTE: this is commented out by default in order to speed up builds.  Uncomment if appropriate.
- Install OpenJDK Java
- Ensure JAVA_HOME is defined in /etc/profile
- Ensure JRE_HOME is defined in /etc/profile
- Create 'kafka' group account
- Create 'kafka' user accounta 
- Create Kafka home directory
- Download Kafka and Unzip 
- Move all the files to parent Directory
- Update the log path
- Update the Java Heap Size for Kafka
  NOTEL for 1GB VM, reduce the heap size to 256MB
- Create a Service files for ZooKeeper and Kafka
- Start Services for ZooKeeper and Kafka
- Validate ZooKeeper and Kafka are listening on their respective ports (2181 and 9092)

####       3.2.2 (docker.yml)
The Ansible playbook is defined to do the following:
- Update all packages to the latest version.
  NOTE: this is commented out by default in order to speed up builds.  Uncomment if appropriate.
- Install yum-utils
- Add Docker Yum Repo
- Install Docker packages
- Start and Enable Docker server
- Make user 'opc' a member of group 'docker'



###   3.3 Update the Playbook avariables 
####        3.3.1 Kafka
Update the Ansible variables (kafka.yml) if required.
```
  vars:
    kafka_dir:   /opt/kafka
    kafka_src:   "https://downloads.apache.org/kafka/3.4.0/kafka_2.13-3.4.0.tgz"
    jdk_version: 1.8.0
```

####        3.3.2 Docker

###   3.4 Execute the Ansible playbook
####        3.4.1 Kafka
```
  ansible-playbook -i inventory kafka.yml
```

####        3.4.2 Docker
```
  ansible-playbook -i inventory docker.yml
```

## 4. Test
###   4.1 Kafka

Switch to default directory

```
cd /opt/kafka
```

Create a Kafka topic
```
    bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic testTopic
    bin/kafka-topics.sh --list --bootstrap-server localhost:9092 
```

Using Kafka Consumer, create a message.
```
    bin/kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic 
```

Using Kafka Producer, read the message.
```
    bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testTopic --from-beginning 
```

###   4.2 Docker
Verify Docker Compose is installed
```
    sudo docker compose version 
```

Test Docker is working
```
    sudo docker run hello-world
```

## 5. Decommission
```
  terraform destroy --auto-approve
```

## 6. References
- https://kafka.apache.org/quickstart
- https://tecadmin.net/install-apache-kafka-centos-8/
- https://geekscircuit.com/how-to-install-docker-on-oracle-linux-8-7/

## 7. Notes
- Terraform and Ansible are pre-installed on Oracle Cloud Shell.
