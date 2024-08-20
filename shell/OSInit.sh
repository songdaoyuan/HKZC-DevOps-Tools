#!/bin/bash
# code by songdaoyuan@20240816
# 用于初始化部署后的Linux Server
# 基础流程: 
#   1.配置镜像源、更新包列表和软件包、安装必备软件包
#   2.关闭DHCP, 使用固定IP, 使用安全的DNS
#   3.确保SSHD已经开启, 且启用了root的密码登录
#   4.配置时间同步
#   5.关闭SELinux / AppArmor
#   6.处理防火墙
#   7.（可选）解除Linux对密集读写的性能限制, 优化数据库性能

#*********************** 公用的函数, 函数内部的shell指令在发行版中通用

enable_root_ssh_login() {
    # 修改 PermitRootLogin 为 yes
    SSHD_CONFIG="/etc/ssh/sshd_config"
    if grep -q "^PermitRootLogin" $SSHD_CONFIG; then
        sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' $SSHD_CONFIG
    else
        echo "PermitRootLogin yes" | tee -a $SSHD_CONFIG
    fi

    # 修改 PasswordAuthentication 为 yes
    if grep -q "^PasswordAuthentication" $SSHD_CONFIG; then
        sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' $SSHD_CONFIG
    else
        echo "PasswordAuthentication yes" | tee -a $SSHD_CONFIG
    fi
    systemctl restart sshd
    echo "SSH 配置已修改并重启服务。root 用户的 SSH 密码登录已启用。"
}

config_date_sync() {
    timedatectl set-timezone Asia/Shanghai
    systemctl enable chronyd
    systemctl start chronyd
    chronyc -a makestep
}


#*********************** 适用于 RH 系发行版的函数

RH_disable_selinux() {
    setenforce 0
    sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
}

RH_config_static_ip() {
    ip addr show

}


#*********************** 适用于 Debain 系发行版的函数

disable_apparmor() {
    echo
}


config_firewall() {
    echo
}

# Red Hat Enterprise Linux (RHEL)、CentOS、Rocky Linux / AlmaLinux、Fedora Server 默认开启了SELinux

# Red Hat Enterprise Linux (RHEL)、CentOS、Rocky Linux / AlmaLinux、Fedora Server 使用Firewalld
# Debain系传统使用iptables、Ubuntu使用ufw
# openSUSE Leap/SUSE Linux Enterprise Server (SLES) 默认情况下，openSUSE 和 SLES 都使用 firewalld，但它们同时也支持 iptables
# 可以使用systemctl 管理 firewalld、iptables、ufw

# 确保脚本以root权限运行
if [ "$(id -u)" != "0" ]; then
   echo "必须以root用户或者使用sudo权限来运行此脚本, 这个脚本会按序执行命令初始化SRV" 1>&2
   exit 1
fi
echo "在生产模式中启用root的SSH登录以及关闭SELinux / AppArmor是不安全的, 请注意做好服务器加固工作"

os_name=$(hostnamectl | grep 'Operating System' | awk '{print $3}')

# 根据操作系统名称调用对应的包管理器
case "$os_name" in
"CentOS" | "Fedora" | "RHEL" | "Rocky" | "AlmaLinux")

    # 配置镜像源、更新包列表和软件包、安装必备软件包
    yum update -y
    yum -y install curl vim openssh-server chrony

    # 关闭SELinux
    RH_disable_selinux

    ;;
"Ubuntu" | "Debian")

    # 配置镜像源、更新包列表和软件包、安装必备软件包
    apt update && apt upgrade -y
    apt install curl vim openssh-server chrony -y

    # 关闭AppArmor
    disable_apparmor

    ;;
*)
    echo "Unsupported distribution: $os_name"
    exit 1
    ;;
esac

enable_root_ssh_login
config_date_sync
