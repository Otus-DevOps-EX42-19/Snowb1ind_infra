# Homework GCP №2

testapp_IP = 35.228.197.153 \
testapp_PORT = 9292

## Создание инстанса с startup скриптом

```shell
gcloud compute instances create reddit-app-test\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=https://raw.githubusercontent.com/Otus-DevOps-EX42-19/Snowb1ind_infra/cloud-testapp/startup_script.sh
```

## Создание правила

```shell
gcloud compute firewall-rules create "default-puma-server" --allow tcp:9292 \
  --direction INGRESS \
  --target-tags=puma-server \
  --source-ranges=0.0.0.0/0
```
