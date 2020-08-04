variable "dist_uri"     { type = string }
variable "repo_name"    { type = string }
variable "svn_user"     { type = string }
variable "svn_pass" { type = string }

locals {
  repo-path = "file:////opt/csvn/data/repositories/${var.repo_name}"
  svn-create-dirs = <<EOF
  mkdir /tmp/repo && cd /tmp/repo && \
  mkdir -p clients \
    config \
    dev/trunk \
    distributives/clients \
    prod \
    releases \
    scripts
  EOF
}

source "docker" "svn" {
  image = "mamohr/subversion-edge"
  export_path = "images/svn.tar"
}

source "file" "db-config" {
  content = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Databases xmlns="http://schemas.radixware.org/product.xsd">
    <Database Name="TX" Uri="jdbc:oracle:thin:@db:1521/RBS" Schema="TEST" Test="true">
        <Parameters/>
    </Database>
</Databases>
EOF
  target = "${path.cwd}/temp/databases.xml"
}

source "file" "notification-config" {
  content = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<NotificationConfig xmlns="http://schemas.radixware.org/product.xsd"/>
EOF
  target = "${path.cwd}/temp/notification.xml"
}

source "file" "repository-config" {
  content = <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<RepositoryConfig xmlns="http://schemas.radixware.org/product.xsd" VersionFormat="2" Title="${var.repo_name}"
                  DowngradesOffshootsScriptCheck="None" BaseDevUri="${var.dist_uri}" RunUris="${var.dist_uri}" RunUri="${var.dist_uri}"/>
EOF
  target = "${path.cwd}/temp/repository.xml"
}

build {
  name = "files"
  sources = [
    "source.file.db-config",
    "source.file.notification-config",
    "source.file.repository-config"]
}

build {
  name = "SVN server"
  sources = [
    "source.docker.svn"
  ]

  provisioner "shell" {
    inline = [
      "${local.svn-create-dirs}"]
  }

  provisioner "file" {
    generated = true
    sources = [
      "${path.cwd}/temp/databases.xml",
      "${path.cwd}/temp/notification.xml",
      "${path.cwd}/temp/repository.xml"]
    destination = "/tmp/repo/config/"
  }

  provisioner "file" {
    direction = "upload"
    source = "${path.cwd}/config/svn/"
    destination = "/tmp/conf"
  }

  provisioner "file" {
    source = "${path.root}/scripts/init_repository.sh"
    destination = "/config/"
  }

  provisioner "file" {
    source = "${path.cwd}/config/svn/passwd"
    destination = "/tmp/conf/passwd"
  }

  provisioner "file" {
    source = "${path.cwd}/config/svn/svnserve.conf"
    destination = "/tmp/conf/svnserve.conf"
  }

  provisioner "shell" {
    environment_vars = [
      "SVN_USER=${var.svn_user}",
      "SVN_PASSWORD=${var.svn_pass}"
    ]
    inline = [
      "chmod +x /config/init_repository.sh",
      "chown -R collabnet:collabnet /opt/csvn/data",
      "yes | cp -rf /tmp/conf/* /opt/csvn/data-initial/conf",
      "/opt/csvn/bin/svnadmin create /opt/csvn/data-initial/repositories/TX",
      "mkdir /data",
      "cp -r /tmp/repo/* /data",
      "rm -r /tmp/repo",
      "/opt/csvn/bin/svn import -m \"init\" /data file:////opt/csvn/data-initial/repositories/TX"
    ]
  }

  post-processor "docker-import" {
    repository = "local/tx-svn-base"
    changes = [
      "ENV SVN_USER=${var.svn_user}",
      "ENV SVN_PASSWORD=${var.svn_pass}",
      "ENTRYPOINT [\"/config/init_repository.sh\"]"
    ]
  }

}