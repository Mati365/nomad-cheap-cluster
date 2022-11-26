name = "nomad-client"
data_dir = "{{ nomad.remote.client.root_dir }}/data"
bind_addr = "0.0.0.0"

client {
  enabled = true

  host_network "internal-cluster-network" {
    cidr = "{{ cluster_cidr }}"
    interface = "{{ cluster_interface }}"
  }

  host_volume "app-data" {
    path = "{{ nfs.app_data_dir }}"
    read_only = false
  }

  template {
    disable_file_sandbox = true
  }

  options   = {
    "docker.auth.config" = "/root/.docker/config.json"
  }
}

advertise {
  http = "ADVERT_IP_ADDR:4646"
  rpc  = "ADVERT_IP_ADDR:4647"
  serf  = "ADVERT_IP_ADDR:4648"
}

consul {
  address = "127.0.0.1:8500"
  token = "{{ nomad_client_policy_key }}"
  auto_advertise      = true
  server_auto_join    = true
  client_auto_join    = true
}

acl {
  enabled = true
}

tls {
  http = true
  rpc  = true

  ca_file   = "{{ nomad.remote.tls_dir }}/nomad-ca.pem"
  cert_file = "{{ nomad.remote.tls_dir }}/client.pem"
  key_file  = "{{ nomad.remote.tls_dir }}/client-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}

vault {
  enabled     = true
  address     = "https://vault.service.consul:8200"
  ca_file     = "{{ vault.remote.tls_dir }}/vault-ca.pem"
  cert_file   = "{{ vault.remote.tls_dir }}/client.pem"
  key_file    = "{{ vault.remote.tls_dir }}/client-key.pem"
}
