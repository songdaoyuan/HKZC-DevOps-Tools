#!/bin/bash
# code by songdaoyuan@20240814
# 检测OS版本 -> 卸载现有的Docker -> 安装生产使用的20.10.21
# 流程参考自:https://mirrors.tuna.tsinghua.edu.cn/help/docker-ce/
# 所有需要通过*.docker.*下载的文件均已备份在gitee或者使用TUNA源

set -exu

echo "必须以root用户或者使用sudo权限来运行此脚本, 如果你之前安装过其他版本的Docker或者组件, 请先清理"

su -

os_name=$(hostnamectl | grep 'Operating System' | awk '{print $3}')

# 根据操作系统名称调用对应的包管理器
case "$os_name" in
"CentOS" | "Fedora" | "RHEL")
    yum remove docker \
        docker-client \
        docker-client-latest \
        docker-common \
        docker-latest \
        docker-latest-logrotate \
        docker-logrotate \
        docker-engine
    ;;
"Ubuntu" | "Debian")
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove $pkg; done
    apt-get update
    ;;
*)
    echo "Unsupported distribution: $os_name"
    exit 1
    ;;
esac

export DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce"

wget -O- https://gitee.com/songdaoyuan/hkzc-dev-ops-tools/raw/master/Docker/GetDocker.sh | sh --version 20.10.21

# 如果需要手动安装, 以下是安装流程

# ************************* Ubuntu *******************

# apt-get install ca-certificates curl gnupg
# install -m 0755 -d /etc/apt/keyrings
# curl -fsSL https://gitee.com/songdaoyuan/hkzc-dev-ops-tools/raw/master/Docker/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# sudo chmod a+r /etc/apt/keyrings/docker.gpg
# echo \
#     "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu \
#     "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
#     tee /etc/apt/sources.list.d/docker.list >/dev/null
# apt-get update
# apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ************************* Ubuntu *******************

# ************************* CentOS *******************

# yum install -y yum-utils
# yum-config-manager --add-repo https://gitee.com/songdaoyuan/hkzc-dev-ops-tools/raw/master/Docker/centos/docker-ce.repo
# sed -i 's+https://download.docker.com+https://mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
# yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# ************************* CentOS *******************