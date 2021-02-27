build {
  name = "Step 1"

  sources = [
    "source.file.project-config"]
}

build {
  name = "Step 2"

  source "source.docker.openjdk" {
    image = "openjdk:8"
  }

  provisioner "shell-local" {
    valid_exit_codes = [
      0,
      11]
    inline = [
      "unzip -uoqq distribs/com.tranzaxis\\* manager.zip -d ${path.root}",
      "unzip -juoqq distribs/com.tranzaxis\\* files/com.tranzaxis/etc/DbScripts/tablespaces.sql -d ${path.cwd}/db/install"
    ]
  }

  provisioner "file" {
    generated = true
    pause_before = "5s"
    source = "${path.root}/manager.zip"
    destination = "/tmp/manager.zip"
  }

  provisioner "shell" {
    inline = [
      "apt-get install -y unzip && unzip -qq /tmp/manager.zip -d /tmp",
      "mkdir -p /data/project /data/manager && cd /data/project && mkdir -p distrib distrib.log log.prod log.test upgrades upgrades.backup",
      "cp -R /tmp/manager/* /data/manager/",
      "rm -r /tmp/manager"]
  }

  provisioner "file" {
    source = "${path.cwd}/config/manager/manager.conf"
    destination = "/data/manager.conf"
  }

  provisioner "file" {
    source = "${path.cwd}/ojdbc8.jar"
    destination = "/data/ojdbc8.jar"
  }

    provisioner "file" {
      generated = true
      source = "${path.cwd}/temp/project.xml"
      destination = "/data/project/project.xml"
    }

  provisioner "shell" {
    inline = [
      "chmod +x /data/manager/bin/console",
      "rm /tmp/manager.zip"]
  }

  post-processor "docker-tag" {
    repository = "local/tx-manager"
    changes = [
      "ENV PATH \"$PATH:/usr/local/openjdk-8/bin\"",
      "WORKDIR /data/manager/bin",
      "ENTRYPOINT [\"/data/manager/bin/console\"]",
      "CMD [\"CMD_HELP\"]"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "del \"${path.root}\\manager.zip\""]
  }
}
