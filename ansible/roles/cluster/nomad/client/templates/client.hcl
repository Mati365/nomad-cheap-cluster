name = "nomad-client"
data_dir = "{{ nomad.remote.client.root_dir }}/data"
bind_addr = "0.0.0.0"

client {
  enabled = true

  template {
    disable_file_sandbox = true
  }
}

advertise {
  http = "{{ nomad.remote.advert_real_ip }}:4646"
  rpc  = "{{ nomad.remote.advert_real_ip }}:4647"
  serf  = "{{ nomad.remote.advert_real_ip }}:4648"
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
