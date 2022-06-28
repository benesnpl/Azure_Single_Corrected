terraform {
  required_version = "> 0.14.0"

  required_providers {
    azurerm = {
      version = "~> 2.54"
    }
  }
}

provider "azurerm" {
    features {}
    subscription_id = "1407e914-ef0f-491a-9475-91dbb0fb191b"
    client_id = "9ec8ae03-6112-4cd6-bba4-dbf54ebefa97"
    client_secret = "Thx8Q~zX29t5R6hVjszfkxabQP.8OoZAdxpSFc7h"
    tenant_id = "cf668d98-df58-45c9-86fb-b72c2761364b"
}
