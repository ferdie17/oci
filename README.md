# OCI (Oracle Cloud Infrastructure)

## OBJECTIVE:
Take advance  of Oracle Free VMs to test MW apps.

## SECTIONS:
1. Set up your free Oracle Account
2. Provision VM (via Terraform)
3. Deployment   (via Ansible)
   3.1 Kafka
4. Test
   4.1 Kafka
5. References
6. Appendices
7. Notes

## 1. Set up your free Oracle Account

### 1.1 Sign up for a free account in Oracle Cloud (https://signup.oraclecloud.com/)
Please follow the instructions as found on the following page: https://docs.oracle.com/en/cloud/paas/content-cloud/administer/create-and-activate-oracle-cloud-account.html

Take note of the following values, as they will be needed for provisioning

Tenancy and User ID
https://pitstop.manageengine.com/portal/en/kb/articles/where-to-get-the-tenancy-s-ocid-and-user-s-ocid#:~:text=Open%20the%20navigation%20menu%2C%20under,copy%20it%20to%20your%20clipboard.

OCI API Private Key Path and Fingerprint
https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm


## 2. Provision VM (via Terraform)
cd ~
git clone https://github.com/ferdie17/oci.git
cd oci

create a tfvarsenv.sh file outside of the repo dir, place it outside of the git repo directory so that it does not get saved in the repo.

vi ../tfvarsenv.sh
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export TF_VAR_user_ocid=ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
export TF_VAR_private_key_path=~/.oci/oci_api_key.pem
#export TF_VAR_private_key_password=<put-here-private-key-password>
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

chmod 755 ~/tfvarsenv.sh
. ~/tfvarsenv.sh
terraform init
terraform plan
terraform apply --auto-approve

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

compute_instance_ip = "140.238.199.73"
generated_private_key_pem = <sensitive>
ang_ferdin@cloudshell:oci (ap-sydney-1)$ 

ssh opc@140.238.199.73
exit

## 3. Deployment (via Ansible)
###   3.1 Kafka
    Add the host IP address to Ansible Inventory File.
```
    $ cat inventory 
    [kafka]
    152.67.98.24
```

    The Ansible playbook will do the following
cat kafka.yml 
    Execute the Ansible playbook
ansible-playbook -i inventory kafka.yml

## 4. Test
###   4.1 Kafka
    Switch to default directory
```    cd /opt/kafka```

    Create a Kafka topic
```    bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic testTopic ```

```    bin/kafka-topics.sh --list --bootstrap-server localhost:9092 ```

    Using Kafka Consmer, create a message.
```    bin/kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic ```

    Using Kafka Producer, read the message.
```    bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testTopic --from-beginning ```

## 5. References
- https://kafka.apache.org/quickstart
- https://tecadmin.net/install-apache-kafka-centos-8/

## 6. Appendices

## 7. NOTES
- Terraform and Ansible are pre-installed on Oracle CLoud Shell.
