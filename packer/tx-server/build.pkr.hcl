variable "repo_name"    { type = string }
variable "dist_uri"     { type = string }

locals {
  temp_dir = "${path.cwd}/temp"
  temp_dir_win = "${path.cwd}\\temp"
  repo_dir = "file:///opt/csvn/data/repositories/TX/distributives"
}

source "docker" "openjdk" {
  image = "openjdk:8"
  export_path = "images/tx-server.tar"
}

build {
  name = "TX server"
  sources = [
    "source.docker.openjdk"
  ]

  provisioner "shell-local" {
    inline = [
      "docker exec svn /bin/bash -c \"REPO_DIR=${local.repo_dir} ; /opt/csvn/bin/svn export $${REPO_DIR}/${var.dist_uri}/$(/opt/csvn/bin/svn ls $${REPO_DIR}/${var.dist_uri} | sort -n | tail -1)/release/com.tranzaxis/etc/OsScripts/prod/ /tmp/tx\"",
      "docker exec svn /bin/bash -c \"REPO_DIR=${local.repo_dir} ; /opt/csvn/bin/svn export $${REPO_DIR}/${var.dist_uri}/$(/opt/csvn/bin/svn ls $${REPO_DIR}/${var.dist_uri} | sort -n | tail -1)/release/com.tranzaxis/etc/DbScripts/ /tmp/tx/db\"",
      "docker exec svn /bin/bash -c \"REPO_DIR=${local.repo_dir} ; /opt/csvn/bin/svn export $${REPO_DIR}/${var.dist_uri}/$(/opt/csvn/bin/svn ls $${REPO_DIR}/${var.dist_uri} | sort -n | tail -1)/release/org.radixware/kernel/starter/bin/dist/starter.jar /tmp/tx/starter.jar\"",
      "docker cp svn:/tmp/tx temp",
      "docker exec svn rm -r -f /tmp/tx"
    ]
  }

  provisioner "shell-local" {
    only_on = ["windows"]
    inline = [
      "mkdir \"${path.cwd}/config/tx_server\" 2> NUL",
      "echo n | copy /-y \"${local.temp_dir}/tx\\*explorer.cmd\" \"${path.cwd}/for_users/explorer\"",
      "echo n | copy /-y \"${local.temp_dir}/tx\\explorer.sh\" \"${path.cwd}/for_users/explorer\"",
      "echo n | copy /-y \"${local.temp_dir}/tx\\explorer_mac.sh\" \"${path.cwd}/for_users/explorer\"",
      "echo n | copy /-y \"${local.temp_dir}/tx\\starter.jar\" \"${path.cwd}/for_users/explorer\"",
      "echo n | copy /-y \"${local.temp_dir}/tx\\explorer.cfg\" \"${path.cwd}/for_users/explorer\"",
      "echo n | copy /-y \"${local.temp_dir}/tx\\server.cfg\" \"${path.cwd}/for_users\""
    ]
  }


  provisioner "shell" {
    inline = [
      "mkdir -p /app/server", 
      "mkdir /tmp/tx"
    ]
  }

  provisioner "file" {
    generated = true
    sources = [
      "${local.temp_dir}/tx/server.sh",
      "${local.temp_dir}/tx/starter.jar",
      "${path.cwd}/packer/tx-server/scripts/init_config.sh",
      "${path.cwd}/for_users/server.cfg"]
    destination = "/tmp/tx/"
  }

  provisioner "shell" {
    inline = [
      "cp -r /tmp/tx/* /app/server",
      "chmod +x /app/server/server.sh",
      "chmod +x /app/server/init_config.sh",
      "rm -r /tmp/tx"
    ]
  }

  provisioner "shell-local" {
    only_on = [
      "linux",
      "darwin"]
    inline = [
      "mkdir -p config/tx_server explorer",
      "cp -n ${local.temp_dir}/tx/explorer*.sh for_users/explorer",
      "cp -n ${local.temp_dir}/tx/starter.jar for_users/explorer",
      "cp -n ${local.temp_dir}/tx/explorer.cfg for_users/explorer",
      "cp -n ${local.temp_dir}/tx/server.cfg for_users",
      "rm -r ${local.temp_dir}/tx"]
  }


  post-processor "docker-import" {
    repository = "local/tx-server"
    changes = [
      "ENV PATH \"$PATH:/bin:/usr/local/openjdk-8/bin\"",
      "WORKDIR /app/server",
      "ENTRYPOINT /app/server/init_config.sh"]
  }
}