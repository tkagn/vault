# Vault Kube Auth

## Prerequisites

- HashiCorp Vault admin access
- Red Hat OpenShift admin access


## OpenShift - Create RHOCP Namespace for Vault Kuberenetes-Auth Service Account

```bash
# Namespace for service accout
oc new-project vault-secrets-operator

# Create service account to perform token reviews
oc create sa svcacct-vault-auth

## Give service account permission to perform token reviews
oc adm policy add-cluster-role-to-user --rolebinding-name='crb-tokenreviewer-svcacct-vault-auth' system:auth-delegator system:serviceaccount:vault-secrets-operator:svcacct-vault-auth

## Create JWT token for service account
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: svcacct-vault-auth-token
  namespace: vault-secrets-operator
  annotations:
    kubernetes.io/service-account.name: svcacct-vault-auth
type: kubernetes.io/service-account-token
data: {}
EOF

# Get JWT token
oc get -n vault-secrets-operator secret/svcacct-vault-auth-token -o json | jq .data.token | base64 -d -w0

# Get CA
oc exec -n  -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt >> ca.crt
oc get -n vault-secrets-operator secret/svcacct-vault-auth-token -o json | jq -r '.data["ca.crt"]' | base64 -d -w0

-o jsonpath='{.data["ca.crt"]}'
```

## Vault - Setup the Kubernetes auth backend

```bash
vault auth enable -path kubenetes/<clustername> kubernetes
vault write auth/kubernetes/<clustername>config token_reviewer_jwt=<service account token> kubernetes_host=<cluster api address> kubernetes_ca_cert=<cluster ca.crt> 

```


## Vault - Generate Secret Engine for RHOCP cluster to Protect Secrets

```bash
oc project vault
oc exec -ti vault-0 -- /bin/bash

# Create secret engine
vault secrets enable -path=openshift -version=2 kv


## Create Policy 
cat << EOF | vault policy write vault-secrets-operator -
path "openshift/<clustername>/*" {
  capabilities = ["read"]
}

EOF

# Create a role named, 'vault-secrets-operator' to map Kubernetes Service Account to Vault policies and default token TTL
vault write auth/kubernetes/<clustername>/role/vault-secrets-operator \
  bound_service_account_names="svcacct-vault-auth" \
  bound_service_account_namespaces="vault-secrets-operator" \
  policies=vault-secrets-operator \
  ttl=24h



```



# Test Access

```bash
curl -k \
    --request POST \
    --data '{"jwt": "<your service account jwt>", "role": "<Kube Auth Role>"}' \
    http://<cluster>:8200/v1/auth/<auth-method name>kubernetes/login | jq .
```




## Resources

https://www.redhat.com/en/blog/vault-integration-using-kubernetes-authentication-method
https://github.com/ricoberger/vault-secrets-operator
