#!/bin/bash

# code by songdaoyuan@20240801
# update 20240823 修正了一些参数的命名方式

# 工作原理
# 1.连接到镜像代理服务器MIRROR_SERVER -> 2.拉取镜像 -> 3.推送到harbor服务器 -> 4.从harbor服务器拉取到本地

# 使用方式
# 首先将这个脚本放在如 /usr/local/bin 的系统变量目录, 使用 chmox +x 授予运行权限
# rdocker $OPERATION $IMAGE_NAME_VERSION

# ToDo 增加镜像存在性校验

set -exu

# 定义基本信息(镜像服务器 & harbor)
MIRROR_SERVER=172.28.12.252
# 修改为你自己的harbor服务器
HARBOR_SERVER=harbor.domain.com/swap/

OPERATION=$1 # 操作类型, 目前只支持 pull
IMAGE_NAME_VERSION=$2 # 获取传入的镜像名和版本

echo "第一次使用时, 确保你已经配置了${MIRROR_SERVER}的SSH免密登录"

# 连接到镜像代理服务器MIRROR_SERVER & 拉取镜像
ssh root@$MIRROR_SERVER "docker pull ${IMAGE_NAME_VERSION}" && echo "remote docker pull successfully" || echo "remote docker pull failed"
# 打标签, 上传到harbor
ssh root@$MIRROR_SERVER "docker tag ${IMAGE_NAME_VERSION} ${HARBOR_SERVER}${IMAGE_NAME_VERSION}"
ssh root@$MIRROR_SERVER "docker push ${HARBOR_SERVER}${IMAGE_NAME_VERSION}"
# 删除本地的冗余镜像
ssh root@$MIRROR_SERVER "docker rmi ${HARBOR_SERVER}${IMAGE_NAME_VERSION}"
# 从harbor拉回镜像
docker pull ${HARBOR_SERVER}${IMAGE_NAME_VERSION} && echo "local docker pull successfully" || echo "local docker pull failed"
