#!/bin/bash

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: prod-clusterissuer123
  namespace: cert-manager
stringData:
  tls.key: |
    $(openssl genrsa 2048)
type: Opaque
EOF
