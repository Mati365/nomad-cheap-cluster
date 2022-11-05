name = "nomad-server"
data_dir = "{{ nomad.remote.server.root_dir }}/data"
bind_addr = "0.0.0.0"

server {
  enabled = true
  bootstrap_expect = 1
}

client {
  enabled = true
}

advertise {
  http = "{{ nomad.remote.advert_real_ip }}:4646"
  rpc  = "{{ nomad.remote.advert_real_ip }}:4647"
  serf  = "{{ nomad.remote.advert_real_ip }}:4648"
}

consul {
  address = "127.0.0.1:8500"
  token = "{{ nomad_server_policy_key }}"
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
  cert_file = "{{ nomad.remote.tls_dir }}/server.pem"
  key_file  = "{{ nomad.remote.tls_dir }}/server-key.pem"

  verify_server_hostname = {{ (env != 'dev') | to_json }}
  verify_https_client    = {{ (env != 'dev') | to_json }}
}
