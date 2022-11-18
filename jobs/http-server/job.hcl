job "http-server" {
  datacenters = ["dc1"]

  group "http-server" {
    count = 3

    network {
      mode = "bridge"

      port "http" {
        host_network = "internal-cluster-network"
        to = 80
      }
    }

    service {
      name = "http-server"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.example.rule=Path(`/`)",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "1s"
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
