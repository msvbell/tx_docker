variable "local_path_to_bash" {
  type = string
  default = env("LOCAL_PATH_TO_BASH")
}

source "null" "db" {
  communicator = "none"
}

build {
  sources = [
    "source.null.db"
  ]

  post-processor "shell-local" {
    inline = ["\"${var.local_path_to_bash}  -c \"packer/database/scripts/build_oracle_image.sh\""]
  }
}