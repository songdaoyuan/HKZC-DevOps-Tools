#!/bin/bash

set -exu

#前端环境编译

npm install -g yarn

cd web

yarn install && yarn run build

cd ..
# 将 pnpm 构建生成的所有产物移动到 Node 镜像中

cat > Dockerfile << 'EOF'

FROM dev-harbor.hysz.co/basics/nodejs_22.15:latest

MAINTAINER songdaoyuan

LABEL description="基于Next.js的Dify前端服务二次开发" \
    version="0.0.1_Preview" \
    create_by="Lihongming Songdaoyuan"

WORKDIR /home/node/app

# 复制文件夹中的内容而不保留文件夹本身
COPY web/.next/standalone/ .

EXPOSE 3000

CMD node server.js 

EOF

docker build -t dev-harbor.hysz.co/$env/$env-$JOB_NAME:latest .

docker push dev-harbor.hysz.co/$env/$env-$JOB_NAME:latest

docker rmi dev-harbor.hysz.co/$env/$env-$JOB_NAME:latest

# 准备 docker-compose.yml
# 使用 cat > docker-compose.yml << 'EOF'，带引号的EOF限制转义变量
# 使用 host.docker.internal 和宿主机交换数据

cat > docker-compose.yml << EOF
version: "2"
services:
  node:
    image: dev-harbor.hysz.co/$env/$env-$JOB_NAME:latest
    container_name: fs-dify-web
    user: "node"
    environment:
      - NODE_ENV=production
    ports:
      - "8080:3000"
    extra_hosts:
      - "host.docker.internal:host-gateway"
EOF