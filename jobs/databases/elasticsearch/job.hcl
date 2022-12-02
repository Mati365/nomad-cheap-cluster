job "elasticsearch" {
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

  group "elasticsearch" {
    count = 1

    network {
      mode = "host"

      port "db" {
        static = 9200
        host_network = "internal-cluster-network"
      }

      port "api" {
        static = 9300
        host_network = "internal-cluster-network"
      }
    }

    volume "elasticsearch" {
      type = "host"
      source = "elasticsearch-data"
      read_only = false
    }

    service {
      name = "elasticsearch"
      port = "db"

      check {
        name = "elasticsearch-check"
        type = "tcp"
        interval = "15s"
        timeout = "3s"
      }
    }

    task "elasticsearch" {
      driver = "docker"

      volume_mount {
        volume      = "elasticsearch"
        destination = "/usr/share/elasticsearch/data"
        read_only   = false
      }

      config {
        image = "{{ addresses.registry }}:5000/nomad-elasticsearch"
        ports = ["db", "api"]
        network_mode = "host"
      }

      env {
        ES_JAVA_OPTS = "-Xms1024m -Xmx1024m"
      }

      resources {
        cpu    = 1000
        memory = 2048
      }
    }
  }
}
