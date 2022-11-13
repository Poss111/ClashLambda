variable "access_key" {
  default   = ""
  type      = string
  sensitive = true
}

variable "secret_key" {
  default   = ""
  type      = string
  sensitive = true
}

variable "region" {
  default = "us-east-1"
  type    = string
}

variable "release_version" {
  default = ""
  type    = string
}

variable "image_id" {
  default   = ""
  type      = string
  sensitive = true
}

variable "network_iam_policies" {
  default   = []
  type      = list(string)
  sensitive = true
}

variable "cloudwatch_iam_policies" {
  default   = []
  type      = list(string)
  sensitive = true
}

variable "secret_iam_policies" {
  default   = []
  type      = list(string)
  sensitive = true
}

variable "email_address" {
  default = ""
  type    = string
}

variable "topic_actions" {
  default = []
  type    = list(string)
  sensitive = true
}

variable "sns_policies" {
  default = []
  type    = list(string)
  sensitive = true
}
