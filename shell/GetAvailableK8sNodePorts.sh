#!/bin/bash
# 获取已使用的 K8s NodePort
used_ports=$(kubectl get services --all-namespaces -o jsonpath='{range .items[*]}{.spec.ports[*].nodePort}{"\n"}{end}' | sort -n | uniq)

# 定义 NodePort 范围
start_port=30000
end_port=32767

# 查找可用的 NodePort
echo "Available NodePorts:"
for ((port=start_port; port<=end_port; port++)); do
    if ! echo "$used_ports" | grep -q "^$port$"; then
        echo $port
    fi
done