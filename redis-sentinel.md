<center>AICP能力平台10C部署记录</center>

#1. redis-sentinel模式部署  

机器列表：  

|IP/PORT | ROLE   
| ----   | ----   
|10.0.20.82:6399 | master  
|10.0.20.83:6399 | slave  
|10.0.20.84:6399 | slave  
|10.0.20.82:26399 | sentinel  
|10.0.20.83:26399 | sentinel  
|10.0.20.84:26399 | sentinel  


##1.1 redis配置

部署目录：  
　　/home/hcicloud/software/redis  
redis-master 【master配置文件】
>port 6799  
>bind 0.0.0.0  
>daemonize yes  
>pidfile /home/hcicloud/software/redis/runredis-6799.pid  
>dir "/home/hcicloud/software/redis/data"
>logfile "/home/hcicloud/software/redis/log/redis-6379.log"

  
redis-slave节点配置：
>port 6799  
>bind 0.0.0.0  
>daemonize yes  
>pidfile /home/hcicloud/software/redis/runredis-6799.pid  
>dir "/home/hcicloud/software/redis/data"
>logfile "/home/hcicloud/software/redis/log/redis-6379.log"

> \#从 master 复制数据时，使用此密码访问 master  
>masterauth passcode  

> \#redis 密码，无此配置项时，访问 redis 不需要密码  
>requirepass passcode 

相比master节点配置多了  replicaof 和 masterauth  

sentinel节点配置：
>  port 26379  
>  bind 0.0.0.0  
>  daemonize yes  
>  protected-mode no  
>  pidfile /var/run/redis-sentinel.pid  
>  sentinel auth-pass hci_master xxxx  
>  sentinel monitor hci_master 10.0.0.101 6379 2  
>  sentinel down-after-milliseconds  hci_master 10000  
>  sentinel parallel-syncs hci_master 1  
>  sentinel failover-timeout hci_master 5000  

##1.2 redis启动

进入/home/hcicloud/software/redis目录下
启动redis实例：  
> ./redis-server  ./redis.conf

启动redis-sentinel实例：
> ./redis-sentinel  ./sentinel.conf 

## 1.3 redis-sentinel 验证

连接到redis-sentinel节点
> [hcicloud@localhost redis]$ ./redis-cli   -h 10.0.20.82 -p 26379  \#连接任意哨兵节点
> 10.0.20.82:26379> SENTINEL get-master-addr-by-name hci_master  
> 1) "10.0.20.84"  
> 2) "6379"  

其他常用命令如下：
> sentinel master asr_trans_master# 查看master的状态  
> SENTINEL slaves asr_trans_master # 查看salves的状态  
> SENTINEL sentinels asr_trans_master # 查看哨兵的状态  
> info sentinel # 查看哨兵信息  
> role # 查询此redis的角色  

