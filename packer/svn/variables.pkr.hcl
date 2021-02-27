variable "repo_name" {
  type = string
  default = "TX"
}

variable "svn_user" {
  type = string
  default = "manager"
}

variable "svn_password" {
  type = string
  default = "Password123"
  sensitive = true
}

variable "svn_port" {
  type = number
  default = 18080
}

variable "repo-path" {
  type = string
  default = "/opt/csvn/data/repositories/TX"
}

variable "distr_uri" {
  type = string
  default = "com.tranzaxis.banxelv"
}