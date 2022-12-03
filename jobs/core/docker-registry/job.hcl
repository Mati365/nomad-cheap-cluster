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
        host_network = "internal-cluster-network"
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

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.registry.rule=Host(`registry.{{ cluster_hostname }}`)",
        "traefik.http.routers.registry.entrypoints=http,https",
        "traefik.http.services.registry.loadbalancer.server.port=5000",
{% if env != 'dev' %}
        "traefik.http.routers.registry.tls=true",
        "traefik.http.routers.registry.tls.certresolver=https-resolver",
        "traefik.http.routers.registry.tls.domains[0].main=registry.{{ cluster_hostname }}"
{% endif %}
      ]

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
        REGISTRY_STORAGE_DELETE_ENABLED = "true"
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
