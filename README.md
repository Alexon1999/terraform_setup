# Terraform on Scaleway

[Documentation](https://registry.terraform.io/providers/scaleway/scaleway/latest/docs)

- Fill `secrets.sh` variables with Scaleway credentials and other prject variables.
  - `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are the credentials to provide to Terraform to have access to the AWS bucket S3 to store the Terraform state.
  
  You can use [Scaleway CLI](https://github.com/scaleway/scaleway-cli) or Scaleway Console to have all information/create API KEYS needed to fill the `secrets.sh` file.

- Load the variables in your terminal : `source secrets.sh`
- Initialize a Terraform working directory: `terraform init`
- Create Workspaces to manage different environment with differnt terraform state.
  - `terraform workspace new testing`
  - `terraform workspace list`
  - `terraform workspace select testing`
- Generate and show the execution plan: `terraform plan`
- Build the infrastructure: `terraform apply`
- Destroy the infrastructure: `terraform destroy`

### Troubleshoot

- Error: no zone found with the name `{subdomain}.{domain}`
  1) try to Import Existing Zone: If the zone already exists in Scaleway but is not recognized by Terraform, you might need to import the DNS zone into your Terraform state.
   `terraform import scaleway_domain_zone.dns_zone demo.hieraug.fr`

  2) Remove the Existing Resource from the State (If it's Incorrect or Unwanted)
   `terraform state rm scaleway_domain_zone.dns_zone`

  after apply it with, `terraform apply`