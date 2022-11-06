datacenter = "dc1"
node_name = "consul-server"
server    = true
bootstrap = true
data_dir   = "{{ consul.remote.server.root_dir }}/data"
log_level  = "INFO"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "{{ nomad.remote.advert_real_ip }}"
encrypt = "{{ consul.local.encryption.gossip }}"

tls {
  defaults {
    ca_file = "{{ consul.remote.tls_dir }}/consul-agent-ca.pem"
    cert_file = "{{ consul.remote.tls_dir }}/dc1-server-consul-0.pem"
    key_file = "{{ consul.remote.tls_dir }}/dc1-server-consul-0-key.pem"
    verify_incoming = true
    verify_outgoing = true
  }

  internal_rpc {
    verify_server_hostname = true
  }
}

auto_encrypt {
  allow_tls = true
}

ui_config {
  enabled = true
}

addresses {
  http = "0.0.0.0"
}

telemetry {
  statsite_address = "0.0.0.0:3000"
}

acl {
  enabled = true
  enable_token_persistence = true
  default_policy = "deny"
}

connect {
  enabled = true
}
