# https://developer.hashicorp.com/nomad/tutorials/stateful-workloads/stateful-workloads-host-volumes
job "postgres" {
  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${node.unique.name}"
    value     = "nomad-server"
  }

   update {
    max_parallel = 1
    min_healthy_time = "5s"
    healthy_deadline = "5m"
    auto_revert = false
    canary = 0
  }

  group "postgres" {
    count = 1

    network {
      mode = "bridge"

      port "db" {
        host_network = "internal-cluster-network"
        static = 5432
        to = 5432
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
        name = "postgresql_check"
        type = "tcp"
        interval = "60s"
        timeout = "5s"
      }
    }

    task "postgres" {
      driver = "docker"

      vault {
        env = true
        policies  = ["postgres-policy"]
      }

      volume_mount {
        volume      = "postgres"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      env {
        POSTGRES_USER = "postgres"
        POSTGRES_PASSWORD = "postgres"
        POSTGRES_DB = "postgres"
      }

      config {
        image = "postgres:15.1"
        ports = ["db"]

        volumes = [
          "secrets/pass.env:/etc/pass.env"
        ]
      }

      template {
        destination = "secrets/pass.env"

        {% raw %}
          data = <<EOF
            {{ with secret "kv-v2/data/database/postgres" }}
              POSTGRES_PASSWORD = {{ .Data.password }}
              POSTGRES_DB =  {{ .Data.db }}
              POSTGRES_USER = {{ .Data.user }}
            {{ end }}
          EOF
        {% endraw %}
      }
    }
  }
}
