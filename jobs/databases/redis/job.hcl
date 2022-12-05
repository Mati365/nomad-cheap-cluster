job "cache" {
  datacenters = ["dc1"]
  type = "service"
  priority = 80

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

  group "cache" {
    count = 1

    network {
      mode = "host"

      port "db" {
        static = 6379
        host_network = "internal-cluster-network"
      }
    }

    service {
      name = "redis"
      port = "db"

      check {
        name = "redis-check"
        type = "tcp"
        interval = "15s"
        timeout = "3s"
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:7.0.5"
        ports = ["db"]
        network_mode = "host"
      }

      resources {
        cpu    = 1100
        memory = 256
      }
    }
  }
}
