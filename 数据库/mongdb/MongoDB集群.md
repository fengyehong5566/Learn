# MongoDB主从复制 

## 主从复制原理
	1、在主从结构中，主节点的操作记录成为oplog(operation log)。oplog保存在系统数据库local中的oplog.$main中，这个集合的每个文档就是在主服务器上执行的操作。  
	2、从服务器会定期从主服务中获取oplog记录，然后在本机执行，以确保从服务器与主服务器的数据一致

## 搭建主从复制

>	环境描述：
		192.168.87.102	node01	master服务器
		192.168.87.103	node02	slave服务器
		
1、确保时间同步、主机名解析、关闭防火墙及SELinux

2、在两台机器上安装mongodb

3、配置master服务器如下
```
[root@node01 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.102
	port=7000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false
	master=true
```

4、配置slave服务器如下
```
[root@node02 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.103
	port=8000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false
	slave=true
	source=192.168.87.102:7000
```
	
5、分别在两台机器上启动mongod服务，并查看端口 

```
[root@node01 ~]# netstat -antp | grep mongo
tcp        0      0 192.168.87.102:7000     0.0.0.0:*               LISTEN      1619/mongod         
tcp        0      0 192.168.87.102:7000     192.168.87.103:52907    ESTABLISHED 1619/mongod         
```
	
	
6、验证主从数据复制

mongo在从库上默认不可读，需要设置才行。mongodb 3.0版本设置如下：
```	
	> rs.slaveOk()
```


# MongoDB副本集(replSet)

>1、mongo副本集/复制集是mongo高可用性特征之一，是有自动故障恢复功能的主要集群。由一个Primary节点和一个或多个Secondary节点组成。
2、Mongodb客户端的所有数据都写入Primary，Secondary从Primary同步写入的数据，来保持复制集内所有成员存储相同的数据集，提供数据的高可用


## 复制集的原理
>
	1、主节点记录所有的变更到oplog日志

	2、辅助节点(Secondary)复制主节点的oplog日志并且将这些日志在辅助节点进行重放

	3、各个节点之间会定期发送心跳信息，一旦主节点宕机，则触发选举一个新的主节点，剩余的辅助节点指向新的主

	4、10s内各辅助节点无法感知主节点的存在，则开始触发选举

	5、通常1分钟内完成主辅助节点切换，10-30s内感知主节点故障，10-30s内完成选举及切换



## 搭建MongoDB副本集

	环境描述：
		192.168.87.102	node01	PRIMARY服务器
		192.168.87.103	node02	SECONDARY服务器
		192.168.87.104	node03	SECONDARY服务器


1、确保时间同步、主机名解析、关闭防火墙及SELinux

2、在各节点安装mongoDB

3、各节点配置文件如下，配置完后启动mongod服务

```
192.168.87.102：

[root@node01 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.102
	port=7000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false

	replSet=mycluster/192.168.87.103:8000


192.168.87.103：

[root@node02 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.103
	port=8000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false

	replSet=mycluster/192.168.87.104:9000


192.168.87.104:

[root@node03 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.104
	port=9000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false

	replSet=mycluster/192.168.87.102:7000

启动mongodb集群：
各台机器执行：

	$MONGODB_HOME/bin/mongod --maxConns 20000 --config $MONGODB_HOME/mongodb.conf
```

注：【也可制作启动脚本】
```
cat  /etc/init.d/mongod

#!/bin/sh
# chkconfig: - 64 36
# description:mongod

ulimit -SHn 655350

case $1 in

start)
	/usr/local/mongodb/bin/mongod --maxConns 20000 --config /usr/local/mongodb/mongodb.conf
	;;

stop)
	/usr/local/mongodb/bin/mongo 127.0.0.1:27017/admin --eval "db.shutdownServer()"

	#/usr/local/mongodb/bin/mongo 127.0.0.1:27017/admin --eval "db.auth('system', '123456');db.shutdownServer()"
	;;

status)
	/usr/local/mongodb/bin/mongo 127.0.0.1:27017/admin --eval "db.stats()"
	
	#/usr/local/mongodb/bin/mongo 127.0.0.1:27017/admin --eval "db.auth('system', '123456');db.stats()"
	;;

esac



```

4、连接任意一台机器，初始化副本集
```
[root@node01 ~]# mongo --host 192.168.87.102 --port 7000

	> config = 
		{
			_id: 'mycluster', 
			members: 
			[
				{
					"_id":1,
					"host":"192.168.87.102:7000",
					priority: 3
				},
				
				{
					"_id":2,
					"host":"192.168.87.103:8000",
					priority: 2
				},
				
				{
					"_id":3,
					"host":"192.168.87.104:9000",
					priority: 1
				}
			]
		}	
	
	> rs.initiate(config)
	{ "ok" : 1 }

```

初始化副本集完毕后，会发现三台机器的命令提示符会产生变化如下，其中一台机器被选举为PRIMARY，另外两台机器为SECONDARY
```
mycluster:PRIMARY> 
mycluster:SECONDARY> 
mycluster:SECONDARY> 
```

集群创建好后，可以通过> rs.status()查看状态信息


5、测试在PRIMARY中写入数据，并分别在两台secondary查看数据

	注意：seondary默认是不允许执行数据读写操作，执行会报错。在seondary执行> rs.slaveOk()后可查看数据，但无法写入数据
	
6、关闭PRIMARY节点，一断时间后会发现其中一台SECONDARY机器会提升为PRIMARY角色，并可进行读写操作；其他的SECONDARY机器会重新连接新的PRIMARY服务器进行数据复制




# MongoDB分片集群 

	集群角色
	
	1) mongos
		数据库集群请求的入口，所有的请求都通过mongos进行协调，不需要在应用程序添加一个路由选择器，mongos自己就是一个请求分发中心，它负责把对应的数据请求请求转发到对应的shard服务器上。在生产环境通常有多mongos作为请求的入口，防止其中一个挂掉所有的mongodb请求都没有办法操作。

	2)config server
		配置服务器，存储所有数据库元信息（路由、分片）的配置。mongos本身没有物理存储分片服务器和数据路由信息，只是缓存在内存里，配置服务器则实际存储这些数据。mongos第一次启动或者关掉重启就会从 config server 加载配置信息，以后如果配置服务器信息变化会通知到所有的 mongos 更新自己的状态，这样 mongos 就能继续准确路由。在生产环境通常有多个 config server 配置服务器，因为它存储了分片路由的元数据，防止数据丢失！

	3)shared
		分片（sharding）是指将数据库拆分，将其分散在不同的机器上的过程。将数据分散到不同的机器上，不需要功能强大的服务器就可以存储更多的数据和处理更大的负载。基本思想就是将集合切成小块，这些块分散到若干片里，每个片只负责总数据的一部分，最后通过一个均衡器来对各个分片进行均衡（数据迁移）。
	

	
# 搭建MongoDB分片集群 

	环境描述：
		192.168.87.102 	node01	shared服务器	端口：7000
		192.168.87.103	node02	shared服务器	端口：8000
		192.168.87.104	node03	配置服务器 		端口：9000.
		192.168.87.106	node05	配置服务器 		端口：9001
		192.168.87.105	node04	路由器服务器	端口：6000

1、确保时间同步、主机名解析、关闭防火墙及SELinux

2、在各节点安装mongoDB

3、两台分片服务器配置如下，并启动mongod服务
```
192.168.87.102:

[root@node01 ~]# cat /app/mongodb/mongodb.conf

	bind_ip=192.168.87.102
	port=7000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false
	
	shardsvr=true

[root@node01 ~]# mongod -f /app/mongodb/mongodb.conf

[root@node01 ~]# netstat -antp | grep mongo
tcp        0      0 192.168.87.102:7000     0.0.0.0:*               LISTEN      39869/mongod        

192.168.87.103:

[root@node02 ~]# cat /app/mongodb/mongodb.conf

	bind_ip=192.168.87.103
	port=8000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false
	
	shardsvr=true

[root@node02 ~]# mongod -f /app/mongodb/mongodb.conf

[root@node02 ~]# netstat -antp | grep mongo
tcp        0      0 192.168.87.103:8000     0.0.0.0:*               LISTEN      40049/mongod        

```


4、MongoDB 3.4版本后要求配置服务器必须配置副本集保证高可用，下述为配置过程

```
192.168.87.104:

[root@node03 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.104
	port=9000
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false

	replSet=configsrv/192.168.87.106:9001
	configsvr=true

[root@node03 ~]# mongod -f /app/mongodb/mongodb.conf 

[root@node03 ~]# netstat -antp | grep mongo
tcp        0      0 192.168.87.104:9000     0.0.0.0:*               LISTEN      39424/mongod        



192.168.87.106:

[root@node05 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.106
	port=9001
	dbpath=/app/mongodb/data
	logpath=/app/mongodb/log/mongo.log
	fork=true
	logappend=true
	directoryperdb=true
	auth=false

	replSet=configsrv/192.168.87.104:9000
	configsvr=true

[root@node05 ~]# mongod -f /app/mongodb/mongodb.conf

[root@node05 ~]# netstat -antp | grep mongo
tcp        0      0 192.168.87.106:9001     0.0.0.0:*               LISTEN      1592/mongod         

```

连接任意一台机器，初始化副本集

```
[root@node03 ~]# mongo --host 192.168.87.104 --port 9000

> config = 
	{
		_id: 'configsrv', 
		members: 
			[
				{
					 "_id":1,
					 "host":"192.168.87.104:9000",
					 priority: 3
				},
				{
					"_id":2,
					"host":"192.168.87.106:9001",
					priority: 2
				}
			]
	}

> rs.initiate(config)
{ "ok" : 1 }

```	
	
5、配置启动路由服务器，连接配置服务器集群 

```
[root@node04 ~]# cat /app/mongodb/mongodb.conf 

	bind_ip=192.168.87.105
	port=6000
	fork=true
	logpath=/app/mongodb/log/mongo.log
	logappend=true

	configdb=configsrv/192.168.87.104:9000,192.168.87.106:9001
 

[root@node04 ~]# mongos -f /app/mongodb/mongodb.conf 

[root@node04 ~]# netstat -antp | grep mongo
tcp        0      0 192.168.87.105:6000     0.0.0.0:*               LISTEN      10391/mongos        
tcp        0      0 192.168.87.105:44867    192.168.87.104:9000     ESTABLISHED 10391/mongos        
tcp        0      0 192.168.87.105:44863    192.168.87.104:9000     ESTABLISHED 10391/mongos        
tcp        0      0 192.168.87.105:44865    192.168.87.104:9000     ESTABLISHED 10391/mongos        
tcp        0      0 192.168.87.105:44866    192.168.87.104:9000     ESTABLISHED 10391/mongos        
tcp        0      0 192.168.87.105:50326    192.168.87.106:9001     ESTABLISHED 10391/mongos        
tcp        0      0 192.168.87.105:50330    192.168.87.106:9001     ESTABLISHED 10391/mongos        
[root@node04 ~]# 
```

	
6、登录路由，添加分片服务器
```
[root@node04 ~]# mongo --host 192.168.87.105 --port 6000

mongos> use admin

mongos> db.runCommand({addshard: "192.168.87.102:7000",allowLocal:true})
mongos> db.runCommand({addshard: "192.168.87.103:8000",allowLocal:true})
mongos> db.stats()
```

7、在路由服务器上设置针对哪个数据库进行分片
```
mongos> db.runCommand({enablesharding: "testdb"})
{ "ok" : 1 }
mongos> db.runCommand({shardcollection: "testdb.tb01",key:{id:1}})
{ "collectionsharded" : "testdb.tb01", "ok" : 1 }
mongos> 
```

8、测试结果，连接路由服务器存储数据
```
mongos> use testdb

mongos> function add(){
...  var i = 0;
...  for(;i<200;i++){
...    db.tb01.insert({"id":i+10,"name":"jim"})
...  }
... }
mongos> add()

mongos> db.tb01.stats()
```
在此命令输出中可看到数据的两个分片







	
	
	
	
	