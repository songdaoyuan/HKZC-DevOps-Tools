#!/bin/bash

# ToDo 1.初始化scripts文件夹(手动添加脚本或者从 Gitee 拉取)
# 可选 调整 skywalking-agent-8.11.0

docker build --no-cache -f Dockerfile-jre_8u422-dbg -t jre_8u422-dbg:latest .