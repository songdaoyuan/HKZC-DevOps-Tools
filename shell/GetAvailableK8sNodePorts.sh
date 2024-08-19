#!/bin/bash
# 获取已使用的 K8s NodePort
for port in {30000..32767}
do
  if ! kubectl get services --all-namespaces -o jsonpath='{.items[*].spec.ports[*].nodePort}' | grep -q "\b$port\b"; then
    echo "Port $port is available"
  fi
done