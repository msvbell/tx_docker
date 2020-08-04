variable "repo_name"    { type = string }
variable "svn_user"     { type = string }

source "docker" "openjdk" {
  image = "openjdk:8"
  export_path = "images/manager.tar"
}

source "file" "project-config" {
  content = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
  <prod:ManagerProject Title="${var.repo_name}" SvnHomeUrl="http://svn:18080/svn/${var.repo_name}" xmlns:prod="http://schemas.radixware.org/product.xsd">
  <prod:Upgrade Dir="upgrades" BackupDir="upgrades.backup" TestLogDir="log.test" ProdLogDir="log.prod"/>
  <prod:Distribution Dir="distrib" LogDir="distrib.log"/>
  <prod:SVNAuthentication UserName="${var.svn_user}" Type="SVNPassword" SSHKeyFile=""/>
  <prod:KeyStore Type="0" File=""/>
</prod:ManagerProject>
  EOF
  target = "temp/project.xml"
}

build {
  sources = [
    "source.file.project-config"]
}

build {
  sources = [
    "source.docker.openjdk"
  ]

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

//  provisioner "file" {
//    source = "${path.root}/project"
//    destination = "/tmp"
//  }

  post-processor "docker-import" {
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
