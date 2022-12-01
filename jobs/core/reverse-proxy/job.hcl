job "reverse-proxy" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${node.unique.name}"
    value     = "nomad-server"
  }

  group "reverse-proxy" {
    count = 1

    volume "app-data" {
      type      = "host"
      source    = "app-data"
      read_only = false
    }

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

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik.rule=Host(`traefik.{{ cluster_hostname }}`)",
        "traefik.http.routers.traefik.entrypoints=http,https",
{% if env != 'dev' %}
        "traefik.http.routers.traefik.tls=true",
        "traefik.http.routers.traefik.tls.certresolver=https-resolver",
        "traefik.http.routers.traefik.tls.domains[0].main=traefik.{{ cluster_hostname }}"
{% endif %}
      ]

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

      volume_mount {
        volume      = "app-data"
        destination = "/letsencrypt"
        read_only   = false
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
