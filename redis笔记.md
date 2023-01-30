<center>
<font size=7 color=blue>
    Redis笔记
</font>
</center>


<!-- TOC -->

- [第 1 章. Redis介绍](#第-1-章-redis介绍)
  - [1.1 Redis特性：](#11-redis特性)
  - [1.2 Redis应用场景：](#12-redis应用场景)
- [第 2 章. Redis安装部署](#第-2-章-redis安装部署)
  - [2.1 Redis单机部署](#21-redis单机部署)
    - [2.1.1 可执行的命令：](#211-可执行的命令)
    - [2.1.2 Redis配置文件](#212-redis配置文件)
  - [2.2 Redis主从复制](#22-redis主从复制)
    - [2.2.1 Redis主从复制：](#221-redis主从复制)
    - [2.2.2 启动redis服务。](#222-启动redis服务)
    - [2.2.3 启动Redis master](#223-启动redis-master)
  - [2.3 Redis高可用](#23-redis高可用)
    - [2.3.1 Redis Sentinel的主要功能：](#231-redis-sentinel的主要功能)
    - [2.3.2 主观下线和客观下线](#232-主观下线和客观下线)
    - [2.3.3 Sentinel的通信命令](#233-sentinel的通信命令)
    - [2.3.4 Sentinel部署](#234-sentinel部署)
    - [2.3.5 Sentinel时客户端命令](#235-sentinel时客户端命令)
  - [2.4 Redis集群模式](#24-redis集群模式)
    - [2.4.1 Redis集群方案](#241-redis集群方案)
    - [2.4.2 客户端分区方案](#242-客户端分区方案)
    - [2.4.3 代理分区方案](#243-代理分区方案)
    - [2.4.4 查询路由方案](#244-查询路由方案)
    - [2.4.5 数据分布](#245-数据分布)
    - [2.4.6 Redis的数据分区](#246-redis的数据分区)
    - [2.4.7 Redis集群搭建](#247-redis集群搭建)
- [第3章. Redis命令和架构](#第3章-redis命令和架构)
  - [3.1 全局命令](#31-全局命令)
  - [3.2数据结构和内部编码](#32数据结构和内部编码)
- [第4章. Redis内置类型——string](#第4章-redis内置类型string)
  - [4.1 常见命令：](#41-常见命令)
  - [4.2 不常用命令](#42-不常用命令)
  - [4.3 内部编码](#43-内部编码)
  - [4.4 典型使用场景](#44-典型使用场景)
- [第5章. Redis内置类型——hash](#第5章-redis内置类型hash)
  - [5.1 常用命令](#51-常用命令)
  - [5.2 不常用命令](#52-不常用命令)
  - [5.3 内部编码](#53-内部编码)
  - [5.4 适用场景](#54-适用场景)
    - [5.4.1　哈希结构和关系型表](#541哈希结构和关系型表)
    - [5.4.2 几种缓存方式](#542-几种缓存方式)
- [第6章. Redis内置类型——列表](#第6章-redis内置类型列表)
  - [6.1 五种列表操作类型：](#61-五种列表操作类型)
  - [6.2 命令格式](#62-命令格式)
    - [6.2.1 添加](#621-添加)
    - [6.2.2 查找](#622-查找)
    - [6.2.3 删除](#623-删除)
    - [6.2.4 修改](#624-修改)
    - [6.2.5 阻塞](#625-阻塞)
    - [6.2.6 命令执行时间复杂度](#626-命令执行时间复杂度)
  - [6.3 内部编码](#63-内部编码)
- [第7章. Redis内置类型——集合](#第7章-redis内置类型集合)
  - [7.1 集合内的操作命令](#71-集合内的操作命令)
  - [7.2 集合间的操作命令](#72-集合间的操作命令)
  - [7.3 集合常用命令的时间复杂度](#73-集合常用命令的时间复杂度)
  - [7.4 内部编码](#74-内部编码)
  - [7.5 应用场景](#75-应用场景)

<!-- /TOC -->


# 第 1 章. Redis介绍

## 1.1 Redis特性：  

1. 速度快，最快可达到10w QPS（基于内存，C语言开发，单线程架构）  
2. 基于键/值对的数据结构，类型包含：  
> a. string（字符串）  
  b. hash（哈希）  
  c. list（列表）    
  d. set（集合）  
  e. zset（有序集合）  
  f. bitmap（位图）
  
同时在字符串的基础上演变出BitMap和HyperLoglog两种数据结构。3.2版本中加入GEO（地理信息位置）。  
3. 丰富的功能。如：键过期、发布订阅、Lua脚本（自己实现redis命令）、事务、流水线（Pipeline，用于减少网络的开销）。  
4. 简单稳定，无外部库依赖。  
5. 客户端语言多  
6. 持久化（RDB/AOF）  
7. 主从复制  
8. 高可用（Redis Sentinel），分布式（Redis Cluster）

## 1.2 Redis应用场景：  

  a. 缓存  
　　合理的使用 缓存 能够明显加快访问的速度，同时降低数据源的压力。这也是 Redis 最常用的功能。Redis 提供了 键值过期时间（EXPIRE key seconds）设置，并且也提供了灵活控制 最大内存 和 内存溢出 后的 淘汰策略。  
  b. 排行榜  
　　每个网站都有自己的排行榜，例如按照 热度排名 的排行榜，发布时间 的排行榜，答题排行榜 等等。Redis 提供了 列表（list）和 有序集合（zset）数据结构，合理的使用这些数据结构，可以很方便的构建各种排行榜系统。  
  c. 计数器  
　　计数器 在网站应用中非常重要。例如：点赞数加 1，浏览数 加 1。还有常用的 限流操作，限制每个用户每秒 访问系统的次数 等等。Redis 支持 计数功能（INCR key），而且计数的 性能 也非常好，计数的同时也可以设置 超时时间，这样就可以 实现限流。
  d. 社交网络  
　　赞/踩，粉丝，共同好友/喜好，推送，下拉刷新等是社交网站必备的功能。由于社交网站 访问量通常比较大，而且 传统的数据库 不太适合保存这类数据，Redis 提供的 数据结构 可以相对比较容易实现这些功能。  
  e. 消息队列  
　　Redis 提供的 发布订阅（PUB/SUB）和 阻塞队列 的功能，虽然和专业的消息队列比，还 不够强大，但对于一般的消息队列功能基本满足。  

# 第 2 章. Redis安装部署

安装方式：  
　　Redis 单机服务器  
　　Redis 主从复制  
　　Redis 高可用  
　　Redis 分布式  

## 2.1 Redis单机部署

　　从官网下载部署包，下载到服务器，然后解压。这里以redis-5.0.5.zip二进制包为例。部署到/home/software目录下

> unzip redis-5.0.5.zip  -d /home/software  #会在/home/software下生产redis目录  
> cd /home/software/redis
> ./redis-server  ./redis.conf   #启动命令

### 2.1.1 可执行的命令：

|     **可执行文件**    |          作用                  |
|---------------------|--------------------------------|  
|redis-server         |启动redis服务                    |
|redis-cli            |命令行客户端                     |
|redis-benchmark      |redis基准测试工具                |
|redis-check-aof      |redisAOF持久化文件检测和修复工具   |
|redis-check-dump     |redisRDB持久化文件检测和修复工具   |
|redis-sentinel       |启动redis sentinel              |

### 2.1.2 Redis配置文件

　　Redis 配置文件主要参数解析参考：  
>  
\# redis进程是否以守护进程的方式运行，yes为是，no为否(不以守护进程的方式运行会占用一个终端)。  
daemonize no  
>
>\# 指定redis进程的PID文件存放位置  
pidfile /var/run/redis.pid  
>
>\# redis进程的端口号  
port 6379  
>
>\# 绑定的主机地址  
bind 127.0.0.1  
>
>\# 客户端闲置多长时间后关闭连接，默认此参数为0即关闭此功能  
timeout 300  
>
>\# redis日志级别，可用的级别有debug/verbose/notice/warning  
loglevel verbose  
>
>\# log文件输出位置，如果进程以守护进程的方式运行，此处又将输出文件设置为stdout的话，就会将日志信息输出到/dev/null里面去了  
logfile stdout  
>
>\# 设置数据库的数量，默认为0可以使用select <dbid>命令在连接上指定数据库id  
databases 16  
>
>\# 指定在多少时间内刷新次数达到多少的时候会将数据同步到数据文件  
save <seconds> <changes>  
>
>\# 指定存储至本地数据库时是否压缩文件，默认为yes即启用存储  
rdbcompression yes  
>
>\# 指定本地数据库文件名  
dbfilename dump.db  
>
>\# 指定本地数据问就按存放位置  
dir ./  
>
>\# 指定当本机为slave服务时，设置master服务的IP地址及端口，在redis启动的时候他会自动跟master进行数据同步  
slaveof <masterip> <masterport>    
>
>\# 当master设置了密码保护时，slave服务连接master的密码    
masterauth <master-password>  
>
>\# 设置redis连接密码，如果配置了连接密码，客户端在连接redis是需要通过AUTH<password>命令提供密码，默认关闭  
requirepass footbared  
>
>\# 设置同一时间最大客户连接数，默认无限制。redis可以同时连接的客户端数为redis程序可以打开的最大文件描述符，如果设置 maxclients 0，表示不作限制。当客户端连接数到达限制时，Redis会关闭新的连接并向客户端返回 max number of clients reached 错误信息  
maxclients 128  
>
>\# 指定Redis最大内存限制，Redis在启动时会把数据加载到内存中，达到最大内存后，Redis会先尝试清除已到期或即将到期的Key。当此方法处理后，仍然到达最大内存设置，将无法再进行写入操作，但仍然可以进行读取操作。Redis新的vm机制，会把Key存放内存，Value会存放在swap区  
maxmemory <bytes>  
>
>\# 指定是否在每次更新操作后进行日志记录，Redis在默认情况下是异步的把数据写入磁盘，如果不开启，可能会在断电时导致一段时间内的数据丢失。因为redis本身同步数据文件是按上面save条件来同步的，所以有的数据会在一段时间内只存在于内存中。默认为no。  
appendonly no  
>
>\# 指定跟新日志文件名默认为appendonly.aof  
appendfilename appendonly.aof  
>
>\# 指定更新日志的条件，有三个可选参数 - no：表示等操作系统进行数据缓存同步到磁盘(快)，always：表示每次更新操作后手动调用fsync()将数据写到磁盘(慢，安全)， everysec：表示每秒同步一次(折衷，默认值)；  
appendfsync everysec  

## 2.2 Redis主从复制

角色    |  IP地址   | 端口号
-------|-----------|-------
master |10.0.1.181 | 6379
slave  |10.0.1.182 | 6379

### 2.2.1 Redis主从复制：
master服务器配置：
>daemonize yes  
pidfile /var/run/redis-16379.pid  
logfile /var/log/redis/redis-16379.log  
port 6379  
bind 0.0.0.0  
timeout 300  
databases 16  
dbfilename dump-16379.db  
dir ./redis-workdir  
masterauth 123456  
requirepass 123456  

配置slave服务器：  
　　slave的配置和master大致一样，只是需要添加下面这两项：
在slave的redis服务配置中添加：  
>　　slaveof  10.0.1.181 6379
  
如果master设置了密码，还需要设置：  
>　　masterauth  Password  

### 2.2.2 启动redis服务。
>　　./redis-server ./redis.conf  


### 2.2.3 启动Redis master
>　　./redis-server ./redis.conf  


检查状态：
>　　info replication


## 2.3 Redis高可用

在redis实现高可用的技术中主要包括 **持久化、复制、哨兵、集群**
>　　持久化：持久化是 **最简单** 的高可用方法。主要作用是 **数据备份** ， 保证数据不会因进程退出而丢失；  
>　　复制：复式是高可用redis的基础，**哨兵** 和 **集群** 是在复制的基础上实现的。缺点是故障恢复无法自动化、写操作无法负载均衡、存储能力受到单机限制。    
>　　哨兵：在复制的基础上，哨兵实现了**自动化** 的 **故障恢复**。缺点是写操作无法负载均衡，存储能力受到单机的限制。  
>　　集群：解决了 **写操作** 无法负载均衡以及存储受到单机限制的问题，实现了较为完善的高可用方案   



![](https://user-gold-cdn.xitu.io/2018/8/22/16560ce61dbc4eeb?imageslim)   

### 2.3.1 Redis Sentinel的主要功能：  
　　Sentinel 的主要功能包括： **主节点存活检测、主从运行情况检测、自动故障转移(failover)、主从切换**， Redis的Sentinel最小配置是一主一从。
Sentinel系统可以管理多个redis服务器，执行一下四个任务：
>　　监控：监控主、从服务器是否运行正常  
>　　通知：当某个redis服务器有问题时，Sentinel通过 **API** 脚本向管理员发送通知  
>　　故障转移：当master节点故障，它会从slave中选取新的master节点  
>　　配置提供者：在Sentinel模式下，客户端在初始化时连接的是Sentinel节点集合，从中获取 **Master** 节点的信息  

### 2.3.2 主观下线和客观下线
　　默认情况下，每个 Sentinel 节点会以 **每秒一次** 的频率对 **Redis节点** 和 **其它 的 Sentinel 节点**　发送 PING 命令，并通过节点的 **回复** 来判断节点是否在线。

**主观下线**  
　　主观下线 适用于所有 **主节点、从节点** 。如果在 **down-after-milliseconds** 毫秒内，Sentinel 没有收到 目标节点 的有效回复，则会判定 该节点 为 主观下线。  
**客观下线**  
　　客观下线 只适用于 **主节点**。如果 主节点 出现故障，Sentinel 节点会通过 **sentinel is-master-down-by-addr** 命令，向其它 Sentinel 节点询问对该节点的 状态判断。如果超过 **quorum** 个数的节点判定 主节点 不可达，则该 Sentinel 节点会判断 主节点 为 客观下线。  

### 2.3.3 Sentinel的通信命令


Sentinel 节点连接一个 Redis 实例的时候，会创建 cmd 和 pub/sub 两个 连接。Sentinel 通过 cmd 连接给 Redis 发送命令，通过 pub/sub 连接到 Redis 实例上的其他 Sentinel 实例。  
Sentinel 与 Redis 主节点 和 从节点 交互的命令，主要包括：  

命令       |                        作 用
----------|----------------------------------------------------------  
PING      | Sentinel 向 Redis 节点发送 PING 命令，检查节点的状态
INFO      | Sentinel 向 Redis 节点发送 INFO 命令，获取它的 从节点信息
PUBLISH   | Sentinel 向其监控的 Redis 节点 __sentinel__:hello 这个 channel 发布 自己的信息 及 主节点 相关的配置
SUBSCRIBE | Sentinel 通过订阅 Redis 主节点 和 从节点 的 __sentinel__:hello 这个 channnel，获取正在监控相同服务的其他 Sentinel 节点

Sentinel 与 Sentinel 交互的命令，主要包括：



命令                             | 作 用
---------------------------------|--------------
PING          |   Sentinel 向其他 Sentinel 节点发送 PING 命令，检查节点的状态
SENTINEL:is-master-down-by-addr|   和其他 Sentinel 协商 主节点 的状态，如果 主节点 处于 SDOWN 状态，则投票自动选出新的 主节点

### 2.3.4 Sentinel部署
部署须知：
>1. 一个稳健的redis sentinel集群，应该有至少三个sentinel实例，并且保证这些实例放到不同的服务器上，甚至物理区域；  
>2. sentinel无法保证强一致性；  
>3. Sentinel通过不断的测试和观察，才能保证高可用；

Redis Sentinel配置文件：  
>\# 哨兵sentinel实例运行的端口，默认26379    
　**port 26379**

>\# 哨兵sentinel的工作目录  
　　**dir ./**  

>\# 哨兵sentinel监控的redis主节点的     
>\## ip：主机ip地址  
>\## port：哨兵端口号  
>\## master-name：可以自己命名的主节点名字（只能由字母A-z、数字0-9 、这三个字符".-_"组成。）  
>\## quorum：当这些quorum个数sentinel哨兵认为master主节点失联 那么这时 客观上认为主节点失联了  
>\# sentinel monitor <master-name> <ip> <redis-port> <quorum>  
　　**sentinel monitor mymaster 127.0.0.1 6379 2**

>\# 当在Redis实例中开启了requirepass <foobared>，所有连接Redis实例的客户端都要提供密码。  
>\# sentinel auth-pass <master-name> <password>    
　　**sentinel auth-pass  mymaster 123456**  

>\# 指定主节点应答哨兵sentinel的最大时间间隔，超过这个时间，哨兵主观上认为主节点下线，默认30秒    
>\# sentinel down-after-milliseconds \<master-name>  \<milliseconds>  
　　**sentinel down-after-milliseconds mymaster 30000**    

>\# 指定了在发生failover主备切换时，最多可以有多少个slave同时对新的master进行同步。这个数字越小，完成failover所需的时间就越长；反之，但是如果这个数字越大，就意味着越多的slave因为replication而不可用。可以通过将这个值设为1，来保证每次只有一个slave，处于不能处理命令请求的状态。  
>\# sentinel parallel-syncs <master-name> <numslaves>  
　　**sentinel parallel-syncs mymaster 1**    

>\# 故障转移的超时时间failover-timeout，默认三分钟，可以用在以下这些方面：  
>\## 1. 同一个sentinel对同一个master两次failover之间的间隔时间。  
>\## 2. 当一个slave从一个错误的master那里同步数据时开始，直到slave被纠正为从正确的master那里同步数据时结束。  
>\## 3. 当想要取消一个正在进行的failover时所需要的时间。  
>\## 4.当进行failover时，配置所有slaves指向新的master所需的最大时间。不过，即使过了这个超时，slaves依然会被正确配置为指向master，但是就不按parallel-syncs所配置的规则来同步数据了  
>\#sentinel failover-timeout <master-name> <milliseconds>  
　　**sentinel failover-timeout mymaster 180000**

>\# 当sentinel有任何警告级别的事件发生时（比如说redis实例的主观失效和客观失效等等），将会去调用这个脚本。一个脚本的最大执行时间为60s，如果超过这个时间，脚本将会被一个SIGKILL信号终止，之后重新执行。  
>\# 对于脚本的运行结果有以下规则：  
>\## 1. 若脚本执行后返回1，那么该脚本稍后将会被再次执行，重复次数目前默认为10。  
>\## 2. 若脚本执行后返回2，或者比2更高的一个返回值，脚本将不会重复执行。  
>\## 3. 如果脚本在执行过程中由于收到系统中断信号被终止了，则同返回值为1时的行为相同。  
>\# sentinel notification-script <master-name> <script-path>  
　　**sentinel notification-script mymaster /var/redis/notify.sh**

>\# 这个脚本应该是通用的，能被多次调用，不是针对性的。  
>\# sentinel client-reconfig-script <master-name> <script-path>  
　　**sentinel client-reconfig-script mymaster /var/redis/reconfig.sh**

sentinel.con配置示例：
>protected-mode no  
>bind 0.0.0.0  
>port 16380  
>daemonize yes  
>sentinel monitor master 127.0.0.1 16379 2  
>sentinel down-after-milliseconds master 5000  
>sentinel failover-timeout master 180000  
>sentinel parallel-syncs master 1  
>sentinel auth-pass master 123456  
>logfile /var/log/redis/sentinel-16380.log  

### 2.3.5 Sentinel时客户端命令

> PING sentinel  　#检查其它Sentinel节点状态，返回PONG为正常 
>  
> SENTINEL masters 　  #显示被监控的所有主节点以及它们的状态  
> 
> SENTINEL master <master_name>　  #显示主节点的信息和状态  

> SENTINEL slaves <master_name>　  #显示从节点的信息和状态  
> 
> SENTINEL get-master-addr-by-name <master_name>  
 \#返回主节点的IP和port。如果正在运行failover或已经完成failover，将会返回提升为master状态的slave节点的IP和port。  

> SENTINEL reset <pattern>  
\#重置名字匹配该 正则表达式 的所有的 主节点 的状态信息，清除它之前的 状态信息，以及 从节点 的信息。   

>  SENTINEL failover <master_name>  
  \#强制当前 Sentinel 节点执行 failover，并且不需要得到其他 Sentinel 节点的同意。但是 failover 后会将 最新的配置 发送给其他 Sentinel 节点。


注意：当发生 **主从切换** 时，redis.conf会自动发生刷新。  


## 2.4 Redis集群模式
在redis3.0版本之后就有效的解决了 **redis在分布式方面的需求** 。当遇到**单机内存、并发、流量** 等瓶颈时，可以采用Cluster架构方案达到负载均衡的目的。  

### 2.4.1 Redis集群方案

　　Redis Cluster 集群模式通常具有 高可用、可扩展性、分布式、容错 等特性。
　　Redis分布式方案一般分为两种：
　　　　a、客户端分区方案
　　　　b、代理分区方案

### 2.4.2 客户端分区方案

　　客户端已经决定数据会被 **存储** 到那个redis节点或者从哪个redis节点读取数据。其主要思想是采用 **哈希算法** 将redis数据的 key 进行散列，通过 hash 函数，特定的key会映射到特定的redis节点上。

　　**客户端分区方案** 的代表为 **redis sharding**， Redis Sharding是 Redis Cluster出来之前，业界普遍使用的 redis 多实例集群方法。Java的Redis客户端驱动库Jedis，支持redis sharding功能，即ShardeJedis以及结合 **缓存池** 的ShardedJedisPool。

 　*优点*：  
　　　　**不使用第三方中间件、分区逻辑可控、配置简单、节点之间无关联，容易 线性扩展 灵活性强**  
　　*缺点*：  
　　　　客户端 **无法动态增删** 服务节点，客户端需要自行维护 **分发逻辑**，客户端之间 **无法连接共享**， 会造成 **连接浪费**  
　　
### 2.4.3 代理分区方案

　　客户端发送请求到一个 **代理组件**， **代理** 解析客户端的数据，并将请求转发至正确的节点，最后将结果回复给客户端。 

![](https://user-gold-cdn.xitu.io/2018/9/4/165a4f9e6f8b3a44?imageslim)

　　*优点*：  
　　　　简化客户端的分布式逻辑， 客户端透明接入，切换成本低，代理的 **转发** 和 **存储** 分离。  
　　*缺点*：  
　　　　多了一层 **代理层**， 加重了 **架构部署复杂度** 和 **性能耗损**。  

　　**代理分区** 主流实现的方案有 **Twemproxy** 和 **Codis**。  

　　**Twemproxy**：  
　　　　Twemproxy 也叫 nutcraker，是 twitter 开源的一个 **redis** 和 **memcache** 的 中间代理服务器 程序。Twemproxy 作为 代理，可接受来自多个程序的访问，按照 **路由规则**，转发给后台的各个 Redis 服务器，再原路返回。Twemproxy 存在 **单点故障** 问题，需要结合 **Lvs** 和 **Keepalived** 做 **高可用方案**。
![](https://user-gold-cdn.xitu.io/2018/9/4/165a4f9e751d0773?imageslim)  

　　*优点*：   
　　　　应该范围广，稳定性较高，中间代理层高可用。  
　　*缺点*：  
　　　　无法平滑的 **水平扩容/缩容**，无可视化管理界面，运维不友好，出现故障，不能自动转移。  

　　**Codis**：  
　　　　Codis 是一个 分布式 Redis 解决方案，对于上层应用来说，连接 Codis-Proxy 和直接连接 原生的 Redis-Server 没有的区别。Codis 底层会 **处理请求的转发**，不停机的进行 **数据迁移** 等工作。Codis 采用了 **无状态的代理层** ，对于 客户端 来说，一切都是透明的。

![](https://user-gold-cdn.xitu.io/2018/9/4/165a4f9e7509b300?imageslim)  

　　*优点*：  
　　　　实现了上传Proxy和底层Redis的 **高可用、数据分片和自动平衡**，提供 **命令行接口** 和 **RESTful API**，提供 **监控和管理** 界面， 可以动态 **添加和删除** redis节点  
　　*缺点*：  
　　　　**部署架构 和 配置** 复杂，不支持 **跨机房和多租户** ，不支持**鉴权管理**。  

### 2.4.4 查询路由方案

　　**客户端随机地** 请求任意一个 Redis 实例，然后由 Redis 将请求 **转发** 给 **正确** 的 Redis 节点。Redis Cluster 实现了一种 **混合形式的查询路由**，但并不是 直接 将请求从一个 Redis 节点 转发 到另一个 Redis 节点，而是在 客户端 的帮助下直接 **重定向（ redirected）**到正确的 Redis 节点。

![](https://user-gold-cdn.xitu.io/2018/9/4/165a4f9e84b4b379?imageslim)  

　　*优点*：  
　　　　**无中心节点**， 数据按照 **槽** 存储分布在多个redis实例上，可以平滑的进行节点 **扩容/缩容** ，支持 **高可用和自动故障转移**， 运维成本低。  
　　*缺点*：  
　　　　验证依赖 Redis-trib 工具，缺乏 **监控管理** ，需要依赖 Smart Client（**维护连接，缓存路由表，Multiop和Pipeline支持**）。 failover 节点的 **检测过慢**， 不中**中心节点Zookeeper**及时。Gossip消息具有一定开销。无法根据统计分区 **冷热数据**。  

### 2.4.5 数据分布
　　**分布式数据库** 首先要解决把 **整体数据集**安照 **分区规则** 映射到 **多个节点** 的问题。即把 **数据集** 划分到 **多个节点** 上，每个节点负责 **整体数据** 的一个子集。  

数据分布通常有 哈希分区 和 顺序分区 两种方式，对比如下： 
 
分区方式 |     特点            |            相关产品
--------|--------------------|-----------------
哈希分区 |离散程度好，数据分布与业务无关，无法顺序访问 |Redis Cluster，Cassandra，Dynamo
顺序分区 | 离散程度易倾斜，数据分布与业务相关，可以顺序访问 | BigTable，HBase，Hypertable

　　由于redis Cluster 采用 **哈希分区规则** ，这里重点讨论 **哈希分区**
　　常见的哈希分区规则有几种，如下：  
　　节点取余分区：  
　　　　使用特点的数据，如 redis 的键或用户ID，在根据 **节点数据量 N** 使用公式: **hash(key) % N** 计算出 **哈希值**，用来决定数据映射到那个节点。

![](https://user-gold-cdn.xitu.io/2018/9/4/165a4f9f1b14840d?imageslim)

　　　　*优点*：  
　　　　　　这种方式的突出优点是 **简单性**，常用于 **数据库** 的 **分库分表规则**。一般采用 **预分区** 的方式，提前根据 **数据量** 规划好 **分区数**，比如划分为 512 或 1024 张表，保证可以支撑未来一段时间的 **数据容量**，再根据 **负载情况** 将 **表** 迁移到其他 **数据库** 中。扩容时通常采用 **翻倍扩容**，避免 **数据映射** 全部被 打乱，导致 **全量迁移** 的情况。  
　　　　*缺点*：  
　　　　　　当 **节点数量** 变化时，如扩容和缩容节点，数据节点 **映射关系** 需要重新计算，会导致数据的重新迁移。  

　　一致性哈希分区：  
　　　　  **一致性哈希** 可以很好的解决 **稳定性问题**，可以将所有的 **存储节点** 排列在 **收尾相接** 的 Hash 环上，每个 key 在计算 Hash 后会 **顺时针** 找到 **临接 的 存储节点** 存放。而当有节点 **加入 或 退出** 时，仅影响该节点在 Hash 环上 **顺时针相邻** 的 **后续节点**。
![](https://user-gold-cdn.xitu.io/2018/9/4/165a4f9f1b2a7661?imageslim)

　　　　*优点*：  
　　　　　　**加入和删除** 节点只影响 **哈希环** 中 **顺时针方向** 的 **相邻的节点**， 对其他节点无影响。  
　　　　*缺点*：  
　　　　　　**加减节点** 会造成 **哈希环** 中部分数据 **无法命中** 。当使用 **少量节点** 时，**节点变化** 将大范围影响 **哈希环** 中 **数据映射**，不适合  **少量数据节点** 的分布式方案。 普通的 **一致性哈希分区** 在增减节点时需要 **增减一倍** 或**减少一倍** 节点才能保证 **数据** 和 **负载的均衡**。   
>　　注意：  
>　　　　因为 **一致性哈希分区** 的这些缺点，一些分布式系统采用 **虚拟槽** 对 **一致性哈希** 进行改进，比如 Dynamo 系统。  


　　虚拟槽分区：  
　　　　  **虚拟槽分区** 巧妙地使用了 **哈希空间**，使用 **分散度良好** 的 哈希函数 把所有数据 映射 到一个 **固定范围** 的 **整数集合** 中，整数集合定义为 槽（slot）。这个范围一般 **远远大于节点数**，比如 Redis Cluster 槽范围是 0 ~ 16383【2^14=16384】。槽 是集群内 **数据管理** 和 **迁移** 的 **基本单位**。采用 **大范围槽** 的主要目的是为了方便 **数据拆分** 和 **集群扩展**。每个节点会负责 一定数量的槽，如图所示：

![](https://user-gold-cdn.xitu.io/2018/9/4/165a4f9f644d509a?imageslim)
　　
　　图中集群有 5 个节点，每个节点平均大约负责 3276 个 槽。由于采用 **高质量** 的 哈希算法，每个槽所映射的数据通常比较 均匀，将数据平均划分到 5 个节点进行 数据分区。 **Redis Cluster 就是采用 虚拟槽分区。**  

　　　　节点1： 包含 0 到 3276 号哈希槽。  
　　　　节点2：包含 3277  到 6553 号哈希槽。  
　　　　节点3：包含 6554 到 9830 号哈希槽。  
　　　　节点4：包含 9831 到 13107 号哈希槽。  
　　　　节点5：包含 13108 到 16383 号哈希槽。  

　　这种结构很 **容易 添加 或者 删除 节点**。如果 增加 一个节点 6，就需要从节点 1 ~ 5 获得部分 槽 分配到节点 6 上。如果想 移除 节点 1，需要将节点 1 中的 槽 移到节点 2 ~ 5 上，然后将 没有任何槽 的节点 1 从集群中 移除 即可。

>　　由于从一个节点将 **哈希槽** 移动到另一个节点并 **不会停止服务**，所以无论 **添加/删除** 或者 **改变** 某个节点的 **哈希槽的数量** 都不会造成 集群不可用 的状态.  

### 2.4.6 Redis的数据分区

　　Redis Cluster 采用 **虚拟槽分区**，所有的 **键** 根据 **哈希函数** 映射到 ** 0~16383** 整数个槽内，计算公式： **slot = CRC16(key) & 16383**。每个节点负责维护一部分槽以及槽所映射的 **键值数据**。

　　Redis虚拟槽分区的特点：  
　　　　a. 解耦 **数据** 和 **节点** 之间的关系，简化了节点 **扩容和缩容** 难度。  
　　　　b. **节点自身** 维护槽的映射关系，不需要客户端或者代理服务维护槽分区元数据。  
　　　　c. 支持 **节点、槽、键** 之间的映射查询，用于 **数据路由、在线伸缩** 等场景。  

　　Redis集群的功能限制：  
　　　　Redis集群相对 **单机** 在功能上存在一些限制，需要 **开发人员**提前了解，在使用时做好规避。  
　　　　　　a. key **批量操作** 支持有限  
　　　　　　　　类似 mset、mget 操作，目前只支持对具有相同 slot 值的 key 执行 批量操作。对于 映射为不同 slot 值的 key 由于执行 mget、mget 等操作可能存在于多个节点上，因此不被支持。  
　　　　　　b. key **事务操作** 支持有限   
　　　　　　　　只支持 多 key 在 同一节点上 的 事务操作，当多个 key 分布在 不同 的节点上时 无法 使用事务功能。  
　　　　　　c. key 作为 **数据分区** 的最小粒度   
 　　　　　　　　不能将一个 大的键值 对象如 hash、list 等映射到 不同的节点。  
　　　　　　d. 不支持 **多数据空间**  
　　　　　　　　单机 下的 Redis 可以支持 16 个数据库（db0 ~ db15），集群模式 下只能使用 一个 数据库空间，即 db0。  
　　　　　　e. **复制结构** 只支持一层  
　　　　　　　　从节点 只能复制 主节点，不支持 嵌套树状复制 结构。  

### 2.4.7 Redis集群搭建

Redis-Cluster 是 Redis 官方的一个 高可用 解决方案，Cluster 中的 Redis 共有 2^14（16384） 个 slot 槽。创建 Cluster 后，槽 会 平均分配 到每个 Redis 节点上。  

**准备节点：**  
Redis 集群一般由 多个节点 组成，**节点数量至少为 6 个**，才能保证组成 完整高可用 的集群。每个节点需要 **开启配置 cluster-enabled yes**，让 Redis 运行在 **集群模式** 下。  

  节点名称  | 端口号 |主从角色 |所属主节点
-----------|-------|--------|--
redis-6379 |6379   |主节点   |---
redis-6389 |6389   |从节点   |redis-6379
redis-6380 |6380   |主节点   |---
redis-6390 |6390   |从节点   |redis-6380
redis-6381 |6381   |主节点   |---
redis-6391 |6391   |从节点   |redis-6381

**配置文件：**
以下 **模板** 配置各个实例的 redis.conf，以下只是搭建集群需要的 **基本配置**，可能需要根据实际情况做修改。
>\# redis后台运行  
daemonize yes  

>\# 绑定的主机端口  
bind 127.0.0.1  

>\# 数据存放目录  
dir /usr/local/redis-cluster/data/redis-6379

>\# 进程文件  
pidfile /var/run/redis-cluster/${自定义}.pid  
 
>\# 日志文件  
logfile /usr/local/redis-cluster/log/${自定义}.log  

>\# 端口号  
port 6379  

>\# 开启集群模式，把注释#去掉  
<font color=red>
    cluster-enabled yes 
</font>  

>\# 集群的配置，配置文件首次启动自动生成  
cluster-config-file /usr/local/redis-cluster/conf/${自定义}.conf  

>\# 请求超时，设置10秒  
cluster-node-timeout 10000  

>\# aof日志开启，有需要就开启，它会每次写操作都记录一条日志  
appendonly yes  

**安装Ruby环境:**  
>yum -y install ruby ruby-devel rubygems rpm-build

修改ruby的gem源（改为国内的，因为国外的太慢）
>gem sources  # 查看当前使用的源地址  
>gem sources -a new_URL  #添加镜像地址（可选阿里云镜像）  
>gem sources -r  old_URL  #删除默认源地址  
>gem sources -u  #更新源缓存库  

安装rubygem redis依赖：
> sudo gem install redis

**Redis-trib.rb命令：**  
将redis-trib.rb命令放到redis的根目录下面，默认redis包不含此命令。  
redis-trib.rb 命令行工具 的具体功能如下：  

命令|作用
-|-
create|创建集群
check|检查集群
info|查看集群信息
fix|修复集群
reshard|在线迁移slot
rebalance|平衡集群节点slot数量
add-node|将新节点加入集群
del-node|从集群中删除节点
set-timeout|设置集群节点间心跳连接的超时时间
call|在集群全部节点上执行命令
import|将外部redis数据导入集群

**启动各节点的redis服务：**
>sudo redis-server conf/redis-6379.conf  
>sudo redis-server conf/redis-6389.conf  
>sudo redis-server conf/redis-6380.conf  
>sudo redis-server conf/redis-6390.conf  
>sudo redis-server conf/redis-6381.conf  
>sudo redis-server conf/redis-6391.conf  

在每个 redis 节点的 redis.conf 文件中，我们都配置了 cluster-config-file 的文件路径，集群启动时，conf 目录会新生成 集群 节点配置文件。

**redis-trib 关联集群节点：**
> sudo ./redis-trib.rb create --replicas 1 127.0.0.1:6379 127.0.0.1:6380 127.0.0.1:6381 127.0.0.1:6389 127.0.0.1:6390 127.0.0.1:6391

集群创建后，**redis-trib** 会先将 16384 个 哈希槽 分配到 3 个 主节点，即 redis-6379，redis-6380 和 redis-6381。然后将各个 **从节点** 指向 **主节点**，进行 **数据同步**。  
>>> Creating cluster  
>>> Performing hash slots allocation on 6 nodes...  
Using 3 masters:  
127.0.0.1:6379  
127.0.0.1:6380  
127.0.0.1:6381  
Adding replica 127.0.0.1:6390 to 127.0.0.1:6379  
Adding replica 127.0.0.1:6391 to 127.0.0.1:6380  
Adding replica 127.0.0.1:6389 to 127.0.0.1:6381  
>>> Trying to optimize slaves allocation for anti-affinity  
[WARNING] Some slaves are in the same host as their master  
M: ad4b9ffceba062492ed67ab336657426f55874b7 127.0.0.1:6379  
   slots:0-5460 (5461 slots) master  
M: df23c6cad0654ba83f0422e352a81ecee822702e 127.0.0.1:6380  
   slots:5461-10922 (5462 slots) master  
M: ab9da92d37125f24fe60f1f33688b4f8644612ee 127.0.0.1:6381  
   slots:10923-16383 (5461 slots) master  
S: 25cfa11a2b4666021da5380ff332b80dbda97208 127.0.0.1:6389  
   replicates ad4b9ffceba062492ed67ab336657426f55874b7  
S: 48e0a4b539867e01c66172415d94d748933be173 127.0.0.1:6390  
   replicates df23c6cad0654ba83f0422e352a81ecee822702e  
S: d881142a8307f89ba51835734b27cb309a0fe855 127.0.0.1:6391  
   replicates ab9da92d37125f24fe60f1f33688b4f8644612ee  

然后输入 yes，redis-trib.rb 开始执行 **节点握手** 和 **槽分配** 操作，输出如下：
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated  
>>> Assign a different config epoch to each node  
>>> Sending CLUSTER MEET messages to join the cluster  
Waiting for the cluster to join....  
>>> Performing Cluster Check (using node 127.0.0.1:6379)  
M: ad4b9ffceba062492ed67ab336657426f55874b7 127.0.0.1:6379  
   slots:0-5460 (5461 slots) master  
   1 additional replica(s)  
M: ab9da92d37125f24fe60f1f33688b4f8644612ee 127.0.0.1:6381  
   slots:10923-16383 (5461 slots) master  
   1 additional replica(s)  
S: 48e0a4b539867e01c66172415d94d748933be173 127.0.0.1:6390  
   slots: (0 slots) slave  
   replicates df23c6cad0654ba83f0422e352a81ecee822702e  
S: d881142a8307f89ba51835734b27cb309a0fe855 127.0.0.1:6391  
   slots: (0 slots) slave  
   replicates ab9da92d37125f24fe60f1f33688b4f8644612ee  
M: df23c6cad0654ba83f0422e352a81ecee822702e 127.0.0.1:6380  
   slots:5461-10922 (5462 slots) master  
   1 additional replica(s)  
S: 25cfa11a2b4666021da5380ff332b80dbda97208 127.0.0.1:6389  
   slots: (0 slots) slave  
   replicates ad4b9ffceba062492ed67ab336657426f55874b7  
[OK] All nodes agree about slots configuration.  
>>> Check for open slots...  
>>> Check slots coverage...  
[OK] All 16384 slots covered.  

执行 **集群检查**，检查各个 redis 节点占用的 **哈希槽**（slot）的个数以及 slot **覆盖率**。16384 个槽位中，**主节点** redis-6379、redis-6380 和 redis-6381 分别占用了 5461、5461 和 5462 个槽位。

通过BGSAVE命令，**从节点** 在后台 **异步** 地从 **主节点** 同步数据。  

Redis集群完整性检测：
使用 redis-trib.rb check 命令检测之前创建的 两个集群 是否成功，check 命令只需要给出集群中 任意一个节点地址 就可以完成 整个集群 的 检查工作，命令如下：  
>   ./redis-trib.rb check 127.0.0.1:6379


# 第3章. Redis命令和架构

## 3.1 全局命令

1、查看所有键
> keys  *

2、获取当前数据库中的 **键总数**
> dbsize  

dbsize命令在获取计算键总数时，不会遍历所有键，而是直接获取 **redis 内置键总数变量** 。dbsize命令的时间复杂度是O（1）。而keys会遍历所有键，时间复杂度是O(n)。当redis保存大量键时，<font color=red> 线上环境禁止使用keys </font>.  

3、检查键是否存在
> exists keyname  #存在返回 1，不存在返回 0

4、删除键
> del keyname  #返回成功删除的键的个数，假设一个键不存在，会返回0

5、键过期
> expire keyname seconds

redis 支持对 **键** 添加 **过期时间**，当超过过期时间后，会 **自动删除键**。<font color=red> ttl 命令</font> 用于获取 键的 **剩余过期时间**，返回值如下：  
　　返回值大于 0 的整数：表示键的剩余的过期时间；  
　　返回-1 : 没有设置过期时间  
　　返回-2 : 键不存在  

6、获取键的数据结构类型
> type keyname   #键不存在时，返回none

## 3.2数据结构和内部编码

Redis内部主要数据结构：  
　　string、 hash、 list、 set、 zset  
对于每种 **数据结构**，实际上都有自己底层的内部编码实现，而且是多种实现。这样redis会在合适的场景选择合适的内部编码

数据结构 | 内部编码
-|-
string | raw   int  embstr
list   | linkedlist ziplist
hash   | hashtable  ziplist
set    | hashtable  intset
zset   | skiplist   ziplist  

<font color=red>
object encoding 命令获取内部编码  
object help  查看命令帮助信息
</font>

Redis这样设计的两个好处：  
　　1、可以改进内部编码，而对外的数据结构和命令没有影响。
　　2、不同的内部编码可以在不同场景下发挥各自的优势。如：ziplist：节省内存，但是在列表元素比较多的情况下，性能会有所下降。这个时候redis会根据 配置 ，将列表类型的内部实现转换为 linkedlist。 

##3.3 单线程架构

　　Redis使用 **单线程架构** 和 **I/O多路复用模型** 来实现高性能的内存数据库服务。  
　　单线程为什么这么快呢？  
　　1、纯内存访问  
　　　　Redis将所有数据放在 **内存**中，内存的 响应时长 大约为 100ns，这是Redis达到每秒万级别访问的重要基础。

　　2、非阻塞I/O  
　　　　Redis 使用 **epoll** 作为I/O多路复用技术的实现，再加上Redis自身的 **事件处理模型** 将epoll中的 **连接、读写、关闭** 都转为事件， 从而不用在网络I/O上浪费过多的时间。

　　3、单线程避免线程切换和竞态生产的消耗  
　　　　采用 **单线程** 就能达到如此高的性能，那么不失为一种不错的选择，因为单线程能带来几个好处：  
　　　　a、单线程 可以简化 **数据结构和算法** 的实现，开发人员不需要了解负责的并发数据结构。  
　　　　b、单线程 避免了 **线程切换** 和 **竞态** 产生的消耗，对于服务端开发来说， **锁和线程切换** 通常是性能杀手。  
>　　**注意：**  
>　　　　单线程的问题： 对于 每个命令 的 执行时间 是有要求的。如果某个命令执行过长，会造成其他命令的阻塞，对于redis这种高性能的服务来说是致命的，所以redis是面向**快速执行** 场景的数据库。


# 第4章. Redis内置类型——string

　　**字符串类型** 是redis最基础的数据结构。字符串类型的值可以是 **字符串** （简单和复杂的字符串，例如JSON、XML）、**数字**（整数、浮点数）、**二进制**（图片、音频、视频），但是最大不能超过 **512M**。  

## 4.1 常见命令：
1、设置值
>set keyname value  [ex second] [px milliseconds] [nx|xx]  
　　set 命令选项:  
　　　　ex seconds：为 键 设置 **秒级** 过期时间  
　　　　ps milliseconds： 为 键 设置 **毫秒级** 过期时间   
　　　　nx ：**键必须不存在**，才能设置成功，用于 **添加**   
　　　　xx ：与nx相反，**键必须存在**，才能设置成功，用于**更新**

除了set命令，redis还有 setex 和 setnx 命令
> setex  keyname seconds  value  
> setnx  keyname value  
　　setex：设定键的值，并指定此键值对应的 **有效时间**  
　　setnx：**键必须不存在** 才可以设置成功，如果键存在，返回 0.  
 
2、获取值
> get keyname  
　　如果键不存在，则返回 nil（空）

3、批量设置值
> mset key value [key value ...]  
> 　　如：  mset a 1 b 2 c 3 d 4 

4、批量获取值
> mget key [key ...]  
>> **批量操作** 命令，可以有效提高开发效率，假如没有 mget 这样的命令，要执行 n次 get 命令的过程和耗时。  
>> <font color=red> n次get时间  = n次网络时间 + n次命令时间</font>
  
> 批量操作命令耗时：
>>  <font color=red> n次get时间  = 1次网络时间 + n次命令时间</font>  

Redis 可以支撑 每秒数万 的 读写操作，但这指的是 Redis 服务端 的处理能力，对于 客户端 来说，一次命令除了 命令时间 还是有 网络时间。

5、计数
> incr keyname  
>　　incr 命令用于对值做 **自增操作**， 返回结果分为三种情况：  
>　　　　值不是整数，返回错误；  
>　　　　值是整数， 返回自增后的结果；  
>　　　　键不存在，按照值为 0 自增，返回结果为 1；  

　　Redis还提供了 **decr（自减）、incrby（自增指定数字）、decrby（自减指定数字）、incrbyfloat（自增浮点数）**等操作命令。  
　　很多 存储系统 和 编程语言 内部使用 CAS 机制实现 计数功能，会有一定的 CPU 开销。但在 Redis 中完全不存在这个问题，因为 Redis 是 单线程架构，任何命令到了 Redis 服务端 都要 **顺序执行**。

## 4.2 不常用命令

1、追加值  
> append  keyname value
> 　　append 命令可以向 **字符串尾部** 追加值。  

2、获取字符串长度  
> strlen  keyname

3、设置并返回原值  
> getset keyname value  
> 　　getset 和 set 一样会设置值，但是不同的是，它同时会返回 **键原来的值**。  

4、设置指定位置的字符
> setrange keyname  offset value

5、获取部分字符串  
> getrange  key start end
> 　　start 和 end 分别是开始、结束位置相对第一个字符的偏移量，偏移量默认从 0 开始计算

字符串类型命令的时间 **复杂度** 说明:

![](https://user-gold-cdn.xitu.io/2018/9/24/1660c13bbc201ed4?imageslim)

## 4.3 内部编码

字符串类型的 **内部编码** 有 3 种：  
　　int：8 个字节的长整形  
　　embstr： 小于等于 39 个字节的字符串  
　　raw： 大于 39 个字节的字符串  
Redis 会根据当前值的 **类型 和 长度** 决定使用哪种 内部编码实现。

## 4.4 典型使用场景

**缓存 功能：**  
　　下面是一种比较典型的 缓存 使用场景，其中 Redis 作为 缓存层，MySQL 作为 存储层，绝大部分请求的数据都是从 Redis 中获取。由于 Redis 具有支撑 高并发 的特性，所以缓存通常能起到 加速读写 和 降低后端压力 的作用。

![](https://user-gold-cdn.xitu.io/2018/9/30/16627f1779bef93b?imageslim)

**计数 功能：**  
　　许多应用都会使用 Redis 作为 计数 的基础工具，它可以实现 快速计数、查询缓存 的功能，同时数据可以 异步落地 到其他 数据源。一般来说，视频播放数系统，就是使用 Redis 作为 视频播放数计数 的基础组件，用户每播放一次视频，相应的视频播放数就会自增 1。
>　　实际上，一个真实的 **计数系统** 要考虑的问题会很多：**防作弊**、按照 **不同维度** 计数，**数据持久化** 到 **底层数据源** 等。  

**共享Session：**  
　　一个 **分布式** Web 服务将用户的 Session 信息（例如 用户登录信息）保存在 各自 的服务器中。这样会造成一个问题，出于 **负载均衡** 的考虑，**分布式服务** 会将用户的访问 均衡 到不同服务器上，用户 刷新一次访问 可能会发现需要 重新登录，这个问题是用户无法容忍的。  
　　为了解决这个问题，可以使用 Redis 将用户的 Session 进行 集中管理。在这种模式下，只要保证 Redis 是 高可用 和 扩展性的，每次用户 更新 或者 查询 登录信息都直接从 Redis 中集中获取。

**限速：**  
　　很多应用出于安全的考虑，会在每次进行登录时，让用户输入 手机验证码，从而确定是否是用户本人。但是为了 短信接口 不被 频繁访问，会 限制 用户每分钟获取 验证码 的频率。例如一分钟不能超过 5 次

# 第5章. Redis内置类型——hash

　　大部分编程语言都提供了 哈希（hash）类型，它们的叫法可能是 哈希、字典、关联数组。在 Redis 中，哈希类型 是指键值本身又是一个 键值对结构。  

　　**哈希** 形如 value={ {field1，value1}，...{fieldN，valueN} }，Redis 键值对 和 哈希类型 二者的关系如图所示：

![](https://user-gold-cdn.xitu.io/2018/10/3/1663a75da4aca1ed?imageslim)

>　　哈希类型中的 **映射关系** 叫作 field-value，这里的 value 是指 field 对应的 值，不是 键 对应的值。

## 5.1 常用命令
1、设置值    
> hset  keyname field  value  
>　　下面 为 user：1 添加一对 field-value，如果设置成功会返回 1，反之会返回 0
>>     127.0.0.1:6379> hset user:1 name tom
>>     (integer) 1

Redis 提供了 **hsetnx** 命令，它们的关系就像 set 和 setnx 命令一样，只不过 **作用域** 由 键 变为 field。

2、获取值  
> hget  keyname  field  
> 　　下面操作用于获取 user：1 的 name 域（属性） 对应的值。
>>　　127.0.0.1:6379> hget user:1 name  
>>　　"tom"
   
>　　如果 **键** 或 field 不存在， 会返回 nil 

3、删除field  
> hdel  keyname  field [field ...]  
>　　hdel 会删除 一个或多个 field，返回结果为 成功删除 field 的个数  

4、计算field个数  
> hlen  keyname  


5、批量设置或获取 field-value  
>hmget  keyname field [field ...]  
>hmset  keyname field value [field value ...]  
>　　hmset 和 hmget 分别是 批量设置 和 获取 field-value，hmset 需要的参数是 key 和 多对 field-value，hmget 需要的参数是 key 和 多个 field  

6、判断field是否存在
> hexists keyname field  
>　　如果keyname包含field，返回结果为 1， 不包含时返回 0

7、获取所有field
> hkeys  keyname  
>　　hkeys 命令应该叫 hfields 更为恰当，它返回指定 哈希键 所有的 field  

8、获取所有value
> hvals  keyname  

9、获取所有的field-value
> hgetall  keyname  
>　　在使用 hgetall 时，如果 **哈希元素** 个数比较多，会存在 **阻塞** Redis 的可能。如果开发人员只需要获取 部分 field，可以使用 **hmget**。如果一定要获取 全部 field-value，可以使用 **hscan** 命令，该命令会 **渐进式遍历** 哈希类型。  

## 5.2 不常用命令

1、键值自增
> hincrby  keyname field increment  
> hincrbyfloat  keyname field increment  
> 　　hincrby 和 hincrbyfloat，就像 incrby 和 incrbyfloat 命令一样，但是它们的 作用域 是 field。

2、计算value的字符串长度
> hstrlen keyname  field 

下面是 **哈希类型命令** 的 **时间复杂度**， 开发人员可以参考词表选择合适的命令：

![](https://user-gold-cdn.xitu.io/2018/10/3/1663a75da490cbc5?imageslim)

![](https://user-gold-cdn.xitu.io/2018/10/3/1663a75da4be1ea2?imageslim)

## 5.3 内部编码

**哈希类型** 的 **内部编码** 有两种：  
 　　ziplist（压缩列表）：  
 　　 　　当 **哈希类型** 元素个数 小于 hash-max-ziplist-entries 配置（默认 512 个）、同时 **所有值** 都 小于 hash-max-ziplist-value 配置（默认 64 字节）时，Redis 会使用 ziplist 作为 哈希 的 内部实现，ziplist 使用更加 **紧凑的结构** 实现多个元素的 连续存储，所以在 **节省内存** 方面比 hashtable 更加优秀。

 　　hashtable（哈希表）：  
　　　　 当 **哈希类型** 无法满足 ziplist 的条件时，Redis 会使用 hashtable 作为 哈希 的 内部实现，因为此时 **ziplist** 的 **读写效率** 会下降，而 **hashtable** 的读写 时间复杂度 为 O（1）。  

 　　当 field 个数 比较少，且没有大的 value 时，内部编码 为 ziplist；  
 　　当有 value 大于 64 字节时，内部编码 会由 ziplist 变为 hashtable；  
 　　当 field 个数 超过 512，内部编码 也会由 ziplist 变为 hashtable；
  
## 5.4 适用场景

 　　相比于使用 字符串序列化 缓存 用户信息，哈希类型 变得更加 直观，并且在 更新操作 上会 更加便捷。可以将每个用户的 id 定义为 键后缀，多对 field-value 对应每个用户的 属性

### 5.4.1　哈希结构和关系型表

需要注意的是 哈希类型 和 关系型数据库 有两点不同之处：  
 　　**哈希类型 是 稀疏的**，而 **关系型数据库 是 完全结构化的**，例如 哈希类型 每个 键 可以有不同的 field，而 关系型数据库 一旦添加新的 列，所有行 都要为其 设置值（即使为 NULL），如图所示：  

![](https://user-gold-cdn.xitu.io/2018/10/4/1663e2bcbd36e4ce?imageslim)

 　　**关系型数据库** 可以做复杂的 **关系查询**，而使用 Redis 去模拟关系型复杂查询 **开发困难，维护成本高**。

### 5.4.2 几种缓存方式
　　目前已经能够用 三种方法 缓存 用户信息。下面给出三种方案的实现方法和优缺点分析。

 　　**原生字符串类型**：  
>　　给用户信息的每个属性分配一个键
> 　　set user:1:name tom  
> 　　set user:1:age 23  
> 　　set user:1:city beijing  
> 　　**优点**： 简单直观，每个属性都支持 更新操作。  
> 　　**缺点**： 占用过多的键，内存占用量较大，同时用户信息 内聚性比较差，所以此种方案一般不会在生产环境使用。 

　　**序列化字符串类型**：  
　　 将用户信息 序列化 后用一个键保存
>　　 set user:1 serialize(userIfo)  
>　　 **优点**： 简化编程，如果合理的使用 序列化 可以 **提高内存利用率**  
>　　 **缺点**： **序列化** 和 **反序列化** 有一定的开销，同时每次 更新属性都需要把全部数据取出进行 反序列化，更新后再序列化到redis中。

　　 **哈希类型**：  
　　 每个用户属性使用一对 field-value，但是只用一个键保存。
>　　 hmset  user:1 name tom age 23 city beijing  
>　　 **优点**： 简单直观，如果使用合理可以 **减少内存空间** 的使用  
>　　 **缺点**： 要控制和减少 哈希 在 ziplist 和 hasttable 两种 内部编码的转换， hashtable会消耗 **更多的内存**。


# 第6章. Redis内置类型——列表

 **列表** （list）类型使用来存储多个 **有序** 的字符串。
　　可两端操作：
　　　　插入（push：lpush、rpush）
　　　　弹出（pop：lpop、rpop）
　　可支持范围获取数据 或 指定索引下标
　　一个列表最多可存储 2^32 -1 个元素

## 6.1 五种列表操作类型：

操作类型 |       操作命令
-------|------------------------
添加   | rpush / lpush / linsert
查找   | lrange / lindex / llen
删除   | lpop / rpop / lrem / ltrim
修改   | lset
阻塞   | blpop / brpop

## 6.2 命令格式

### 6.2.1 添加

>rpush key value [value ...]　　//右边插入
>lpush key value [value ...]　　//左边插入
>　　　　
>linsert  key  before|after pivot value  
>// **linsert** 命令会从 list中找到 **第一个** 等于pivot的元素，在其前/后插入一个新元素value，返回当前列表的长度
　　
### 6.2.2 查找

>　　**指定范围查找：**
　　　　lrange key  start stop
　　　　// 索引下标：0 ~ N-1 或 -1 ~ -N
　　　　//返回结果包含下标为stop的元素
>
>　　**指定元素下标：**
　　　　lindex key  index
>
>　　**获取列表长度：**
　　　　llen key

### 6.2.3 删除

>　　**从左侧删除：**
　　　　lpop key

>　　**从右侧删除：**
　　　　rpop key

>　　**指定元素删除：**
　　　　lrem key count value
　　　　// lrem 命令会从列表中找到等于 value 的元素进行删除，count分三种情况：
　　　　//  count > 0 ：从左到右，删除最多 count 个元素
　　　　//  count = 0 ：删除所有
　　　　//  count < 0 : 从右到左，删除最多 count 个元素

### 6.2.4 修改

>　　**指定下标修改**
　　　　lset key  index  newValue

### 6.2.5 阻塞

>　　**阻塞式弹出**
　　　　blpop key  [key ...] timeout 
　　　　brpop key  [key ...] timeout
blpop/brpop是lpop/rpop的阻塞版本, 以blpop为例
key[key ...]： 是一个列表的 **多个键**
timeout： 阻塞时间 (单位：秒)
>
>对于timeout参数：分为 **列表为空** 和 **不为空**
　　列表为空：
　　　　如果timeout=5，那么客户端要等到5秒后返回，如果timeout = 0 客户端一直阻塞等下去。如果期间添加了元素，客户端立即返回。
　　列表不为空：客户端立即返回

在使用brpop时，注意两点：
　　1、如果是 **多个键** ，brpop会从左至右遍历键，一单有一个键能弹出元素，客户端就立即返回
>127.0.0.1:6379> brpop list:1 list:2 list:3 0
..阻塞..

此时另一个 客户端 分别向 list:2 和 list:3 插入元素：
>client-lpush> lpush list:2 element2
(integer) 1
client-lpush> lpush list:3 element3
(integer) 1

客户端 会立即返回 list:2 中的 element2，因为 list:2 最先有 可以弹出 的元素。

　　2、如果 多个客户端 对 同一个键 执行 brpop，那么 最先执行 brpop 命令的 客户端 可以 获取 到弹出的值。
按先后顺序在 3 个客户端执行 brpop 命令：

客户端1：
>client-1> brpop list:test 0
...阻塞...

客户端2：
>client-2> brpop list:test 0
...阻塞...

客户端3：
> client-3> brpop list:test 0
...阻塞...

那么 客户端 1 会获取到元素，因为 客户端 1 最先执行 brpop 命令，而 客户端 2 和 客户端 3 会继续 阻塞。

### 6.2.6 命令执行时间复杂度

相关命令的时间复杂度：
![](https://user-gold-cdn.xitu.io/2018/10/20/16691de83c245b81?imageslim)

## 6.3 内部编码

列表类型有2中内部编码：
　　**ziplist（压缩列表）**
　　　　当列表的元素个数 小于 list-max-ziplist-entries 配置 **（默认 512 个）** ，同时列表中 每个元素 的值都 小于  list-max-ziplist-value 配置时 **（默认 64 字节）** ，Redis 会选用 ziplist 来作为 列表 的 内部实现 来减少内存的使用。
　　
　　**linkedlist（链表）**
　　　当 列表类型 无法满足 ziplist 的条件时， Redis 会使用 linkedlist 作为 列表 的 内部实现。
　　
Redis3.2 版本提供了 **quicklist** 内部编码，简单地说它是 **以一个 ziplist 为 节点 的 linkedlist**，它结合了 ziplist 和 linkedlist 两者的优势，为 列表类型 提供了一种更为优秀的 内部编码 实现。

# 第7章. Redis内置类型——集合

**集合**（set）类型也是用来保存多个 字符串元素，但集合中 **不允许有重复元素**，且集合中的元素是 **无序的**，**不能通过 索引下标 获取元素**。
　　一个集合最多存 **2^32-1**元素。
　　集合除了基本的 **增删改查**，还支持多个集合的 **交集、并集、差集**

## 7.1 集合内的操作命令
**添加：**
>　　sadd key  element [element ...]　　//返回添加成功的元素个数

**删除：**
>　　srem  key  element [element ...]　　//返回结果为删除成功的元素个数

**计算元素个数**
>　　scard key
scard 的时间复杂度为O(1)，它不会遍历集合所有元素，而是直接用redis内部的变量

**判断元素是否在集合中**
>　　sismember key  element
element在集合中返回1，反之返回0

**随机从集合返回指定个数元素**
>　　srandmember key [count]
[count] 可选参数，如果不写默认为 1.

**从集合随机弹出元素**
>　　spop key
spop 操作可以从集合中 **随机** 弹出一个元素，
注： Redis3.2之后，spop 也开始支持 [count]参数

**获取所有元素**
>　　smembers key　　//返回结果是无序的

smembers 和 lrange、hgetall 都属于 *比较重* 的命令，如果 **元素过多** 存在 **阻塞** Redis 的可能性，这时候可以使用 sscan 命令来完成。

## 7.2 集合间的操作命令

**求多个集合的交集**
>　　sinter key [key ...]

**求多个集合的并集**
>　　suinon key [key ...]

**求多个集合的差集**
>　　sdiff  key [key ...]

**保存交集、并集、差集的结果**
集合间 的运算在 元素较多 的情况下会 比较耗时，所以 Redis 提供了以下 三个命令（原命令 + store）将 集合间交集、并集、差集 的结果保存在 destination key 中。
>　　sinterstore destination key [key ...] 
>　　suionstore destination key [key ...] 
>　　sdiffstore destination key [key ...]

## 7.3 集合常用命令的时间复杂度
![](https://user-gold-cdn.xitu.io/2018/11/8/166f3ef48a56fecc?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)

## 7.4 内部编码
**集合类型** 的 内部编码 包含两种：
　　**intset（整数集合）**
　　当集合中的元素 **都是整数** 且 元素个数 小于 set-max-intset-entries 配置（默认 512 个）时，Redis 会选用 intset 来作为 集合 的 内部实现，从而 减少内存 的使用。
　　**hashtable（哈希集合）**
　　当集合类型 无法满足 intset 的条件时，Redis 会使用 hashtable 作为集合的 内部实现。

## 7.5 应用场景
　　 
>1、用户标签
 2、娱乐新闻推荐
 3、电商人群分类
　　

————————————— **完** ———————————

本文档参考作者是 “零壹技术栈”的玩野资料总结完成。
来源链接：https://juejin.im/post/5bcb3b066fb9a05d1c14c712
