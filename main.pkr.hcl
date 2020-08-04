source "null" "example" {
  communicator = "none"
}

build {
  name = "Main"
  sources = [
    "source.null.example"
  ]

  provisioner "shell-local" {
    inline = [
      "build.cmd"
    ]
  }
}