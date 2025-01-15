#!/bin/bash
# 用于监视 NGINX 的配置文件, 在发生改变后自动同步到从节点
func() {

        echo "The nginx configuration has changed"
        date
        nginx -t 2>/dev/null
        [ $? -eq 0 ] && rsync -avRtopg --progress --delete /etc/nginx/ root@192.168.7.158:/ || echo "The nginx configuration is not ok, Please check!"
        ssh root@192.168.7.158 "nginx -s reload"
        nginx -s reload
}

while true
do
        sleep 5
        file=`cat /data/md5sum/nginx.md5 |wc -l`
        [ `md5sum -c /data/md5sum/nginx.md5 |awk '{print $2}' | grep -i failed` ] && func || echo "The nginx configuration has not changed!"
        find /etc/nginx/ -type f -type f ! -name ".*" |xargs md5sum > /data/md5sum/nginx.md5
        filenum=`cat /data/md5sum/nginx.md5 |wc -l`
        [ $file -ne $filenum ] && func
        [ -z `find /data/md5sum/rsync.log -type f -size +500M` ] || cat /dev/null > /data/md5sum/rsync.log
done >> /data/md5sum/rsync.log
