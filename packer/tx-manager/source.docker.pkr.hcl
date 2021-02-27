source "docker" "openjdk" {
  commit = true
  changes = [
    "ENV PATH \"$PATH:/usr/local/openjdk-8/bin\"",
    "WORKDIR /data/manager/bin",
    "ENTRYPOINT [\"/data/manager/bin/console\"]",
    "CMD [\"CMD_пHELP\"]"
  ]
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