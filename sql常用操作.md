## 查看表中已经存在的索引

```sql
exec sp_helpindex  tableName
```

## 获取系统中所有数据库名称

```sql
select * from  master.dbo.sysdatabases
```

## 获取数据库中所有的表名称

```sql
方法1：
use [run]
select name from sys.tables


方法2：
select name from sysobjects where xtype='U'
// U:表示用户表
// S:表示系统表


select name from sysobjects where type='U' and sysstat = '83'
//一般情况只需要type='U'，就行了，但有时候会有系统表混在其中。所以加上sysstat
```

## 获取所有字段名

```sql
select name  from  syscolumns where id=object_id('tableName')
```

## 查看表占用的空间

```
exec sp_spaceused 'tableName'   --获取表占用的空间
exec sp_spaceused   --获取数据库所有空间
sp_helpdb 'databaseName'  --获取数据库占用空间
```

## 查看库中所有表的大小

```sql
use [run]
exec sp_MSforeachtable "exec sp_spaceused '?' "
```

## 操作 存储过程的结果集

```
1、先创建一个临时表
    create table tableName(......)
2、将结果集复制到临时表
    insert into tableName  exec procName
3、对临时表进行操作
    xxxx
4、删除临时表
    drop table  tableName
```

## 查看正在执行的事务信息

```
1、select * from sys.dm_tran_session_transactions;
返回当前多有的活动事务

2、dbcc opentran
返回最先开始的事务
```

## sp_MSforeachdb  和 sp_MSforceachtable 过程

这两个sp_MSforeachdb  和 sp_MSforceachtable 过程，为了便于在多库多表执行命令

```
exec @return_value=sp_MSforeachtable  @command1,@replacechar,@command2,@command3,@whereand,@precommand,@postcommand

exec @return_value=sp_MSforeachdb  @command1,@replacechar,@command2,@command3,@whereand,@precommand,@postcommand

@return_value：返回值--0：成功，其他失败
@command1：第一个执行的命令
@replacechar：自定义名称的符号，默认'?'
@command2：第二个执行的命令
@command3：第三个执行的命令
@whereand：过滤表名称的条件（sp_MSforeachdb 无此参数）
@precommand：执行存储过程前的命令
@postcommand：执行存储过程后的命令
```

## dbcc checkdb

```
dbcc checkdb主要做两件事
    1、检查数据库里有没有损坏发生
    2、尽力修复数据库损坏，使数据库能够被重新正常访问

注：
    dbcc checkdb默认不加锁而是在一个隐藏的数据库快照里进行工作。只有添加 tablock选项才会枷锁
建议：
    对生产系统频繁使用PHYSICAL_ONLY选项，使用该选项可以极大的缩短对大型数据库运行"dbcc checkdb"的运行时间。但是还建议定期运行没有选项的"dbcc checkdb"命令

参数：ALL_ERRORMSGS：显示针对每个对象报告的所有错误。 默认情况下显示所有错误消息。

EXTENDED_LOGICAL_CHECKS：如果兼容性级别为 100 (SQL Server 2008) 或更高，则对索引视图、XML 索引和空间索引（如果存在）执行逻辑一致性检查。

NO_INFOMSGS：取消显示所有信息性消息。

NOINDEX：指定不应对用户表的非聚集索引执行会占用很大系统开销的检查。 这将减少总执行时间。 NOINDEX 不影响系统表，因为总是对系统表索引执行完整性检查。

PHYSICAL_ONLY：将检查限制为页和记录标头的物理结构完整性以及数据库的分配一致性。 设计该检查是为了以较小的开销检查数据库的物理一致性，但它还可以检测会危及用户数据安全的残缺页、校验和错误以及常见的硬件故障。因此，使用 PHYSICAL_ONLY 选项可能会大幅减少对较大数据库运行 DBCC CHECKDB 所需的时间，所以对需要频繁检查的生产系统，建议使用此选项。我们仍然建议完整地定期执行 DBCC CHECKDB。

ESTIMATEONLY：显示运行包含所有其他指定选项的 DBCC CHECKDB 时所需的 tempdb 空间估计量。 不执行实际数据库检查。

DATA_PURITY：使 DBCC CHECKDB 检查数据库中是否存在无效或越界的列值。

TABLOCK：使 DBCC CHECKDB 获取锁，而不使用内部数据库快照。 这包括一个短期数据库排他 (X) 锁。 TABLOCK 可使 DBCC CHECKDB 在负荷较重的数据库上运行得更快，但 DBCC CHECKDB 运行时会减少数据库上可获得的并发性。
```

## sqlcmd

> -U：登录ID
> -P：密码
> -S：服务器
> -H：主机名
> -E：信任连接
> -N：加密连接
> -C：信任服务器证书
> -d：使用数据库名称
> -l：登录超时值
> -t：查询超时值
> -h：标题
> -s：列分隔符
> -w：屏幕宽度
> -a：数据包大小
> -e：回显输入
> -I：允许带引号的标识符
> -c：命令结束
> -L[c]：列出服务器[清除输出]
> -q："命令行查询"
> -Q："命令行查询"并退出
> -m：错误级别
> -V：严重级别
> -W：删除尾随空格
> -u：Unicode输出
> -r[0|1]：发送到 stderr的消息
> -i：输入文件
> -o：输出文件
> -z：新密码
> -f：<代码页>|i:<代码页>[,o:<代码页>]
> -Z：新建密码并退出
> -k[1|2]：删除[替换]控制字符
> -y：可变长度类型显示宽度
> -Y：固定长度类型显示宽度
> -p[1]：打印统计信息[冒号格式]
> -R：使用客户端区域设置
> -K：应用程序意向
> -M：多子网故障转移
> -b：出错时中止批处理
> -v：变量= "值"...
> -A：专用管理连接
> -X[1]：禁用命令、启动脚本、环境变量[并退出]
> -x：禁用变量替换
> -j：打印原始错误消息
> -?：显示语法摘要

# 链接服务器查询数据库报错处理

        在alwayson群集的副本上查询，当主节点上的统计信息未与备节点上的统计信息同步时，使用四段式查询方法或报错。

![](https://yundoc.csc.com.cn/minio/zxjts303/weboffice/shapes/297121/19a181fa1932aa5fc7527af5ecf28f98268a01d7?AWSAccessKeyId=LTAIf5lqDRk6W4Mf&Expires=1653371206&response-expires=300&Signature=bgJtSBmBKEi/XXpNCwzF798PFhE%3D)

解决方法一：

使用openquery命令替换四段式查询语句。该命令是在目标数据库上进行运算，比四段式语句通过链接服务器查询性能好，还能规避统计报错的问题

```sql
select * from openquery([JD5],'select * from [run].[dbo].[zhorderrec]')
select * from openquery([JD5],'select * from [run].[dbo].[zqzy_contract])
```

解决方法二：

在alwayson主节点数据库上删除报错中无法找到的统计信息。

```sql
drop statistics zhorderrec._WA_Sys_00000012_48860864
drop statistics zqzy_contract.WA_Sys_00000003_616F4FBA
```

注:

> 在指定的链接服务器上执行指定的传递查询。 该服务器是 OLE DB 数据源。 OPENQUERY 可以在查询的 FROM 子句中引用，就好象它是一个表名。 OPENQUERY 也可以作为 INSERT、UPDATE 或 DELETE 语句的目标表进行引用。 但这要取决于 OLE DB 访问接口的功能。 尽管查询可能返回多个结果集，但是 OPENQUERY 只返回第一个。
> 
> 参考：
> 
> [OPENQUERY (Transact-SQL) - SQL Server | Microsoft Docs](https://docs.microsoft.com/zh-cn/sql/t-sql/functions/openquery-transact-sql?view=sql-server-ver15)

# 在alwayson辅助副本上创建用户

在主副本上打开ssms，"安全性"——"登录名"——"新建登录名"

创建用户后，执行sql语句查询sid

```sql
use [master]
go
select * from sys.server_principals where name='chaxun'
```

连接到辅助副本实例，运行如下脚本，账户创建同步完成。

```go
use [master]
go
create LOGIN [chaxun] with password=N'Password01!', 
default_database=[master],default_language=[简体中文]，
check_expiration=off, check_policy=off,sid='xxxxxxxxxxxxxxxxx';
go
```

# alwayson 切换操作

方法1[ssms]：

> **切换**
>     在 SSMS中登录将要切换到的辅助副本，打开对象资源管理器，展开 “AlwaysOn 高可用性” - ”可用性组”  。
>     在 对应的可用性组上右键选择故障转移。
>     在确认故障转移可能丢失数据界面选择确认框。
>     一直点击“下一步”直到故障转移完成。
> 
> **继续同步**
>     在 SSMS中依次登录需要继续同步数据的辅助副本，打开对象资源管理器，展开 “AlwaysOn 高可用性” - ”可用性组” - ”可用性数据库” 。
>     在”可用性数据库” 下，挂起同步的数据库有“暂停”标志，右键该数据库，选择“恢复数据移动”。
>     一直点击“下一步”直到数据同步完成。

说明：

        说明：也可以在主副本上执行故障转移，但是考虑到一般故障转移的使用主副本已经不可用，所以建议在辅助副本上执行故障转移。

方法2：【T-SQL】

```sql
//连接辅助副本实例，运行脚本

//切换,仅在即将成为主副本的辅助副本上执行
use [master]
go
alter availability group [alwaysonGroupName] 
force_failover_allow_data_loss;
go


//继续同步，在所有辅助副本上执行，不包括新的主副本
USE [master]
go
alter database [yourdbName] set hadr  resume;
go
```

# 服务器级的固定角色说明

| 服务器级的固定角色     | 说明                                                                                                                                                     |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| sysadmin      | sysadmin 固定服务器角色的成员可以在服务器上执行任何活动。                                                                                                                      |
| serveradmin   | serveradmin 固定服务器角色的成员可以更改服务器范围的配置选项和关闭服务器。                                                                                                            |
| securityadmin | securityadmin 固定服务器角色的成员可以管理登录名及其属性。 他们可以 GRANT、DENY 和 REVOKE 服务器级权限。 他们还可以 GRANT、DENY 和 REVOKE 数据库级权限（如果他们具有数据库的访问权限）。 此外，他们还可以重置 SQL Server 登录名的密码。  |
|               | 重要提示： 如果能够授予对 数据库引擎 的访问权限和配置用户权限，安全管理员可以分配大多数服务器权限。 securityadmin 角色应视为与 sysadmin 角色等效。                                                                |
| processadmin  | processadmin 固定服务器角色的成员可以终止在 SQL Server 实例中运行的进程。                                                                                                      |
| setupadmin    | setupadmin 固定服务器角色的成员可以使用 Transact-SQL 语句添加和删除链接服务器。 （使用 Management Studio 时需要 sysadmin 成员资格。）                                                         |
| bulkadmin     | bulkadmin 固定服务器角色的成员可以运行 BULK INSERT 语句。                                                                                                               |
|               | Linux 上的 SQL Server 不支持 bulkadmin 角色或管理大容量操作权限。 只有 sysadmin 才能对 Linux 上的 SQL Server 执行批量插入。                                                            |
| diskadmin     | diskadmin 固定服务器角色用于管理磁盘文件。                                                                                                                             |
| dbcreator     | dbcreator 固定服务器角色的成员可以创建、更改、删除和还原任何数据库。                                                                                                                |
| public        | 每个 SQL Server 登录名都属于 public 服务器角色。 如果未向某个服务器主体授予或拒绝对某个安全对象的特定权限，该用户将继承授予该对象的 public 角色的权限。 只有在希望所有用户都能使用对象时，才在对象上分配 Public 权限。 你无法更改具有 Public 角色的成员身份。 |
|               | 注意：public 与其他角色的实现方式不同，可通过 public 固定服务器角色授予、拒绝或撤销权限                                                                                                    |

# 固定数据库角色名说明

| 固定数据库角色名          | 说明                                                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| db_owner          | db_owner 固定数据库角色的成员可以执行数据库的所有配置和维护活动，还可以删除 SQL Server中的数据库。 （在 SQL 数据库 和 Synapse Analytics 中，某些维护活动需要服务器级别权限，并且不能由 db_owners 执行。） |
| db_securityadmin  | db_securityadmin 固定数据库角色的成员可以仅修改自定义角色的角色成员资格和管理权限。 此角色的成员可能会提升其权限，应监视其操作。                                                         |
| db_accessadmin    | db_accessadmin 固定数据库角色的成员可以为 Windows 登录名、Windows 组和 SQL Server 登录名添加或删除数据库访问权限。                                                   |
| db_backupoperator | db_backupoperator 固定数据库角色的成员可以备份数据库。                                                                                              |
| db_ddladmin       | db_ddladmin 固定数据库角色的成员可以在数据库中运行任何数据定义语言 (DDL) 命令。                                                                                 |
| db_datawriter     | db_datawriter 固定数据库角色的成员可以在所有用户表中添加、删除或更改数据。                                                                                      |
| db_datareader     | db_datareader 固定数据库角色的成员可以从所有用户表和视图中读取所有数据。 用户对象可能存在于除 sys 和 INFORMATION_SCHEMA 以外的任何架构中 。                                        |
| db_denydatawriter | db_denydatawriter 固定数据库角色的成员不能添加、修改或删除数据库内用户表中的任何数据。                                                                              |
| db_denydatareader | db_denydatareader 固定数据库角色的成员不能读取数据库内用户表和视图中的任何数据。                                                                                 |

# 日志收缩

选中数据库，"任务"--"收缩"--"文件"，文件类型："日志"，

    **释放未使用的空间**：将任何文件中未使用的空间释放给操作系统，并将文件收缩到最后分配的区，因此无需移动任何数据即可减小文件尺寸。 不会将行重新定位到未分配的页。

**在释放我使用的空间前重新组织页**

    相当于执行用于指定目标文件大小的 DBCC SHRINKFILE。 此选项用户必须在 “将文件收缩到” 框中指定目标文件的大小。

    **“将文件收缩到”**  
为收缩操作指定目标文件的大小。 此大小值不得小于当前分配的空间或大于为文件分配的全部区的大小。 如果输入的值超出最小值或最大值，那么一旦焦点改变或单击工具栏上的按钮时，数值将恢复到最小值或最大值。

日志收缩：

```sql
use [master]
go
alter database DBName set recovery simple with no_wait;
alter database DBName set recovery simple;
go

use DBNAME
go
dbcc shrinkfile(N'DBName_log',11,truncateonly)

use master
alter database DBName set recovery full with no_wait
alter database DBName set recovery full
go
```

注：

| log_resue_wait | log_reuse_wait_dest        | 说明                                                                                                                                                                                                                                                                                                                                                                                  |
| -------------- | -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 0              | nothing                    | 前有一个或多个可重复使用的虚拟日志文件 (VLF)。                                                                                                                                                                                                                                                                                                                                                          |
| 1              | checkpoint                 | 自上次日志截断之后，尚未生成检查点，或者日志头尚未跨一个虚拟日志 (VLF) 文件移动。 （所有恢复模式）这是日志截断延迟的常见原因。 有关详细信息，请参阅数据库检查点 (SQL Server)。                                                                                                                                                                                                                                                                                  |
| 2              | log_backup                 | 在截断事务日志前，需要进行日志备份。 （仅限完整恢复模式或大容量日志恢复模式）完成下一个日志备份后，一些日志空间可能变为可重复使用。                                                                                                                                                                                                                                                                                                                  |
| 3              | active_backup_or_restore   | 数据备份或还原正在进行（所有恢复模式）。如果数据备份阻止了日志截断，则取消备份操作可能有助于解决备份直接导致的此问题。                                                                                                                                                                                                                                                                                                                         |
| 4              | active_transaction         | 事务处于活动状态（所有恢复模式）：一个长时间运行的事务可能存在于日志备份的开头。 在这种情况下，可能需要进行另一个日志备份才能释放空间。 请注意，长时间运行的事务将阻止所有恢复模式下的日志截断，包括简单恢复模式，在该模式下事务日志一般在每个自动检查点截断。延迟事务。 “延迟的事务 ”是有效的活动事务，因为某些资源不可用，其回滚受阻。 有关导致事务延迟的原因以及如何使它们摆脱延迟状态的信息，请参阅延迟的事务 (SQL Server)。长时间运行的事务也可能会填满 tempdb 的事务日志。 Tempdb 由用户事务隐式用于内部对象，例如用于排序的工作表、用于哈希的工作文件、游标工作表，以及行版本控制。 即使用户事务只包括读取数据（SELECT 查询），也可能会以用户事务的名义创建和使用内部对象， 然后就会填充 tempdb 事务日志。 |
| 5              | database_mirroring         | 数据库镜像暂停，或者在高性能模式下，镜像数据库明显滞后于主体数据库。 （仅限完整恢复模式）有关详细信息，请参阅数据库镜像 (SQL Server)。                                                                                                                                                                                                                                                                                                          |
| 6              | replication                | 在事务复制过程中，与发布相关的事务仍未传递到分发数据库。 （仅限完整恢复模式）有关事务复制的信息，请参阅 SQL Server Replication。                                                                                                                                                                                                                                                                                                        |
| 7              | database_snapshot_creation | 正在创建数据库快照。 （所有恢复模式）这是日志截断延迟的常见原因，通常也是主要原因。                                                                                                                                                                                                                                                                                                                                          |
| 8              | log_scan                   | 发生日志扫描。 （所有恢复模式）这是日志截断延迟的常见原因，通常也是主要原因。                                                                                                                                                                                                                                                                                                                                             |
| 9              | availability_replica       | 可用性组的辅助副本正将此数据库的事务日志记录应用到相应的辅助数据库。 （完整恢复模式）有关详细信息，请参阅： AlwaysOn 可用性组概述 (SQL Server)。                                                                                                                                                                                                                                                                                                |
| 10、11、12       |                            | 内部使用                                                                                                                                                                                                                                                                                                                                                                                |
| 13             | oldest_page                | 如果将数据库配置为使用间接检查点，数据库中最早的页可能比检查点日志序列号 (LSN) 早。 在这种情况下，最早的页可以延迟日志截断。 （所有恢复模式）有关间接检查点的信息，请参阅数据库检查点 (SQL Server)。                                                                                                                                                                                                                                                                       |
| 14             | other_transient            |                                                                                                                                                                                                                                                                                                                                                                                     |
