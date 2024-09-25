#!/bin/bash

systemctl restart redis-server
systemctl restart nginx

cd /home/docker-compose/8081-prod-basic-gateway && docker-compose down && docker-compose up -d
cd /home/docker-compose/8082-prod-data-office-basic-func-server && docker-compose down && docker-compose up -d
cd /home/docker-compose/8083-prod-system-center-user-func-server && docker-compose down && docker-compose up -d
cd /home/docker-compose/8084-prod-system-wechat-server && docker-compose down && docker-compose up -d
cd /home/docker-compose/8085-prod-bpmn-camunda-server-provider && docker-compose down && docker-compose up -d
cd /home/docker-compose/8086-prod-bpmn-camunda-sync-provider && docker-compose down && docker-compose up -d
cd /home/docker-compose/8087-prod-bpmn-camunda-system-provider && docker-compose down && docker-compose up -d
cd /home/docker-compose/8088-prod-form-engine-server-provider && docker-compose down && docker-compose up -d
