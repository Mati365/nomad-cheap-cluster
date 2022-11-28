job "postgres" {
  datacenters = ["dc1"]
  type = "service"
  priority = 100

  constraint {
    attribute = "${node.unique.name}"
    value     = "nomad-server"
  }

  update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "2m"
    auto_revert = false
    canary = 0
  }

  group "postgres" {
    count = 1

    network {
      mode = "host"

      port "db" {
        static = 5432
      }
    }

    volume "postgres" {
      type      = "host"
      source    = "postgres-data"
      read_only = false
    }

    service {
      name = "postgres"
      port = "db"

      check {
        name = "postgres-check"
        type = "tcp"
        interval = "15s"
        timeout = "3s"
      }
    }

    task "postgres" {
      driver = "docker"

      vault {
        policies  = ["postgres-policy"]
      }

      config {
        image = "{{ addresses.registry }}:5000/nomad-postgres"
        ports = ["db"]
        network_mode = "host"

        volumes = [
          "secrets/db.envs:/etc/db.envs"
        ]
      }

      volume_mount {
        volume      = "postgres"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      template {
        destination = "secrets/db.envs"

        {% raw %}
          data = <<EOF
            {{ with secret "kv-v2/database/postgres" }}
              POSTGRES_USER={{ .Data.data.user }}
              POSTGRES_DB={{ .Data.data.database }}
              POSTGRES_PASSWORD={{ .Data.data.password }}
            {{ end }}
          EOF
        {% endraw %}
      }

      resources {
        cpu    = 1200
        memory = 512
      }
    }
  }
}
