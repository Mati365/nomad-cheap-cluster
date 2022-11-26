job "reverse-proxy" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${node.unique.name}"
    value     = "nomad-server"
  }

  group "reverse-proxy" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 80
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        type     = "http"
        port     = "api"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik:v2.2"
        network_mode = "host"
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data  = file("{{ remote_job_dir }}/config.toml")
        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
  }
}
