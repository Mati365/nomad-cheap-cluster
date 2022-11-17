cluster_addr  = "https://{{ nomad.remote.advert_real_ip }}:8201"
api_addr      = "https://{{ nomad.remote.advert_real_ip }}:8200"

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "{{ vault.remote.tls_dir }}/server.pem"
  tls_key_file       = "{{ vault.remote.tls_dir }}/server-key.pem"
  tls_client_ca_file = "{{ vault.remote.tls_dir }}/vault-ca.pem"
}

storage "consul" {
  address = "http://127.0.0.1:8500"
  path = "vault/"
  token = "{{ vault_service_policy_key }}"
}
