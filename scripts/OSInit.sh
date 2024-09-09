#!/bin/bash
# code by songdaoyuan@20240816
# 20240821 V0.1
# 用于初始化部署后的Linux Server
# 基础流程:
#  √ 1.配置镜像源、更新包列表和软件包、安装必备软件包
#  √ 2.关闭DHCP, 使用固定IP, 使用安全的DNS
#  √ 3.确保SSHD已经开启, 且启用了root的密码登录
#  √ 4.配置时间同步
#  √ 5.关闭SELinux / AppArmor
#  √ 6.处理防火墙
#  √ 7.（可选）解除Linux对密集读写的性能限制, 优化数据库性能

# 考虑到有些服务器没有wget 使用curl替换

#*********************** 公用的函数, 函数内部的shell指令在发行版中通用

config_mirror() {
    # 检测发行版类型和版本
    # 目前只适配了Ubuntu全系和CentOS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    # 转换为小写
    OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
    case $OS in
    *"ubuntu"*)
        echo "检测到 Ubuntu $VER"
        SOURCE_LIST=/etc/apt/sources.list
        TUNA_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
        ALI_MIRROR="https://mirrors.aliyun.com/ubuntu/"
        cp $SOURCE_LIST ${SOURCE_LIST}.bak
        cat /dev/null >$SOURCE_LIST
        echo "deb $TUNA_MIRROR $(lsb_release -cs) main restricted universe multiverse" >>SOURCE_LIST
        echo "deb $TUNA_MIRROR $(lsb_release -cs)-updates main restricted universe multiverse" >>SOURCE_LIST
        echo "deb $TUNA_MIRROR $(lsb_release -cs)-backports main restricted universe multiverse" >>SOURCE_LIST
        echo "deb $ALI_MIRROR $(lsb_release -cs)-security main restricted universe multiverse" >>SOURCE_LIST

        # 更新包列表和软件包、安装必备软件包
        apt update && apt upgrade -y
        apt install curl vim openssh-server chrony -y
        ;;
    *"centos"* | *"red hat"* | *"rhel"*)
        echo "检测到 CentOS/RHEL $VER"
        mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
        wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-${VER}.repo

        # 更新包列表和软件包、安装必备软件包
        yum clean all && yum makecache
        yum update -y
        yum -y install curl vim openssh-server chrony
        ;;
    *)
        echo "非适配的Linux发行版: ${OS}${VER}"
        ;;
    esac
    echo "替换镜像源完成"
}

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

get_netinfo() {
    # 获取当前活动的网络接口
    INTERFACE=$(ip route | grep default | awk '{print $5}')
    # 获取当前IP地址
    CURRENT_IP=$(ip addr show $INTERFACE | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
    # 获取默认网关
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    # 获取子网掩码
    NETMASK=$(ip addr show $INTERFACE | grep "inet\b" | awk '{print $2}' | cut -d/ -f2)

    # 获取DNS服务器(主Ali, 副Cloudflare)
    DNS1="223.5.5.5"
    DNS2="1.1.1.1"

    # 打印当前网络信息
    echo "当前网络配置为:"
    echo "活动的网卡: $INTERFACE"
    echo "IP 地址: $CURRENT_IP"
    echo "网关: $GATEWAY"
    echo "子网掩码: $NETMASK"

    # 询问是否要更改IP地址
    read -p "需要修改当前的IP地址吗? (y/n): " change_ip

    if [ "$change_ip" = "y" ]; then
        read -p "输入新的IP地址: " NEW_IP
    else
        NEW_IP=$CURRENT_IP
    fi
}

unlock_resource_limits() {
    LIMITS_CONF="/etc/security/limits.conf"
    DB="mysql"
    echo "#UNLOCK $DB RESOURCE LIMITS" >>$LIMITS_CONF
    echo "$DB  soft      nice       0" >>$LIMITS_CONF
    echo "$DB  hard      nice       0" >>$LIMITS_CONF
    echo "$DB  soft      as         unlimited" >>$LIMITS_CONF
    echo "$DB  hard      as         unlimited" >>$LIMITS_CONF
    echo "$DB  soft      fsize      unlimited" >>$LIMITS_CONF
    echo "$DB  hard      fsize      unlimited" >>$LIMITS_CONF
    echo "$DB  soft      nproc      65536" >>$LIMITS_CONF
    echo "$DB  hard      nproc      65536" >>$LIMITS_CONF
    echo "$DB  soft      nofile     65536" >>$LIMITS_CONF
    echo "$DB  hard      nofile     65536" >>$LIMITS_CONF
    echo "$DB  soft      core       unlimited" >>$LIMITS_CONF
    echo "$DB  hard      core       unlimited" >>$LIMITS_CONF
    echo "$DB  soft      data       unlimited" >>$LIMITS_CONF
    echo "$DB  hard      data       unlimited" >>$LIMITS_CONF
}

disable_firewall() {

    # Red Hat Enterprise Linux (RHEL)、CentOS、Rocky Linux / AlmaLinux、Fedora Server 使用Firewalld
    # Debain系传统使用iptables、Ubuntu使用ufw
    # openSUSE Leap/SUSE Linux Enterprise Server (SLES) 默认情况下，openSUSE 和 SLES 都使用 firewalld，但它们同时也支持 iptables
    # 可以使用systemctl 管理 firewalld、iptables、ufw

    if systemctl is-active --quiet firewalld; then
        systemctl stop firewalld
        systemctl disable firewalld
        echo "firewalld 已停用"
    elif systemctl is-active --quiet ufw; then
        systemctl stop ufw
        systemctl disable ufw
        echo "ufw 已停用"
    elif systemctl is-active --quiet iptables; then
        systemctl stop iptables
        systemctl disable iptables
        echo "iptables 已停用"
    else
        echo "系统中未找到活动的防火墙"
    fi
}

#*********************** 适用于 RH 系发行版的函数

RH_disable_selinux() {
    # Red Hat Enterprise Linux (RHEL)、CentOS、Rocky Linux / AlmaLinux、Fedora Server 默认开启了SELinux
    setenforce 0
    sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
}

RH_config_static_ip() {
    get_netinfo

    # 创建新的网络配置文件
    CONFIG_FILE="/etc/sysconfig/network-scripts/ifcfg-$INTERFACE"

    echo "DEVICE=$INTERFACE" >$CONFIG_FILE
    echo "BOOTPROTO=static" >>$CONFIG_FILE
    echo "ONBOOT=yes" >>$CONFIG_FILE
    echo "IPADDR=$NEW_IP" >>$CONFIG_FILE
    echo "NETMASK=255.255.255.0" >>$CONFIG_FILE
    echo "GATEWAY=$GATEWAY" >>$CONFIG_FILE
    echo "DNS1=$DNS1" >>$CONFIG_FILE
    echo "DNS2=$DNS2" >>$CONFIG_FILE

    # 重启网络服务
    systemctl restart NetworkManager
}

#*********************** 适用于 Debain 系发行版的函数

DB_disable_apparmor() {
    systemctl disable apparmor
}

DB_config_static_ip() {
    get_netinfo

    # 创建新的Netplan配置文件
    CONFIG_FILE="/etc/netplan/01-netcfg.yaml"

    cat <<EOF >$CONFIG_FILE
    network:
      version: 2
      renderer: networkd
      ethernets:
        $INTERFACE:
          dhcp4: no
          addresses: 
            - $NEW_IP/$NETMASK
          routes:
            - to: default
              via: $GATEWAY
          nameservers:
            addresses: [$DNS1, $DNS2]
EOF

    # 应用新的网络配置
    chmod 600 $CONFIG_FILE
    netplan apply
}

# 确保脚本以root权限运行
if [ "$(id -u)" != "0" ]; then
    echo "必须以root用户或者使用sudo权限来运行此脚本, 这个脚本会按序执行命令初始化Linux Server" 1>&2
    exit 1
fi
echo "在生产模式中启用root的SSH登录以及关闭SELinux/AppArmor是不安全的, 请注意做好服务器加固工作"

#****************模块化测试区域

# exit 1
#****************结束

os_name=$(hostnamectl | grep 'Operating System' | awk '{print $3}')
case "$os_name" in
"CentOS" | "Fedora" | "RHEL" | "Rocky" | "AlmaLinux")
    
    # 第一步: 配置镜像源
    config_mirror
    # 第二步: 配置网络
    RH_config_static_ip
    # 第三步: 配置SSHD
    enable_root_ssh_login
    # 第四步: 配置时间同步
    config_date_sync
    # 第五步: 关闭安全组件
    RH_disable_selinux
    # 第六步: 关闭防火墙
    disable_firewall
    # 第七步（可选）: 解除Linux进程资源限制
    # unlock_resource_limits

    ;;
"Ubuntu" | "Debian")
    
    # 第一步: 配置镜像源
    config_mirror
    # 第二步: 配置网络
    DB_config_static_ip
    # 第三步: 配置SSHD
    enable_root_ssh_login
    # 第四步: 配置时间同步
    config_date_sync
    # 第五步: 关闭安全组件
    DB_disable_apparmor
    # 第六步: 关闭防火墙
    disable_firewall
    # 第七步（可选）: 解除Linux进程资源限制
    # unlock_resource_limits

    ;;
*)
    echo "Unsupported distribution: $os_name"
    exit 1
    ;;
esac