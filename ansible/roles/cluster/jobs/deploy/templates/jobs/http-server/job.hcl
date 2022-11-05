job "http-server" {
  datacenters = ["dc1"]

  group "http-server" {
    count = 4

    update {
      max_parallel     = 1
      canary           = 1
      min_healthy_time = "15s"
      healthy_deadline = "5m"
      auto_revert      = true
      auto_promote     = true
    }

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "http-server"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.example.rule=Host(`example.app`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "echo" {
      driver = "docker"

      config {
        image = "hashicorp/http-echo"
        ports = ["http"]
        args = [
          "-listen",
          ":${NOMAD_PORT_http}",
          "-text",
          "hello world ${node.unique.name}",
        ]
      }
    }
  }
}
