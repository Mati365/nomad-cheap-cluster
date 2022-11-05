job "docs" {
  datacenters = ["dc1"]

  group "example" {
    count = 2

    update {
      max_parallel     = 1
      canary           = 1
      min_healthy_time = "15s"
      healthy_deadline = "5m"
      auto_revert      = true
      auto_promote     = true
    }

    network {
      mode = "bridge"

      port "http" {
        to = 5678
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":5678",
          "-text",
          "hello world 2",
        ]
      }
    }
  }
}
