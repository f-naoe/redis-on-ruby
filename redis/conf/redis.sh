#!/bin/bash

# 邪魔なファイルを削除。
rm -f \
    log/r6000i.log \
    log/r6001i.log \
    log/r6002i.log \
    log/r6003i.log \
    log/r6004i.log \
    log/r6005i.log \
    conf/nodes.6000.conf \
    conf/nodes.6001.conf \
    conf/nodes.6002.conf \
    conf/nodes.6003.conf \
    conf/nodes.6004.conf \
    conf/nodes.6005.conf ;

#redisを6台クラスターモードで(クラスターモードの設定はredis.conf)起動。
# nodes.****.conf はそれぞれ別々のファイルを指定する必要がある。
redis-server conf/redis.conf --port 6000 --cluster-config-file conf/nodes.6000.conf --daemonize yes ;
redis-server conf/redis.conf --port 6001 --cluster-config-file conf/nodes.6001.conf --daemonize yes ;
redis-server conf/redis.conf --port 6002 --cluster-config-file conf/nodes.6002.conf --daemonize yes ;
redis-server conf/redis.conf --port 6003 --cluster-config-file conf/nodes.6003.conf --daemonize yes ;
redis-server conf/redis.conf --port 6004 --cluster-config-file conf/nodes.6004.conf --daemonize yes ;
redis-server conf/redis.conf --port 6005 --cluster-config-file conf/nodes.6005.conf --daemonize yes ;

REDIS_LOAD_FLG=true;

#全てのredis-serverの起動が完了するまでループ。
while $REDIS_LOAD_FLG;
do
    sleep 1;
    redis-cli -p 6000 info 1> log/r6000i.log 2> /dev/null;
    if [ -s log/r6000i.log ]; then
        :
    else
        continue;
    fi
    redis-cli -p 6001 info 1> log/r6001i.log 2> /dev/null;
    if [ -s log/r6001i.log ]; then
        :
    else
        continue;
    fi
    redis-cli -p 6002 info 1> log/r6002i.log 2> /dev/null;
    if [ -s log/r6002i.log ]; then
        :
    else
        continue;
    fi
    redis-cli -p 6003 info 1> log/r6003i.log 2> /dev/null;
    if [ -s log/r6003i.log ]; then
        :
    else
        continue;
    fi
    redis-cli -p 6004 info 1> log/r6004i.log 2> /dev/null;
    if [ -s log/r6004i.log ]; then
        :
    else
        continue;
    fi
    redis-cli -p 6005 info 1> log/r6005i.log 2> /dev/null;
    if [ -s log/r6005i.log ]; then
        :
    else
        continue;
    fi
    #redis-serverの起動が終わったらクラスター・レプリカの割り当てる。
    yes "yes" | redis-cli --cluster create 127.0.0.1:6000 127.0.0.1:6001 127.0.0.1:6002 127.0.0.1:6003 127.0.0.1:6004 127.0.0.1:6005 --cluster-replicas 1;
    REDIS_LOAD_FLG=false;
done
