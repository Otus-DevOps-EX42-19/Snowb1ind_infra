# Snowb1ind_infra

## Изменение требуемой версии Terraform

[Пункт в документации](https://www.terraform.io/docs/configuration/terraform.html#specifying-a-required-terraform-version)

```HCL
# old
required_version = "0.11.14"
...

# new
required_version = "~> 0.12"
...
```

## Изменение версии провайдера GCP

```HCL
# old
provider "google" {   
    version = "2.0.0"
    ...

# new
provider "google" {   
    version = "2.5.0"
    ...
```

## Прямое использование выражений

[Пункт в докумкентации](https://www.terraform.io/upgrade-guides/0-12.html#first-class-expressions)

```HCL
# old
...
private_key = "${file("~/.ssh/id_rsa")}"
...

# new
...
private_key = file("~/.ssh/id_rsa")
...
```
