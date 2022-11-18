ui = true

cluster_addr  = "https://ADVERT_IP_ADDR:8201"
api_addr      = "https://ADVERT_IP_ADDR:8200"

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "{{ vault.remote.tls_dir }}/server.pem"
  tls_key_file       = "{{ vault.remote.tls_dir }}/server-key.pem"
  tls_client_ca_file = "{{ vault.remote.tls_dir }}/vault-ca.pem"
}

storage "raft" {
  path = "{{ vault.remote.server.root_dir }}/data"
}

service_registration "consul" {
  address = "http://127.0.0.1:8500"
  token = "{{ vault_service_policy_key }}"
}
