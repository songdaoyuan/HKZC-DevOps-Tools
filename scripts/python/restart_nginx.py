"""
code by songdaoyuan@2024.7.9
用于重启公司的主、从Nginx服务器

build with nuitka in Python3.8(venv, 兼容Win7)
Package: 
    fabric3.2.2 / invoke2.2.0 / nuitka2.3.22
command:
    nuitka --standalone --onefile restart_nginx.py

TODO 同时执行多条语句采用fabric库中的GroupCommander
TODO 执行命令后采取读取远程NG服务器状态的方式确认命令执行成功
TODO 优化nuitka打包内容, 考虑多脚本共用环境, 降低打包大小
"""

from fabric import Connection
from invoke import Responder

user = "root"
password = "password"

HostIP = "192.168.6.214"
Host2IP = "192.168.6.217"

YesResponder = Responder(pattern=r"(yes/no/[fingerprint])", response="yes\n")


conn = Connection(
    host=HostIP, user=user, connect_kwargs={"password": password, "timeout": 10}
)
try:
    command = "systemctl restart nginx"
    # 重启nginx-master
    # TODO 使用groupCommander
    result = conn.run(
        command, watchers=[YesResponder], pty=True, hide=False, warn=True, timeout=10
    )
    print(result.stdout)
    if result.ok:
        msg = f"restart nginx with ip:{HostIP}成功"
    else:
        msg = f"restart nginx with ip:{HostIP}失败"
    print(msg)
    conn.close()
except Exception as e:
    pass

# 重启nginx-salve, 临时使用, 直接复制代码块
conn = Connection(
    host=Host2IP, user=user, connect_kwargs={"password": password, "timeout": 10}
)
try:
    command = "systemctl restart nginx"
    # 重启nginx-slave
    # TODO 使用groupCommander
    result = conn.run(
        command, watchers=[YesResponder], pty=True, hide=False, warn=True, timeout=10
    )
    print(result.stdout)
    if result.ok:
        msg = f"restart nginx with ip:{Host2IP}成功"
    else:
        msg = f"restart nginx with ip:{Host2IP}失败"
    print(msg)
    conn.close()
except Exception as e:
    pass

input("Press Enter to exit...")
