datacenter = "dc1"
node_name  = "consul-node-NODE_ID"
server     = false
data_dir   = "{{ consul.remote.client.root_dir }}/data"
log_level  = "INFO"
retry_join = ["{{ addresses.consul.ip }}"]
bind_addr = "0.0.0.0"
advertise_addr = "ADVERT_IP_ADDR"

encrypt = "{{ consul.local.encryption.gossip }}"

tls {
  defaults {
    ca_file = "{{ consul.remote.tls_dir }}/consul-agent-ca.pem"
    cert_file = "{{ consul.remote.tls_dir }}/dc1-client-consul-0.pem"
    key_file = "{{ consul.remote.tls_dir }}/dc1-client-consul-0-key.pem"
    verify_incoming = true
    verify_outgoing = true
  }

  internal_rpc {
    verify_server_hostname = true
  }
}

acl {
  enabled = true
  enable_token_persistence = true
  default_policy = "deny"
  tokens {
    agent = "{{ agent_policy_key }}"
  }
}

auto_encrypt = {
  tls = true
}
