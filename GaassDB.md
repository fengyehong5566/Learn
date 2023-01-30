<center>
<font size=10, color=blue>
GaussDB笔记
</font>
</center>

# GaussDB

    gauss 数据库 不是指某个特定的产品，而是一系列的产品统称。

    GaussDB是华为自主创新研发的分布式关系型数据库。该产品具备企业级复杂事务混合负载能力，同时支持分布式事务，同城跨AZ部署，数据0丢失，支持1000+的扩展能力，PB级海量存储。同时拥有云上高可用，高可靠，高安全，弹性伸缩，一键部署，快速备份恢复，监控告警等关键能力，能为企业提供功能全面，稳定可靠，扩展性强，性能优越的企业级数据库服务。

## 常用概念

    **实例**：GaussDB的最小管理单元。一个实例代表了一个独立运行的数据库。可以在控制台创建和管理GaussDB实例。

    **实例类型**：GaussDB支持分布式版和主备版实例。

        分布式形态能够支撑较大的数据量，且提供了横向扩展的能力，可以通过扩容的方式提高实例的数据容量和并发能力。

        主备版适用于数据量较小，且长期来看数据不会大幅度增长，但是对数据的可靠性，以及业务的可用性有一定诉求的场景。

    CN：【Coordinator Node】负责数据库系统元数据存储、查询任务的分解和部分执行，以及将DN中查询结果汇聚在一起

    DN：【Data Node】负责实际执行表数据的存储、查询操作。

    【注：gaussdb对存储的io性能要求高，其支持“超高IO”存储类型，最大吞吐量为350MB/S】

## 

    

## GaussDB 产品分类

包含三大类产品OLTP,OLAP,HTAP的多个子产品：

**关系型数据库**

GaussDB(for openGauss)：应用于金融、电信、政府等行业关键核心系统，高性能场景

GaussDB(for MySQL)：中大型企业生产线系统（高性能，大数据容量），如金融、互联网等

**非关系型数据库**

GaussDB(for Mongo)：应用于游戏（装备、道具）、泛互联场景

GaussDB(for Cassandra)：泛互联网日志数据存储（并发写入量大，存储容量高）、工业互联网数据存储（写入规模大、存储容量大）

GaussDB(forInflux)：工业互联网时序数据、用户银行流水数据、物联网数据存储（时序）

GaussDB(for Redis)：Key-Value存储模式，可用于互联网场景

**GaussDBT/GaussDBA 区别：**

GaussDB100外称**GaussT**，意指**交易型**，开源本版openGauss，以 OLTP 和集群为方向；

GaussDB200外称**GaussA**，意指**分析型**，闭源，基于postgresql。

Gaussdb T 有单机、HA、分布式集群三种架构，据说内部在研发 RAC 集群架构。

Gaussdb T 有三种架构中，

    单机部署：

        低成本部署形式

        针对测试环境，或可靠性要求较低的场景

    主备部署：

        1+1（最大可用）或1+2（最大保护）主备

        基于数据库日志复制的热备

        单机性能可满足需求的情况下，提供高可用

    全分布式部署：

        分布式高扩展：数据按shard划分，读写负载准线性扩展，满足大规模业务量场景

        分布式高可用：支持两地三中心高可用部署

# gsql 客户端【linux】

**gauss客户端下载**

【官网】[通过内网连接实例_云数据库 GaussDB_快速入门_使用客户端连接实例_华为云](https://support.huaweicloud.com/qs-opengauss/opengauss_01_0024.html)

https://dbs-download.obs.cn-north-1.myhuaweicloud.com/GaussDB/1660794000209/GaussDB_opengauss_client_tools.zip

详情参考官网：

    [gsql概述_数据仓库服务 GaussDB(DWS)_工具指南_gsql命令行客户端工具_华为云](https://support.huaweicloud.com/tg-dws/dws_gsql_002.html)

```shell
gsql -h <集群地址> -U <数据库用户> -p <数据库端口> -d <数据库名称> -r

```

参数说明如下：

- “数据库名称”：输入所要连接的数据库名称。首次使用客户端连接集群时，请指定为集群的默认数据库“gaussdb”。
- “集群地址”：请参见获取集群连接地址进行获取。如果通过公网地址连接，请指定为集群“公网访问地址”或“公网访问域名”，如果通过内网地址连接，请指定为集群“内网访问地址”或“内网访问域名”。如果通过弹性负载均衡连接，请指定为“弹性负载均衡地址”。
- “数据库用户”：输入集群数据库的用户名。首次使用客户端连接集群时，请指定为创建集群时设置的默认管理员用户，例如“dbadmin”。
- “数据库端口”：输入创建集群时设置的“数据库端口”。

# 附录

## 工具

详情参考官网：

[工具简介_数据仓库服务 GaussDB(DWS)_工具指南_华为云](https://support.huaweicloud.com/tg-dws/dws_07_0001.html)

**客户端工具：**

| 工具名称        | 工具间介                                                                                                              |
| ----------- | ----------------------------------------------------------------------------------------------------------------- |
| gsql        | 一款运行在Linux操作系统的命令行工具，用于连接DWS集群中的数据库，并对数据库进行操作和维护。                                                                 |
| Data Studio | 用于连接数据库的客户端工具，有着丰富的GUI界面，能够管理数据库和数据库对象，编辑、运行、调试SQL脚本，查看执行计划等。运行在windows操作系统上，免安装使用。                               |
| GDS         | 一款运行在Linux操作系统的命令行工具，通过和外表机制的配合，实现数据的高速导入导出。GDS工具包需要安装在数据源文件所在的服务器上，数据源文件所在的服务器称为数据服务器，也叫GDS服务器。                  |
| DSC         | 用于将Teradata或Oracle数据库中的sql脚本迁移为适用于GaussDB(DWS)的sql脚本，便于在GaussDB(DWS)中重建数据库。DSC工具是运行在Linux操作系统的命令行工具，解压软件包免安装即可使用。 |

**服务端工具：**

| 工具名称          | 简介                                                                                  |
| ------------- | ----------------------------------------------------------------------------------- |
| gs_dump       | 是一款用于导出数据库相关信息的工具，支持导出完整一致的数据库对象（数据库、模式、表、视图等）数据，同时不影响用户对数据库的正常访问。                  |
| gs_dumpall    | 是一款用于导出数据库相关信息的工具，支持导出完整一致的集群数据库所有数据，同时不影响用户对数据库的正常访问。                              |
| gs_restore    | 是GaussDB(DWS)提供的针对gs_dump导出数据的导入工具。通过此工具可由gs_dump生成的导出文件进行导入。                       |
| gds_check     | 用于对GDS部署环境进行检查，包括操作系统参数、网络环境、磁盘占用情况等，也支持对可修复系统参数的修复校正，有助于在部署运行GDS时提前发现潜在问题，提高执行成功率。 |
| gds_install   | 是用于批量安装gds的脚本工具，可大大提高GDS部署效率。                                                       |
| gds_uninstall | 是用于批量卸载GDS的脚本工具。                                                                    |
| gds_ctl       | 是一个批量控制GDS启停的脚本工具，一次执行可以在多个节点上启动/停止相同端口的GDS服务进程，并在启动时为每一个进程设置看护程序，用于看护GDS进程。        |
| gs_sshexkey   | 集群在安装过程中，需要在集群中的节点间执行命令，传送文件等操作。gs_sshexkey工具来帮助用户建立互信，需要确保互信是连通的。                  |

## 调优

参考官网：

    [总体调优思路_云数据库 GaussDB_用户指南_性能调优_华为云](https://support.huaweicloud.com/usermanual-opengauss/opengauss_opti_0020.html)