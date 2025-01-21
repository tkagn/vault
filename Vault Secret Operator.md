# Vault Secret Operator

## Vault Connection

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultConnection
metadata:
  name: vaultconnection-internal
  namespace: quay-enterprise
spec:
  address: 'http://vault.vault.svc.cluster.local:8200'
  skipTLSVerify: false
```

## Vault Auth

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: vaultauth
  namespace: quay-enterprise
spec:
  vaultConnectionRef: vaultconnection-internal
  kubernetes:
    role: svcacct-vault-auth
    serviceAccount: default
    tokenExpirationSeconds: 600
  method: kubernetes
  mount: openshift
  namespace: admin
```

## Vault Static Secret

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: quay-config-bundle
  namespace: quay-enterprise
spec:
  type: kv-v2

  # mount path
  mount: openshift

  # path of the secret
  path: ocp-test/quay-enterprise

  # dest k8s secret
  destination:
    name: config-bundle
    create: true

  # static secret refresh interval
  refreshAfter: 30s

  # Name of the CRD to authenticate to Vault
  vaultAuthRef: vaultauth

```


apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: vaultstaticsecret-config-bundle
  namespace: quay-enterprise
spec:
  destination:
    create: true
    name: config-bundle
  vaultAuthRef: vaultauth
  mount: openshift
  type: kv-v2
  path: ocp-test/quay-enterprise
  namespace: admin


kind: VaultStaticSecret
apiVersion: secrets.hashicorp.com/v1beta1
metadata:
  name: quay-config-bundle
  namespace: quay-enterprise
spec:
  vaultAuthRef: vaultauth
  mount: openshift
  type: kv-v2
  path: ocp-test/quay-enterprise/config-bundle
  refreshAfter: 60s
  destination:
    create: true
    name: quay-config-bundle
