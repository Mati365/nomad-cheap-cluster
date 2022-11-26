job "docker-registry" {
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

  group "docker-registry" {
    count = 1

    network {
      mode = "host"

      port "http" {
        static = 5000
      }
    }

    volume "docker-registry" {
      type      = "host"
      source    = "docker-registry-data"
      read_only = false
    }

    service {
      name = "docker-registry"
      port = "http"

      check {
        name = "docker-registry-check"
        type = "tcp"
        interval = "60s"
        timeout = "5s"
      }
    }

    task "docker-registry" {
      driver = "docker"

      volume_mount {
        volume      = "docker-registry"
        destination = "/var/lib/registry"
        read_only   = false
      }

      template {
        data = "{{ docker.registry.credentials.passwd }}"
        destination = "secrets/htpasswd"
      }

      env {
        REGISTRY_AUTH = "htpasswd"
        REGISTRY_AUTH_HTPASSWD_REALM = "Registry Realm"
        REGISTRY_AUTH_HTPASSWD_PATH = "/auth/htpasswd"
      }

      config {
        image = "registry:2"
        ports = ["http"]
        network_mode = "host"

        volumes = [
          "secrets/htpasswd:/auth/htpasswd"
        ]
      }
    }
  }
}
