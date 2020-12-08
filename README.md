# terraform-google-mlflow
A terraform module to deploy a mlflow server with nginx basic authentication on Google Cloud.
This module install a development MLflow for quick experiment. 
- It uses a local sqlite for the database.
- There is only one hardcoded user account, accessed through basic authentication.
- There is no SSL.

## Prerequisites
To create ressources on Google Cloud, terraform needs:
- A Google Cloud Platform project
- A service accound with the permissions needed to create ressources in the project and its json key file
- A working terraform >= 0.13

## Deploying MLflow with terraform on Google Cloud
1. In an empty directory, copy the service account json key file.
2. Create a file with a `.tf` extention and add the module configuration with your own values:

   ``` hcl
   module "mlflow" {
     source                = "github.com/benqua/terraform-google-mlflow"
     project               = "project-name"
     cred_file             = "project-name-service-accound-key-file-XXXNNNXXXNNX.json"
     service_account_email = "service-account-email@project-name.iam.gserviceaccount.com"
     ssh_user              = "your ssh username"
     ssh_pub_key_file      = "~/.ssh/id_rsa.pub"
     zone                  = "europe-west6-b"
     machine_type          = "n1-standard-1"
     mlflow_password       = "PasswordT0AccessMLflow"
   }

   output "mlflow_ip" {
     value       = module.mlflow.cip
     description = "IP to access mlflow server (HTTP or SSH)"
   }

   ```
   
   Check [other variables and their default values](https://github.com/benqua/terraform-google-mlflow/blob/main/variables.tf).
3. Run `terraform init`
4. Run `terraform plan` and check the output
5. Run `terraform apply` and answer `yes`
6. Wait. Once the ressources are created, terraform will output `mlflow_ip`, the IP to access the MLFlow server.

Note that:
- Once the ressources are created, it takes a few minutes before the MLflow server is available. This time is needed to configure the instance, download and run MLflow and the Nginx proxy (for basic auth).
- The MLflow server is accessible through HTTP (and not HTTPS).

## Warning
A `terraform destroy` will destroy the mlflow server **and** the disck containing the metrics **and** the S3 bucket containing the models. 
