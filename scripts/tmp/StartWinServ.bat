@echo off

:: 检查当前用户是否是管理员
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo 需要管理员权限，正在重新启动...
    :: 使用 PowerShell 重新启动脚本以获得管理员权限
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: 已经有管理员权限, 继续
echo 当前已具有管理员权限
:: 在这里放置需要管理员权限的命令

:: 启动 VMWare Ubuntu 虚拟机
cd C:\Program Files (x86)\VMware\VMware Workstation
vmrun start "C:\Users\song daoyuan\Documents\Virtual Machines\Alpine Standard\Alpine Standard.vmx"
echo VMWare虚拟机已经启动

:: 启动 Nacos
cd D:\xxx
start /min cmd /c "your_long_running_script.cmd"
echo Nacos服务已经启动

:: 睡眠60s等待虚拟机完全启动
timeout /t 60 /nobreak
:: 连接到 Ubuntu, 启动OA服务
ssh root@192.168.0.11 "cd /home/scripts/ && bash StartOA.sh"
echo OA服务已经启动

:: 睡眠60s等待OA系统完全启动
timeout /t 60 /nobreak
start http://192.168.0.11:81
start http://192.168.0.11:82
start http://192.168.0.11:83
start http://192.168.0.11:84
start http://192.168.0.11:85

pause
