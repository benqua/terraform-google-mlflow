# Inputs
variable "project" {
  type        = string
  description = "Google Cloud project name"
  #  default     = "infra-mlflow-terraform"
}

variable "cred_file" {
  type        = string
  description = "The (relative) path to the json service account credential file."
}

variable "zone" {
  type        = string
  description = "The zone where the vm should be launched."
  default     = "us-east1-b"
}

variable "disk_name" {
  type        = string
  description = "Name of the disk"
  default     = "mlflow-data"
}

variable "disk_size" {
  type        = number
  description = "Size of the disk to attach (GB)"
  default     = 30
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket storing the models"
  default     = "mlflow-models"
}

variable "bucket_location" {
  type        = string
  description = "Location of the S3 bucket storing the models"
  default     = "EUROPE-WEST6"
}

variable "machine_type" {
  type        = string
  description = "The machine type to launch (must be available in the selected zone)."
  default     = "n1-standard-1"
}

variable "ssh_user" {
  type        = string
  description = "The username that will be used to connect to the instance with the ssh pub key file"
  default     = "mlflow"
}

variable "ssh_pub_key_file" {
  type        = string
  description = "Public ssh key file path"
  default     = "~/.ssh/id_rsa.pub"
}

variable "service_account_email" {
  type        = string
  description = "Email of the (predefined) service account for the project (must match with cred_file)"
  #  default     = "infra-mlflow-terraform@infra-mlflow-terraform.iam.gserviceaccount.com"
}

variable "mlflow_version" {
  type        = string
  description = "Version of mlflow"
  default     = "1.12.1"
}

variable "mlflow_password" {
  type        = string
  description = "Password to access the mlflow UI (with user mlflow)"
}

