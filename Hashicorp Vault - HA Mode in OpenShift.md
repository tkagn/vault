# Hashicorp Vault - HA Mode in OpenShift

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm search repo hashicorp/vault
helm install vault hashicorp/vault  \
  --set "global.openshift=true" \
  --set "server.ha.enabled=true" \
  --set='server.ha.raft.enabled=true'


oc exec -ti vault-0 -- vault operator init
oc exec -ti vault-0 -- vault operator unseal

oc exec -ti vault-1 -- vault operator raft join http://vault-0.vault-internal:8200
oc exec -ti vault-1 -- vault operator unseal

oc exec -ti vault-2 -- vault operator raft join http://vault-0.vault-internal:8200
oc exec -ti vault-2 -- vault operator unseal


```

overrides.yaml

global:
  openshift: true
server:
  auditStorage:
    storageClass: ocs-storagecluster-ceph-rbd
  dataStorage:
    storageClass: ocs-storagecluster-ceph-rbd
  ha:
    raft:
      enabled: true
    enabled: true
    replicas: 3
  route:
    enabled: true

