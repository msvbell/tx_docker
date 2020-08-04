source "null" "db" {
  communicator = "none"
}

build {
  sources = [
    "source.null.db"
  ]

  post-processor "shell-local" {
    inline = [
      "cd ${path.cwd}/docker-images-master/OracleDatabase/SingleInstance/dockerfiles/",
      "bash -c './buildDockerImage.sh -v 12.2.0.1 -e'"
    ]
  }
}