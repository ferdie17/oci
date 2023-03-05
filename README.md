# OCI

## OBJECTIVE:
Make use of Oracle Free VMs to test MW apps.

## SECTIONS:
1. Set up your free Oracle Account
2. Provision VM (via Terraform)
3. Deployment 
   3.1 Kafka
4. Test
   4.1 Kafka

5. References

## 1. Set up your free Oracle Account

## 2. Provision VM (via Terraform)
create a tfvars.env.sh file 
place it outside of the git repo directory so that it does not get saved in the repo.

## 3. Deployment 
###   3.1 Kafka

## 4. Test
###   4.1 Kafka
```      cd /opt/kafka```

```      bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic testTopic ```

```      bin/kafka-topics.sh --list --bootstrap-server localhost:9092 ```

```      bin/kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic ```

```      bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testTopic --from-beginning ```

## 5. References
- https://tecadmin.net/install-apache-kafka-centos-8/

## NOTES
- Terraform and Ansible are pre-installed on Oracle CLoud Shell.
