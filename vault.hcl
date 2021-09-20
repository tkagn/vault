ha_storage "raft" {
 path    = "/vault/storage/"
}

storage "file" {
  path = "/vault/storage/data"
}

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_cert_file      = "/vault/tls/vault.pem"
  tls_key_file       = "/vault/tls/vault.key"
  tls_client_ca_file = "/vault/tls/ca.pem"
}

disable_mlock = true
api_addr = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8231"
ui = true
