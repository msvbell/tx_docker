source "docker" "db" {
  image = "alpine"
  export_path = "db.tar"
}

build {
  name = "DB"

  sources = [
    "sources.docker.db"
  ]

  post-processor "docker-import" {
    repository = "local/oracle-db"
    tag = "latest"
  }
}