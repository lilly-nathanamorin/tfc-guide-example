provider "vault" {
  # Configured with env variables VAULT_ADDR & VAULT_TOKEN
}


resource "vault_mount" "db" {
  path = "postgres"
  type = "database"
}

