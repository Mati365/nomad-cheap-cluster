datacenter = "dc1"
node_name  = "consul-node-{{ node_id }}"
server     = false
data_dir   = "{{ consul.remote.client.root_dir }}/data"
log_level  = "INFO"
retry_join = ["{{ addresses.consul.ip }}"]
bind_addr = "0.0.0.0"
advertise_addr = "{{ nomad.remote.advert_real_ip }}"

encrypt = "{{ consul.local.encryption.gossip }}"

tls {
  defaults {
    ca_file = "{{ consul.remote.tls_dir }}/consul-agent-ca.pem"
    cert_file = "{{ consul.remote.tls_dir }}/dc1-client-consul-0.pem"
    key_file = "{{ consul.remote.tls_dir }}/dc1-client-consul-0-key.pem"
    verify_incoming = false
    verify_outgoing = true
  }

  internal_rpc {
    verify_server_hostname = true
  }
}

service {
  id      = "dns"
  name    = "dns"
  tags    = ["primary"]
  address = "localhost"
  port    = 8600
  token   = "{{ agent_dns_policy_key }}"
  check {
    id       = "dns"
    name     = "Consul DNS TCP on port 8600"
    tcp      = "localhost:8600"
    interval = "10s"
    timeout  = "1s"
  }
}

acl {
  enabled        = true
  enable_token_persistence = true
  default_policy = "deny"
  tokens {
    agent = "{{ agent_policy_key }}"
  }
}
