#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh \
    --apiserver-endpoint '${endpoint}' \
    --b64-cluster-ca '${authority_data}' \
    --kubelet-extra-args '${kubelet_extra_args}' \
    '${cluster_name}'