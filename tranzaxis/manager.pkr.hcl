source "docker" "openjdk" {
  image = "openjdk:8"
  export_path = "openjdk.tar"
}

build {
  sources = [
    "source.docker.openjdk"
  ]

  provisioner "file" {
    source = "${path.root}/manager/manager_1_2_11_27_7.zip"
    destination = "/tmp/manager.zip"
  }

  provisioner "shell" {
    inline = ["apt-get install -y unzip && unzip /tmp/manager.zip -d /tmp"]
  }

  provisioner "file" {
    source = "${path.root}/manager/manager.conf"
    destination = "/tmp/manager/etc/manager.conf"
  }

  provisioner "file" {
    source = "${path.root}/project"
    destination = "/tmp"
  }

  post-processor "docker-import" {
    repository = "local/manager"
    tag = "0.1"
    changes = [
      "ENTRYPOINT /tmp/manager/bin/console"
    ]
  }
}