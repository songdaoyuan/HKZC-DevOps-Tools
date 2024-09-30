#!/bin/bash


# code by songdaoyuan@20240930

# 工作原理
# 用Bash自带的 /dev/tcp 功能实现一个 tcp 连接工具

# 使用方式
# tcping $HOST $PORT


HOST=$1 # 域名或者IP地址
PORT=$2 # 端口


# 在Unix-like系统中,每个进程默认有三个标准文件描述符:
#     0: 标准输入 (stdin)
#     1: 标准输出 (stdout)
#     2: 标准错误 (stderr)
#     3: 及以上的数字可以用作自定义文件描述符。


if timeout 3 bash -c "exec 3<>/dev/tcp/${HOST}/${PORT}" 2>/dev/null; then
    echo "${HOST}:${PORT} is open"
else
    echo "${HOST}:${PORT} is closed"
fi