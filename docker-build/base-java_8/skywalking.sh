#! /bin/bash
java -javaagent:/skywalking-agent/skywalking-agent.jar \
    -Dskywalking.agent.service_name=$env-$JOB_NAME \
    -server \
    -Xms512m \
    -Xmx1g \
    -Dserver.port=8080 \
    -jar $JOB_NAME.jar \
    --spring.profiles.active=$env

# 在容器中使用
# CMD [
#     "java",
#     "-javaagent:/skywalking-agent/skywalking-agent.jar",
#     "-Dskywalking.agent.service_name=$env-$JOB_NAME",
#     "-server",
#     "-Xms512m",
#     "-Xmx1g",
#     "-Dserver.port=8080",
#     "-jar",
#     "/myapp.jar",
#     "--spring.profiles.active=$env"
# ]
