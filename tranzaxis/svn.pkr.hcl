source "docker" "svn" {
  image = "mamohr/subversion-edge"
  export_path = "svn.tar"
}

build {
  source = [
    "source.docker.svn"
  ]

}