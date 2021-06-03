# AWS Fargate Mailhog

![terraform v0.12.x](https://img.shields.io/badge/terraform-v0.12.x-brightgreen.svg)
![terraform v0.13.x](https://img.shields.io/badge/terraform-v0.13.x-brightgreen.svg)

Create `mailhog.tf` file

```HCL
module "mailhog" {
  source  = "tenantcloud/fargate/mailhog"

  dns_zone_id = "Route53ID"
  domain_name = "example.com"
  project = "example"
}
```
