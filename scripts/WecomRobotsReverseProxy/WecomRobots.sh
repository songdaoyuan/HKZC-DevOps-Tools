#!/bin/bash

# 企业微信机器人的Webhook URL
WEBHOOK_URL=""

# 构建JSON格式的请求体
JSON_DATA=$(
    cat <<EOF
{
"msgtype": "text",
"text": {
    "content": "Test Message"
}
}
EOF
)

# 使用curl发送POST请求到企业微信机器人的Webhook URL
curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$WEBHOOK_URL"
