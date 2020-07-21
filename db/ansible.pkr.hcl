source "docker" "centos" {
  image = "centos:7"
  export_path = "db/ansible"
}

build {
  name = "ansible"

  sources = ["sources.docker.centos"]

  provisioner "shell" {
    script = "db/ansible-install.sh"
  }

  post-processor "docker-import" {
    repository = "local/ansible"
    tag = "latest"
  }
}