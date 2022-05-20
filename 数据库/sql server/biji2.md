# **SQL server**


# 基础概念

DDL
	create
	alter
	drop
	truncate(删除表里所有数据，无法修复，操作不记录到日志)
DML
	insert
	update
	delete（可恢复）
DCL
	grant（赋予权限）
	deny（限制权限）
	revoke（撤销权限）

DQL
	select
	
绘制E-R图（实体关系图）
	实体 
	实体集
	【矩形框表示】
	
	属性（实体的一些特性）
	【椭圆型表示】
	
	联系：反馈实体内部或实体之间的联系
	种类：一对一
		  一对多
		  多对多
	【菱形表示】


​	
定义函数：
​	标量函数：
​		create function funcName（@varName varType）
​		returns
​		begin
​			....
​		end


	表值函数：
	create function  funcName（@varName  varType）
	return @outputName  table
			(
				column1  type,
				column2  type,
				......
			)
	as
	begin
		insert into  @outputName
		select ....
		return
	end

游标：	
	主要适用于对查询返回的结果集进行 行操作。类似于linux系统中sed命令处理数据的模式。
	概述：游标是在sql server 数据库开辟的缓冲区中（存放select语句查询的结果集）通过
		游标位置（类似C语言中的指针）控制，向前或向后的读取指定的记录。
	
		游标提供了一种从结果集中每次读取一条记录的机制，让程序能够对返回的记录逐行进行处理


​	
​	
​	
​	
数据库优化：
​	数据库的性能收到数据库设计、查询结构、并行处理、客户端和服务器端模式、程序设计等方面的影响。
​	数据库设计：
​		1、规范化：就是让数据库中无序的数据变的更加有条理，表中的数据都在合理的位置。使用范式规则可对数据库进行结构化的设计
​			第一范式：
​				数据表中的字段只包含一种数据类型，每种数据只存放在一个地方
​			第二范式：
​				确保表中包含一个唯一的实体数据。第二范式要求每个非键属性完全依赖于主键
​			第三范式：
​				表中所有非关键字段相互独立，表中任意字段内容进行更改不会影像其他字段。
​		2、选择适当的数据类型
​			选择正确的、合理的数据类型对后期的查找速度有直接的影响。
​			a、选择可以存储数据的最小数据类型
​			b、尽量使用简单的数据类型。
​				简单的数据类型的操作通常需要更少的cpu周期。
​			c、尽量避免NULL
​				在有NULL值的字段上设计索引、索引统计和值的比较更加复杂。
​		3、索引的选择
​			通常只为对 应用程序 起关键作用的查询或者被很多用户频繁使用的查询创建索引。
​	
​	查询优化：
​		1、避免使用“*”
​			限制或取列、行的数量可以缩短执行时间，提高查询效率
​		2、避免负逻辑
​			任何负逻辑(如 !=、<>或 not in )都将导致SQL server2016 用 表扫描 来完成查询
​			例如：
​				if not exist （select * fromtable where ...）
​				begin
​					/ statement here /
​				end
​			改为：
​				if exist (select * fromtable where ...)
​				begin	
​					goto label
​				end
​				/ statement here /
​				label:exit
​	
​		3、列操作：
​			where 子句中 列旁边的任何操作都将导致数据库使用 表扫描 来完成查询。
​			例如：
​				select * from employee where substring(name, 1, 1) = "W"
​			改为：
​				select * from employee where name  like "W%"
​				此时优化器就会用一个建立在name上的索引来进行查询
​			
			在查询中应该尽量少用HAVING子句，因为HAVING子句只会在检索出所有记录之后才对结果集进行过滤。
			含HAVING子句的select语句是在过滤数据之前执行count或sum统计等操作，其操作针对目标表的所有记录。
			含where子句的select语句是在过滤数据之后执行count或者sum统计操作。
		
		4、避免使用 distinct
			使用 DIST1NCT 是为了保证在结果集中不出现重复值，但是 DISTINCT 关键字会产生一张工作表，并进行
			排序以删除重复记录 ， 这会大大增加查询时间和 I/O 的次数。因此应尽量避免使用 DIST1NCT。
			可以使用一下方式查找重复的id
				例如：
					select id from emloyee groupby id havingcount(id)>1
		
		5、存储过程【使用showplan可以对不同的查询结构的性能进行比较】
	
		sql server 提供showplan可以对不同的查询结构的性能进行比较，包括查询计划、索引选择、I/O次数、相应时间等
	
	考虑并行：
		数据库系统的并发控制也是影响性能的一个重要方面。为了避免多个用户同时操作可能导致的数据不一致，sql server采用了封锁机制。
		sql server的锁可分为以下3种：【sql server中锁机制对用户是透明的，用户只需了解基本原理即可】
			共享锁：由读取页的进程所使用。共享锁只在特定页的读取过程中有效.
			修改锁：用于将要修改数据的进程，当数据发生变化时，修改锁自动改为独占锁.
			独占锁：用于当前正在修改数据的进程。独占锁作用于所有影响到的页上，直至事务结束.
		
		降低死锁的可能性：
			1、保证事务尽可能小
			2、用存储过程控制易造成死锁的数据对象，因为存储过程执行得更快
			3、创建有用的索引，以加快事务的执行，检索封锁时间
			4、进行数据划分，避免“热点”
	
		行版本控制：
			隔离级别中有两种行版本控制允许一个事务在数据排他锁锁定后读取数据的最后提交版本。由于不必等待到锁释放就可进行读操作，因此查询性能得以大大增强。
			两种行版本控制的隔离级别：
				已提交读快照：这是一种提交读级别的新实现。不像一般的提交读级别， SQL Sever会读取最后提交的版本并因此不必在进行
					读操作时等待直到锁被释放.这个级别可以代替提交读级别。
				快照：这种隔离使用行版本来提供事务级别的读取一致性。这意味着在一个事务中，由于读一致性可以通过行版本控制
					实现，因此同样的数据总是可以像在可序列化级别上一样被读取而不必为防止来自其他事务的更改而被锁定.
	
	索引操作：
		1、避免在索引列上进行运算
			例如：	
				select sno, sname, sage, from stu  where sage +1 > 22  --该语句在执行时并未使用索引
			改：
				select sno, sname, sage, from stu  where sage  > 22 - 1  -- 该语句在执行时，使用了索引
		
		2、避免在索引列上用 OR运算符
			在 SELECT 语句中需要对索引列进行 OR (逻辑或)操作，此时索引将不会被引用。
			例如：	
				select sno, sname, sage, from stu  where sno='123' or sage > 22  --该语句未使用索引，此时可使用union 替换where子句
			改：
				select sno, sname, sage, from stu where sno='123' 
				union
				select sno, sname, sage, from stu where sage>22
				
			注：使用山UON 代替 OR 操作符规则只针对多个索引列有效，如果有的列没有被索引，检索效率可能反而会因为没有选择 OR 而降低。
				
		3、避免在索引列上用 IS NULL
			在索引列上判断该列值是否为空也将引起索引失效。
				对于 SQL Server 2016 的索引来说 ，如果一个索引列的某个值为空，该值将不存在于索引列中。


​	
数据库文件和文件组
​	每个sql server数据库至少有两个操作系统文件：
​		数据文件：包含数据和对象。如表、索引、存储过程和视图
​		日志文件：包含恢复数据库中所有事务所需要的信息。
​	
​	文件组：为了便于分配和管理，可以将 数据文件 集合起来进行管理

​	
​	

​	

# 	**SQL server数据库备份**

sql server带有三种备份策略：
	**数据库完全备份：**
		提供了某个数据库在备份时间点的完整拷贝
		缺点：
			备份文件空间占用相对较大，可能会在备份过程中导致事务日志一直不断增长
		语句：

```sql
USE master
GO
			
BACKUP DATABASE [AdventureWorks2008R2] 
TO DISK = 'C:\Temp\AdventureWorks2008R2_20171112_FULL.bak' WITH COMPRESSION, INIT, STATS = 5;
GO
```



**数据库日志备份：**
		事务日志备份记录了数据库从上一次日志备份到当前时间内的所有事务提交的数据变更，它可以配合数据库完全备份和差异备份（可选）来实现时间点的还原。当日志备份操作成功以后，事务日志文件会被截断，事务日志空间将会被重复循环利用，以此来解决完全备份过程中事务日志文件一致不停增长的问题，因此我们最好能够周期性对数据库进行事务日志备份，以此来控制事务日志文件的大小。**但是这里需要有一个前提是数据库必须是FULL恢复模式，SIMPLE恢复模式的数据库不支持事务日志的备份，当然就无法实现时间点的还原**
		修改数据库为 "full恢复模式"

```		sql
		USE [master]
		GO
		ALTER DATABASE [AdventureWorks2008R2] SET RECOVERY FULL WITH NO_WAIT
		GO
```

​		T-SQL语句备份事务日志：

```sql
user [master]
GO

BACKUP LOG [AdventureWorks2008R2]
TO DISK = N'backupPath\filename.trn' with compression,stats=1;
GO
```



事务日志备份链：

​	由于数据库完全备份是时间点数据的完整拷贝，每个数据库完整备份相互独立，而多个事务日志备份是通过事务日志链条连接在一起，事务日志链起点于完全备份，SQL Server中的每一个事务日志备份文件都拥有自己的FirstLSN和LastLSN，FirstLSN用于指向前一个事务日志备份文件的LastLSN；而LastLSN指向下一个日志的FirstLSN，以此来建立这种链接关系。这种链接关系决定了事务日志备份文件还原的先后顺序。当然，如果其中任何一个事务日志备份文件丢失或者破坏，都会导致无法恢复整个事务日志链，仅可能恢复到你拥有的事务日志链条的最后一个。事务日志备份链条的关系如下图所示：

![img](https://pic4.zhimg.com/80/v2-8ca6a95f160cce959428f56bf14a006f_720w.jpg)





**数据库差异备份：**









# 数据库优化

## SHOWPLAN_ALL	

  显示查询计划是SQL Server将显示在执行查询的过程中连接表时所采取的每个步骤，以及是否选择及选择了哪个索引，从而帮助用户分析有哪些索引被系统采用。[  SET SHOWPLAN_ALL ON ︳OFF 或 SET SHOWPLAN_TEXT ON | OFF ]

```sql
USE book
GO
SET SHOWPLAN_ALL  ON
GO

SELECT * FROM book  where  '编号'='123'
GO 

SET SHOWPLAN_ALL OFF
GO
```



## **STATISTICS IO**	

  通过设置STATISTICS IO选项，可以打印SQL Server显示磁盘IO信息。

```sql
USE book
GO

SET STATISTICS IO ON
GO

SELECT * FROM book WHERE '编号'='123'
GO 

SET STATISTICS IO OFF
GO
```





# 日常操作

1、检查数据库同步状态：[T-SQL]

```sql
select redo_queue_size,redo_queue_size/redo_rate  as lagtime,dbs.name,ar.replica_servername
from sys.dm_hadr_database_replica_states as t 
join sys.databases as dbs on dbs.database_id = t.database_id 
join sys.availability_replicas as ar on t.replica_id = ar.replica_id 
where is_primary_replica=0
/*
各返回值含义:
redo_queue_size:辅助副本的日志文件中尚未重做的日志记录量，单位KB，这个数过大影响数据同步效率时，可以尝试重启辅助副本数据库服务解决。
lagtime:同步数据发送到辅助副本后，辅助副本上的数据恢复延迟。当延迟过大时，可以尝试重启辅助副本数据库服务解决。
name:可用性数据库
replica_server_name:辅助副本服务器主机名。
*/
```



# dbcc功能

数据库控制台命令

| 命令类别 | 功能                                                         | 列如 |
| -------- | ------------------------------------------------------------ | ---- |
| 维护     | 对数据库、索引或文件组进行维护的任务                         |      |
| 杂项     | 杂项任务，如启用跟踪标志或从内存中删除 DLL                   |      |
| 信息     | 收集并显示各种类型信息的任务                                 |      |
| 验证     | 对数据库、表、索引、目录、文件组或数据库页的分配进行的验证操作 |      |

​	

```
dbcc checkdb

NOINDEX选项：
指定不应对用户表的非聚集索引执行会占用很大系统开销的检查。 这将减少总执行时间。 NOINDEX 不影响系统表，因为总是对系统表索引执行完整性检查。

```





```
解决dbcc checkdb 慢的方法
1、带上NO_INFOMSGS（取消显示所有信息性消息）
	减少打印的时间开销
2、调整tempdb库文件的大小
	根据dbcc checkdb estimateonly 命令评估执行“dbcc checkdb”需要的tempdb多大的空间
	目的：减少硬tempdb库文件小，多次申请空间导致的开销
	
	
？？？带NOINDEX选项，指定不应对用户表的非聚集索引执行会占用很大系统开销的检查
```















# Alwayson 

**最重要的结论是：**
1、标准的AlwaysOn方案提供读写分离的是统一的listener（包括虚拟IP、连接地址和端口，由WSFC机制在配置时创建）；但实际通信通过重定向完成，即客户端实际通信不是和listener而是与真正的某个副本通信。
2、读写分离需要应用感知是否只读请求，需要数据库驱动支持并包含在请求中表明是Readonly还是Readwrite
3、故障切换是实例级别，多个主备实例提供同一个的浮动IP地址，客户端无感知；可用组是数据库级别，客户端有感知（通过listener重定向）。



alwayson同步过程主要包括如下六个步骤：

```  txt
1、log flush（primary）
2、log capture（primary）
3、send（primary and secondary）
4、log receive and cache （secondary）
5、log hardened（secondary）
【6、send（secondary and primary）同步提交模式下】
6、redo（secondary）

前两个步骤发生在主副本，最后三个步骤发生在辅助副本，中间的第三个步骤发生主副本和辅助副本之间。

另外，如果是同步提交模式，还需要增加一个步骤：辅助副本在步骤5之后，会发送一个（日志硬化）确认信息给主副本，然后才能进入redo阶段。


```



```
alwayson技术集中了故障转移群集、数据库镜像和日志传送三者的优点，但有不相同。
	故障转移群集的单位是 SQL实例
	数据库镜像和日志传送的单位是 单个用户数据库
	alwayson的单位是 可用性组

alwayson的每个组中可以包括一个或者多个用户数据库。一旦发生切换，可用性组中的所有数据组会作为一个整体进行切换。

alwayson底层采用Windows故障转移群集的机制进行检测和转移，只不过可用性组中的数据库不一定非要再存放在共享存储上，可以是存储在本地磁盘上
```



**AlwaysOn在各副本间数据同步原理：**

```
AlwaysOn必须要维护各副本间的数据一致性，当主副本上的数据发生变化，会同步到辅助副本上。这里AlwaysOn通过三个步骤来完成：
	步骤1：主副本记录发生变化的数据；
	步骤2：将记录传输到各个辅助副本；
	步骤3:把数据变化操作在辅助副本上执行一遍。
具体实现如下：
	在主副本和辅助副本上，SQL Server都会启动相应的线程来完成相应的任务。对于一般的SQL Server服务器，即没有配置高可用性，会运行Log Writer的线程，当发生数据修改事务时，此线程负责将本次操对应的日志信息记录到日志缓冲区中，然后再写入到物理日志文件。但如果配置了AlwaysOny主副本的数据库，SQL Server会为它建立一个叫Log Scanner的线程，不间断的工作，负责将日志从日志缓冲区或日志文件里读出，打包成日志块，发送到辅助副本。因此可以保证发生的数据变化，不断送给各辅助副本。
	辅助副本上存在固化(harden)和重做(redo)两个线程完成数据更新操作，固化线程会将主副本Log Scanner所发过来的日志块写入辅助副本磁盘上的日志文件里，因此称为固化，然后重做线程负责从磁盘上读取日志块，将日志记录对应的操作重演一遍，此时主副本和辅助副本上的数据就一致了。重做线程每隔固定的时间点，会跟主副本通信，告知自己的工作进度。主副本由此知道两边数据的差距。Log Scanner负责传送日志块，不需要等待Log Writer完成日志固化；辅助副本完成日志固化以后就会发送消息到主副本，告知数据传输完成，而不需要等待重做完成，这样各自独立的设计，是尽可能减少 AlwaysOn所带来的操作对数据库性能的影响。
```



**alwayson 同步提交模式：**

​	同步提交模式可分为  **辅助副本发出同步请求** 和 **主副本发出同步请求**

​	**辅助副本发出同步请求：**

​		主要发生在辅助副本刚刚加入可用性组、或者网络等原因主副本出现差异、或者辅助副本出现脏页（物理）等少数情况下。

![](https://img2018.cnblogs.com/blog/780228/201810/780228-20181024235106560-454843373.png)



| **步  骤**        | **行  为**                                                   |
| ----------------- | ------------------------------------------------------------ |
| 1.连接            | 辅助副本通过主副本的镜像端点建立两者之间的连接。             |
| 2.请求数据        | 辅助副本发出一个请求到主副本，要求主副本发送日志块。辅助副本和主副本会协商出一个日志块的LSN初始位置以及一些其他的信息。 |
| 3.运行Log Scanner | 在主副本上，Log Scanner的工作线程开始工作。Log Scanner负责将日志块传送到辅助副本。 |
| 4.固化和重做日志  | 辅助副本会使用固化（Harden）线程和重做（Redo）线程的工作线程来处理Log Scanner发送过来的日志块，固化线程将日志块固化到辅助副本的磁盘上，而重做线程负责将日志中记录的事务在辅助副本上重新演绎。 |
| 5.反馈进度        | 每当辅助副本收到3条来自主副本的消息的时候，就把固化和重做的进度作为一个消息返回给主副本。如果超过1秒还没收到3条消息，进度消息也会被返回。反馈到主副本的消息里包含了哪些LSN已经在辅助副本上被重做和固化。 |

​	**主副本发出同步请求：**

![](https://img2018.cnblogs.com/blog/780228/201810/780228-20181025004100737-1455046348.png)

| **步  骤**            | **行  为**                                                   |
| --------------------- | ------------------------------------------------------------ |
| 1.提交事务            | 在主副本上运行COMMIT TRAN命令来提交事务.                     |
| 2.写入到本 地日志记录 | 在主副本上，COMMIT TRAN命令会被写成一条日志记录（此时记录还在主数据库的日志缓存中）.然后主副本上的log writer工作线程会把直到COMMIT命令为止的所有日志记录组成一个日志块从缓存写入到磁盘上的LDF文件中。当日志被写入到磁盘之后，主数据库就开始等待来自辅助副本的消息来确认日志在辅助数据库上被成功写入磁盘。在这之前，该事务提交操作会保持等待。 |
| 3.扫描日志            | 当日志块开始被从缓存写入到磁盘上时，它也会发信号给Log Scanner工作线程，告诉Log Scanner“日志已经准备好了，可以被发送到辅助副本上”。Log Scanner从缓存中取出日志块，把它发送给AlwaysOn的日志块解码器（Log Block Cracker）。解码器会搜索日志中那些需要特别处理的操作，比如file stream操作，文件增长等。解码器会把这些操作作为一个消息发送给辅助副本。一旦日志块被解码完毕，整个日志块也会被作为消息发送给辅助副本. |
| 4.处理日志块消息      | 日志块消息在辅助副本上得到处理。固化线程负责将日志固化到磁盘上。然后日志被保存到辅助数据库的日志缓存中，重做线程从缓存中获得日志块并开始执行重做操作. |
| 5.反馈进度            | 每当辅助副本收到3条来自主副本的消息时，就把固化和重做的进度作为一个消息返回给主副本。如果超过1秒还没收到3条消息，进度消息也会被返回。进度信息中包含当前哪些LSN被固化了，哪些LSN已经被重做了。由于重做线程晚于固化操作启动，被固化的LSN可能会多于被重做的LSN. |
| 6.完成提交            | 主数据库受到了辅助副本来的确认消息，完成事务提交处理并向客户端发送一条确认消息. |

 ```
 2. 补充说明
 
 在同步提交模式下，日志块必须在主副本和辅助副本上都被固化到磁盘上，事务才能真正在主数据上提交。但是它并不要求日志在辅助副本上完成重做，这样可以减轻对主副本的性能影响。
 进入DISCONNECTED或"NOT SYNCHRONIZING"状态后，即使可用性副本处于同步提交模式，事务也不需要等待该副本的响应就可以在主副本上提交。
 如果为当前主副本配置了异步提交可用性模式，则它将通过异步方式为所有辅助副本提交事务，而不管这些副本各自的可用性模式设置如何。
   它可以保证事务日志是同步的，也就是可以保证不丢失数据，但不能保证数据变化没有延时，这是由于辅助副本在接收主副本传来的Trans log时，首先将其缓到本地Log Cache，接着强制硬化到本地Ldf，然后随即向主副本告知你可以commit了，但注意，此时的硬化到本地ldf并非本地数据已经变化，这是因为辅助副本将trans log硬化到本地的同时，它是使用一个异步进程去redo这些trans log产生的Page变化到Data文件的，所以数据的延时就是肯定的了。
 3.AlwaysOn异步提交模式
          当辅助副本处于异步提交模式下时，主副本无须确认该辅助副本已经完成日志固化，就可以提交事务。因此，主数据库事务提交不会受到辅助数据库的影响而产生等待。
           对于主副本和辅助副本相隔很远而且不希望小错误影响主副本性能的灾难恢复方案，异步提交模式将会很有用。而且，由于主副本不会等待来自辅助副本的确认，因而辅助副本上的问题从不会影响主副本。
       在异步提交模式下，辅助副本会尽量与自主副本的日志记录保持一致。不过，即使辅助数据库和主数据库上的数据事实上是同步的，可用性组也始终认为辅助数据库处于“SYNCHRONIZING”状态（即“未同步”状态）。
 ```









# 系统数据库

**master库**

​	用于记录所有SQL Server系统级别的信息，这些信息用于 **控制用户数据库和数据操作。**

**msdb库**

​	由 Enterprise Manager和Agent使用，记录着**任务计划信息、事件处理信息、数据备份及恢复信息、警告及异常信息。**



**model库**

​	SQL Server为用户数据库提供的样板，新的用户数据库都以 model数据库为基础。每次创建一个新数据库时，SQL Server先制作一个model数据库的拷贝，然后再将这个拷贝扩展成要求的规模。

**tempdb库**

​	一个共享的工作空间，SQL Server中的所有数据库都可以使用它。它为临时表和其他临时工作提供了一个存储区。

​	如

```sql
select tempT.a from (select * from salars) as tempT
这里的'select * from salars'就形成了一个临时的中间表，这个中间表就存在tempdb里，每次重启sql，tempdb里的数据将完全重建
```





























# sp_updatestats

**Sp_updatestats** 执行时，将始终更新内存优化表的统计信息

**sp_updatestats** 可以触发存储过程或其他已编译代码的重新编译。 但是，如果在引用的表和索引上只有一个查询计划，则 **sp_updatestats** 可能不会导致重新编译。 在这些情况下，即便更新了统计信息也不必进行重新编译。

更新统计信息可确保查询使用最新的统计信息进行编译。

查询优化器使用统计信息来创建可提高查询性能的查询计划。

```
exec sp_updatestats [[@resample = ] 'resample']
使用resample选项，则统计信息将根据最新的采样率进行更新。
不使用，采样率由sql server根据表中的行总数自动确定
```





# 存储过程

```
create proce|procedure  procedure_Name [;name]
[
	{@parameter [type_schema_name] data_type}
	[varying] [=default] [out|output]
][,...n]
[WITH <procedure_option> [,...n] ]
[FOR REPLICATION]
AS{[BEGIN] sql_statement[;][...n][END]}

procedure_Name：新建的存储过程名
;name ： 可选整数
@parameter：存储过程的参数，最多2100个
datatype：参数的数据类型
varying：指定作为输出参数支持的结果集
default：参数默认值
output：表明参数为输出参数
FOR REPLICATION：设定不能在订阅服务器上对存储过程进行复制操作
AS：指定存储过程要执行的操作
sql_statement：存储过程包含的T-SQL语句
```





```
变量的声明：
	declare  @I  int
变量的赋值：
	set @I =30
声明多个变量
delare @s varchar(10),@a int
变量的打印：
	print @I
	select @I
```



# select 笔记  

  语法：
  ```
  select  select_list [INTO new_table]
  [from table_source] [where search_condition]
  [group by GROUP_BY_expression]
  [having search_condition]
  [order by order_expresssion [ASC|DESC] ]
  ```
  解释：
    INTO子句：创建一个新表，并将来自查询的结果行插入该表中
    from：指定查询数据的来源，通常为表或视图
    where子句：指定检索条件
    group by 子句：根据查询结果按照指定字段进行分组
    HAVING：从分组结果中筛选出符合分组统计条件的数据
    ORDER by：对查询结果按字段进行排序，默认是升序。【ASC：升序，DESC：降序】
    

## WITH语句
  WITH语句用于指定临时命名的结果集

    
    
    
