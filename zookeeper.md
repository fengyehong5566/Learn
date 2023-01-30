





# zookeeper 设计目的

    1、最终一致性

    2、可靠性

    3、实时性

    4、等待无关

    5、原子性

    6、顺序性



# zookeeper 的数据模型

    zk 会维护一个具有层次关系的数据结构。类似于标准的文件系统，如下图：

<img src="file:///E:/技术学习/markdown/pictures/zookeeper/zk数据模型.png" title="" alt="avatar" width="358">

zk 这种数据结构有如下特点：

    1、每个子目录项如NameService都被称作znode，所在的路径就是这个znode的唯一标识，如图中Server2 这个 znode的唯一标识是/NameService/Server2

    2、znode 可以有子节点目录，并且每个znode可以存储数据。注意EPHEMERAL（临时的）类型的目录节点不能有子节点目录。

    3、znode是有版本的（version），每个znode中存储的数据可以有多个版本，也就是一个访问路径中可以存储多份数据，version号自动增加。

    

## znode 介绍

    在 zk 中 zonde 有四种类型：

    1、persistent —— 持久化目录节点

        客户端与zookeeper断开连接后，该节点依旧存在      

    2、persistent_sequential —— 持久化顺序编号目录节点

        客户端与zookeeper断开连接后，该节点依旧存在，只是Zookeeper给该节点名称进行顺序编号

    3、ephemeral —— 临时目录节点

        客户端与zookeeper断开连接后，该节点被删除

    4、ephemeral_sequential —— 临时顺序编号目录节点

        客户端与zookeeper断开连接后，该节点被删除，只是Zookeeper给该节点名称进行顺序编号































znode可以被监控，包括这个目录节点中存储的数据的修改，子节点目录的变化等，一旦变化可以通知设置监控的客户端，这个是Zookeeper的核心特性，Zookeeper的很多功能都是基于这个特性实现的。

6）ZXID：每次对Zookeeper的状态的改变都会产生一个zxid（ZooKeeper Transaction Id），zxid是全局有序的，如果zxid1小于zxid2，则zxid1在zxid2之前发生。
