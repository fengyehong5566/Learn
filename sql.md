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
​    标量函数：
​        create function funcName（@varName varType）
​        returns
​        begin
​            ....
​        end

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
​    数据库的性能收到数据库设计、查询结构、并行处理、客户端和服务器端模式、程序设计等方面的影响。
​    数据库设计：
​        1、规范化：就是让数据库中无序的数据变的更加有条理，表中的数据都在合理的位置。使用范式规则可对数据库进行结构化的设计
​            第一范式：
​                数据表中的字段只包含一种数据类型，每种数据只存放在一个地方
​            第二范式：
​                确保表中包含一个唯一的实体数据。第二范式要求每个非键属性完全依赖于主键
​            第三范式：
​                表中所有非关键字段相互独立，表中任意字段内容进行更改不会影像其他字段。
​        2、选择适当的数据类型
​            选择正确的、合理的数据类型对后期的查找速度有直接的影响。
​            a、选择可以存储数据的最小数据类型
​            b、尽量使用简单的数据类型。
​                简单的数据类型的操作通常需要更少的cpu周期。
​            c、尽量避免NULL
​                在有NULL值的字段上设计索引、索引统计和值的比较更加复杂。
​        3、索引的选择
​            通常只为对 应用程序 起关键作用的查询或者被很多用户频繁使用的查询创建索引。
​    
​    查询优化：
​        1、避免使用“*”
​            限制或取列、行的数量可以缩短执行时间，提高查询效率
​        2、避免负逻辑
​            任何负逻辑(如 !=、<>或 not in )都将导致SQL server2016 用 表扫描 来完成查询
​            例如：
​                if not exist （select * fromtable where ...）
​                begin
​                    / statement here /
​                end
​            改为：
​                if exist (select * fromtable where ...)
​                begin    
​                    goto label
​                end
​                / statement here /
​                label:exit
​    
​        3、列操作：
​            where 子句中 列旁边的任何操作都将导致数据库使用 表扫描 来完成查询。
​            例如：
​                select * from employee where substring(name, 1, 1) = "W"
​            改为：
​                select * from employee where name  like "W%"
​                此时优化器就会用一个建立在name上的索引来进行查询
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
​    每个sql server数据库至少有两个操作系统文件：
​        数据文件：包含数据和对象。如表、索引、存储过程和视图
​        日志文件：包含恢复数据库中所有事务所需要的信息。
​    
​    文件组：为了便于分配和管理，可以将 数据文件 集合起来进行管理

​    

## 索引

sql语句编写

```sql
select dinstinct  ..from  ..join ..on .. \
where ..group by ..having ..order by ..limit ..
```

sql语句解析过程

```sql
from .. on.. join ..where ..group by ..having ..select dinstinct .. \
order by ..limit ..
```

详细过程可参考：https://www.cnblogs.com/annsshadow/p/5037667.html

索引是什么？

答：索引就是帮助mysql 高效获取数据的一种 数据结构。索引就是一种 树结构，mysql一般用的是 B+树。

索引的优点和缺点？

答：

> 缺点：
> 
> 1、当数据量很大的时候，索引也会很大。会占用一定得内存/物理空间
> 
> 2、索引并不适用所有的情况：
> 
>   a、少量数据；b、频繁进行改动的字段；c、很少适用的字段
> 
> 3、索引能提高查询，但会降低“增删改”的效率
> 
> 优点：
> 
> 1、提高查询效率（降低了IO使用率）
> 
> 2、降低了cpu使用率

索引分类：

    单值索引：利用表中的某一个字段创建单值索引，一个表里可以有多个单值索引

    唯一索引：即特殊的单值索引。创建唯一索引的字段中的数据没有重复的值。

    复合索引：利用表中的多个字段创建的索引

    主键索引：即特所的唯一索引，主机索引不能有null值，唯一索引可以有null值

    全文索引：InnoDB，MyISAM引擎都能用，只能在CHAR，VARCHAR，TEXT类型的字段上加该索引。主要用来查找文本中的关键字，而不是直接与字段值进行比较，全文索引需要配合match against使用，而不是一般的where like…

    空间索引：是对空间数据类型的字段建立的索引，空间索引的列必须是not null，只有MyISAM支持该索引。

创建索引：

```sql
--方法一：create 索引类型  索引名  on 表名(字段名);
create indexType  indexName on tableName(columnName)


--方法二：alter table tableName add 索引类型  索引名(字段名...)
alter table tb  add index dept_index(dept);
```

删除索引：

```sql
drop index  indexName on tableName
```

索引查询：

```sql
show  index from tableName
```

聚集索引和费聚集索引：

    聚集索引：聚集索引是索引结构和数据一起存放的索引。类似于字典的正文，当我们根据拼音直接就能找到那个字。

    非聚集索引：非聚集索引是索引结构和数据分开存放的索引。类似于根据偏旁部首找字，首先找到该字所在的地址，再根据地址找到这个字的信息。

创建语法：

```sql
create cluster index  indexName on tableName(colu1,colu2,...)
```

## 优化SQL：

1、查看执行计划：

```sql
explain  +  SQL语句
eg： explain select * from tb;
```

2、“执行计划“中需要指导的几个”关键字“

> id：编号
> 
> select_type：查询类型
> 
> table：表
> 
> type：类型
> 
> possible_keys：预测用到的索引
> 
> key：实际使用的索引
> 
> key_len：实际使用索引的长度
> 
> ref：表之间的引用
> 
> rows：通过索引查询到的数据量
> 
> Extra：额外的信息

​    

3、explain输出详解：

id：

> id值相同，从上往下顺序执行。表的执行顺序因表数量的改变而改变。
> 
> id值有相同，也有不同。id值越大越优先；id值相同，从上往下顺序执行。
> 
> id值不同，id值越大越优先查询。因为进行嵌套子查询时，先查内层，再查外层。

select_type:

> simple：不包含子查询，不包含union查询。
> 
> primary：包含子查询的主查询(最外层)
> 
> subquery：包含子查询的主查询(非最外层)
> 
> derived：衍生查询(用到了临时表)
> 
>     在from子查询中，只有一张表；
>     在from子查询中，如果table1 union table2，则table1就是derived表；
>     
>     explain select  cr.cname     
>     from ( select * from course where tid = 1  union select * 
>     from course where tid = 2 ) cr ;
> 
> union：union之后的表称之为union表
> 
> union result：告诉我们，哪些表之间使用了union查询

type关键字的使用说明：索引类型

> system：源表只有一条数据（实际中，基本不可能）；衍生表只有一条数据的主查询（偶尔可达到）
> 
> const：仅仅能查到一条数据的SQL ,仅针对Primary key或unique索引类型有效。
> 
> eq_ref
> 
> ref
> 
> range
> 
> index
> 
> ALL

**possible_keys和key：**

    possible_keys：可能用到的索引，是一种预测，可能不准。了解就好

    key：是指实际用到的索引

如果possible_key/key是NULL，则说明没用索引。

**key_len：**

    索引的长度，用于判断复合索引是否被完全使用(a,b,c)。

    注：key_len的值，可以理解为使用到的索引中含有的字段，key_len等于使用到的字段定义的长度之和

        如果索引字段可以为null，mysql底层会使用1个字节用于标识

        varchar属于可变的长度，mysql底层会使用2个字节用于标识

**ref：**

指明当前表所参照的字段。

注意与type中的ref值区分。在type中，ref只是type类型的一种选项值。

**row：**

被索引优化查询的数据个数 (实际通过索引而查询到的数据个数)

**extra：**

表示其他的一些说明，也很有用。

using filesort：

a、针对单索引的情况。

 当出现了这个词，表示你当前的SQL性能消耗较大。表示进行了一次“额外”的排序。常见于order by语句中。总结：对于单索引，如果排序和查找是同一个字段，则不会出现using filesort；如果排序和查找不是同一个字段，则会出现using filesort；因此where哪些字段，就order by哪些些字段。

b、针对复合索引的情况

不能跨列(官方术语：最佳左前缀)

![](D:\Program%20Files\marktext\images\50bf27175a0597e49f1c007dbc6f5a249df0344c.png)

结果分析：复合索引的顺序是(a1,a2,a3)，可以看到a1在最左边，因此a1就叫做“最佳左前缀”，如果要使用后面的索引字段，必须先使用到这个a1字段。对于explain1，where后面我们使用a1字段，但是后面的排序使用了a3，直接跳过了a2，属于跨列；对于explain2，where后面我们使用了a2字段，直接跳过了a1字段，也属于跨列；对于explain3，where后面我们使用a1字段，后面使用的是a2字段，因此没有出现【using filesort】。

c、using temporary

当出现了这个词，也表示你当前的SQL性能消耗较大。这是由于当前SQL用到了临时表。一般出现在group by中。

当你查询哪个字段，就按照那个字段分组，否则就会出现using temporary。

        

d、using index

using index称之为“索引覆盖”。表示不用读取源表，而只利用索引获取数据，不需要回源表查询。

e、using where

表示需要【回表查询】，表示既在索引中进行了查询，又回到了源表进行了查询。

f、impossible where(了解)

当where子句永远为False的时候，会出现impossible where

# SQL server数据库备份

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

```sql
        USE [master]
        GO
        ALTER DATABASE [AdventureWorks2008R2] SET RECOVERY FULL WITH NO_WAIT
        GO
```

​        T-SQL语句备份事务日志：

```sql
user [master]
GO

BACKUP LOG [AdventureWorks2008R2]
TO DISK = N'backupPath\filename.trn' with compression,stats=1;
GO
```

事务日志备份链：

​    由于数据库完全备份是时间点数据的完整拷贝，每个数据库完整备份相互独立，而多个事务日志备份是通过事务日志链条连接在一起，事务日志链起点于完全备份，SQL Server中的每一个事务日志备份文件都拥有自己的FirstLSN和LastLSN，FirstLSN用于指向前一个事务日志备份文件的LastLSN；而LastLSN指向下一个日志的FirstLSN，以此来建立这种链接关系。这种链接关系决定了事务日志备份文件还原的先后顺序。当然，如果其中任何一个事务日志备份文件丢失或者破坏，都会导致无法恢复整个事务日志链，仅可能恢复到你拥有的事务日志链条的最后一个。事务日志备份链条的关系如下图所示：

![img](https://pic4.zhimg.com/80/v2-8ca6a95f160cce959428f56bf14a006f_720w.jpg)

**数据库差异备份：**

    

    

# 数据库恢复模式

    数据库有三种恢复模式：简单恢复模式、完整恢复模式和大容量日志恢复模式

    选中“run”，右键“属性”，选中“选项”，“恢复模式”

    **简单恢复模式**，旧称：Checkpoint with truncate log。在这个模式下，SQL Server会**在每次checkpoint或backup之后⾃动截断log**，也就是丢弃所有的inactive log records，仅保留⽤于实例启动时⾃动发⽣的instance recovery所需的少量log，这样做的**好处**是log⽂件⾮常⼩，不需要DBA去维护、备份log，**坏处**也是显⽽易见的，就是⼀旦数据库出现异常，需要恢复时，最多只能恢复到上⼀次的备份，⽆法恢复到最近可⽤状态，因为log丢失了。 Simple模式主要⽤于⾮critical的业务，⽐如开发库和测试库，但是道富这边的SQL Server（即使是⽣产库）⼤都采⽤Simple模式，是因为这边的SQL Server⼤都⽤于⾮critical的业务（critical的数据库⼤都采⽤Oracle和DB2)，可以忍受少于1天的数据丢失(我们的job每天都会定时备份全库）。

        如果需要压缩数据库⽇志（Shrink语句），将数据库模式切换到简单恢复模式后压缩率才是最⾼的，如果你的数据库在完整恢复模式或⼤容
量⽇志回复模式下采⽤⽇志压缩，压缩后的⽇志⼤⼩并不会很理想。

**完整恢复模式：**

        和Simple模式相反，Full模式的旧称叫”Checkpoint without truncate log“，也就是SQL Server不主动截断log，只有备份log之后，才可以截断log，否则log⽂件会⼀直增⼤，直到撑爆硬盘，因此需要部署⼀个job定时备份log。Full的好处是可以做point-in-time恢复，最⼤限度的保证数据不丢失，⼀般⽤于critical的业务环境⾥。缺点就是DBA需要维护log，增加⼈员成本（其实也就是多了定时备份log这项⼯作⽽已）。

**大容量日志恢复**

        Bulk-logged模式和full模式类似，唯⼀的不同是针对以下Bulk操作，会产⽣尽量少的log：

1) Bulk load operations (bcp and BULK INSERT).

2) SELECT INTO. 

3) Create/drop/rebuild index 
   
     众所周知，通常bulk操作会产⽣⼤量的log，对SQL Server的性能有较⼤影响，bulk-logged模式的作⽤就在于降低这种性能影响，并防⽌log⽂件过分增长，但是它的问题是⽆法point-in-time恢复到包含bulk-logged record的这段时间。 Bulk-logged模式的最佳实践⽅案是在做bulk操作之前切换到bulk-logged，在bulk操作结束之后马上切换回full模式。
   
   注：
   
     如果想要

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

## STATISTICS IO

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

| 命令类别 | 功能                              | 列如  |
| ---- | ------------------------------- | --- |
| 维护   | 对数据库、索引或文件组进行维护的任务              |     |
| 杂项   | 杂项任务，如启用跟踪标志或从内存中删除 DLL         |     |
| 信息   | 收集并显示各种类型信息的任务                  |     |
| 验证   | 对数据库、表、索引、目录、文件组或数据库页的分配进行的验证操作 |     |

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

```txt
1、log flush（primary）
2、log capture（primary）
3、send（primary and secondary）
4、log receive and cache （secondary）
5、log hardened（secondary）
【6、send（secondary and primary）同步提交模式下】
6、redo（secondary）

前两个步骤发生在主副本，最后三个步骤发生在辅助副本，中间的第三个步骤发生主副本和辅助副本
之间。

另外，如果是同步提交模式，还需要增加一个步骤：辅助副本在步骤5之后，会发送一个（日志
硬化）确认信息给主副本，然后才能进入redo阶段。

```

```textile
alwayson技术集中了故障转移群集、数据库镜像和日志传送三者的优点，但有不相同：
    故障转移群集的单位是 SQL实例
    数据库镜像和日志传送的单位是 单个用户数据库
    alwayson的单位是 可用性组

    alwayson的每个组中可以包括一个或者多个用户数据库。一旦发生切换，可用性组中的所有
数据库组合会作为一个整体进行切换。

    alwayson底层采用Windows故障转移群集的机制进行检测和转移，只不过可用性组中的数据
库不一定非要再存放在共享存储上，可以是存储在本地磁盘上
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

​    同步提交模式可分为  **辅助副本发出同步请求** 和 **主副本发出同步请求**

​    **辅助副本发出同步请求：**

​        主要发生在辅助副本刚刚加入可用性组、或者网络等原因主副本出现差异、或者辅助副本出现脏页（物理）等少数情况下。

![](https://img2018.cnblogs.com/blog/780228/201810/780228-20181024235106560-454843373.png)

| **步  骤**        | **行  为**                                                                                                  |
| --------------- | --------------------------------------------------------------------------------------------------------- |
| 1.连接            | 辅助副本通过主副本的镜像端点建立两者之间的连接。                                                                                  |
| 2.请求数据          | 辅助副本发出一个请求到主副本，要求主副本发送日志块。辅助副本和主副本会协商出一个日志块的LSN初始位置以及一些其他的信息。                                             |
| 3.运行Log Scanner | 在主副本上，Log Scanner的工作线程开始工作。Log Scanner负责将日志块传送到辅助副本。                                                      |
| 4.固化和重做日志       | 辅助副本会使用固化（Harden）线程和重做（Redo）线程的工作线程来处理Log Scanner发送过来的日志块，固化线程将日志块固化到辅助副本的磁盘上，而重做线程负责将日志中记录的事务在辅助副本上重新演绎。 |
| 5.反馈进度          | 每当辅助副本收到3条来自主副本的消息的时候，就把固化和重做的进度作为一个消息返回给主副本。如果超过1秒还没收到3条消息，进度消息也会被返回。反馈到主副本的消息里包含了哪些LSN已经在辅助副本上被重做和固化。   |

​    **主副本发出同步请求：**

![](https://img2018.cnblogs.com/blog/780228/201810/780228-20181025004100737-1455046348.png)

| **步  骤**     | **行  为**                                                                                                                                                                                                                                    |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.提交事务       | 在主副本上运行COMMIT TRAN命令来提交事务.                                                                                                                                                                                                                  |
| 2.写入到本 地日志记录 | 在主副本上，COMMIT TRAN命令会被写成一条日志记录（此时记录还在主数据库的日志缓存中）.然后主副本上的log writer工作线程会把直到COMMIT命令为止的所有日志记录组成一个日志块从缓存写入到磁盘上的LDF文件中。当日志被写入到磁盘之后，主数据库就开始等待来自辅助副本的消息来确认日志在辅助数据库上被成功写入磁盘。在这之前，该事务提交操作会保持等待。                                                      |
| 3.扫描日志       | 当日志块开始被从缓存写入到磁盘上时，它也会发信号给Log Scanner工作线程，告诉Log Scanner“日志已经准备好了，可以被发送到辅助副本上”。Log Scanner从缓存中取出日志块，把它发送给AlwaysOn的日志块解码器（Log Block Cracker）。解码器会搜索日志中那些需要特别处理的操作，比如file stream操作，文件增长等。解码器会把这些操作作为一个消息发送给辅助副本。一旦日志块被解码完毕，整个日志块也会被作为消息发送给辅助副本. |
| 4.处理日志块消息    | 日志块消息在辅助副本上得到处理。固化线程负责将日志固化到磁盘上。然后日志被保存到辅助数据库的日志缓存中，重做线程从缓存中获得日志块并开始执行重做操作.                                                                                                                                                                 |
| 5.反馈进度       | 每当辅助副本收到3条来自主副本的消息时，就把固化和重做的进度作为一个消息返回给主副本。如果超过1秒还没收到3条消息，进度消息也会被返回。进度信息中包含当前哪些LSN被固化了，哪些LSN已经被重做了。由于重做线程晚于固化操作启动，被固化的LSN可能会多于被重做的LSN.                                                                                                      |
| 6.完成提交       | 主数据库受到了辅助副本来的确认消息，完成事务提交处理并向客户端发送一条确认消息.                                                                                                                                                                                                    |

```
2. 补充说明

   在同步提交模式下，日志块必须在主副本和辅助副本上都被固化到磁盘上，事务才能真正在主数
据上提交。但是它并不要求日志在辅助副本上完成重做，这样可以减轻对主副本的性能影响。
   进入DISCONNECTED或"NOT SYNCHRONIZING"状态后，即使可用性副本处于同步提交模式，
事务也不需要等待该副本的响应就可以在主副本上提交。
   如果为当前主副本配置了异步提交可用性模式，则它将通过异步方式为所有辅助副本提交事务，而
不管这些副本各自的可用性模式设置如何。
   它可以保证事务日志是同步的，也就是可以保证不丢失数据，但不能保证数据变化没有延时，这
是由于辅助副本在接收主副本传来的Trans log时，首先将其缓到本地Log Cache，接着强制硬
化到本地Ldf，然后随即向主副本告知你可以commit了，但注意，此时的硬化到本地ldf并非本
地数据已经变化，这是因为辅助副本将trans log硬化到本地的同时，它是使用一个异步进
程去redo这些trans log产生的Page变化到Data文件的，所以数据的延时就是肯定的了。
3.AlwaysOn异步提交模式
    当辅助副本处于异步提交模式下时，主副本无须确认该辅助副本已经完成日志固化，就可以提
交事务。因此，主数据库事务提交不会受到辅助数据库的影响而产生等待。
    对于主副本和辅助副本相隔很远而且不希望小错误影响主副本性能的灾难恢复方案，异步提交
模式将会很有用。而且，由于主副本不会等待来自辅助副本的确认，因而辅助副本上的问题从不会
影响主副本。
    在异步提交模式下，辅助副本会尽量与自主副本的日志记录保持一致。不过，即使辅助数据库
和主数据库上的数据事实上是同步的，可用性组也始终认为辅助数据库处于“SYNCHRONIZING”状
态（即“未同步”状态）。
```

# 系统数据库

**master库**

​    用于记录所有SQL Server系统级别的信息，这些信息用于 **控制用户数据库和数据操作。**

**msdb库**

​    由 Enterprise Manager和Agent使用，记录着**任务计划信息、事件处理信息、数据备份及恢复信息、警告及异常信息。**

**model库**

​    SQL Server为用户数据库提供的样板，新的用户数据库都以 model数据库为基础。每次创建一个新数据库时，SQL Server先制作一个model数据库的拷贝，然后再将这个拷贝扩展成要求的规模。

**tempdb库**

​    一个共享的工作空间，SQL Server中的所有数据库都可以使用它。它为临时表和其他临时工作提供了一个存储区。

​    如

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

# 附录

## SQL server  与 mysql 高可用比较

SQL SERVER 的 ALWAYS ON  和 MYSQL的  MGR 有什么不同？

> 1、mysql 的MGR 支持多主的模式，SQL server 不支持
> 
> 2、SQL server 的AWO 支持同步和异步的同步模式。mysql的MGR不支持，可以视为强一致的同步模式
> 
> 3、SQL server 和 mysql 都是通过日志的方式来进行复制的
> 
> 4、mysql的MGR是使用整体数据库实例复制的方式，SQL server的集群，不是基于 instance 而是基于数据库的。

# 常用操作

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

## sp_MSforeachdb 和 sp_MSforceachtable 过程

这两个sp_MSforeachdb 和 sp_MSforceachtable 过程，为了便于在多库多表执行命令

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

## 链接服务器查询数据库报错处理

        在alwayson群集的副本上查询，当主节点上的统计信息未与备节点上的统计信息同步时，使用四段式查询方法或报错。

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

## 在alwayson辅助副本上创建用户

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

## alwayson 切换操作

方法1[ssms]：

> **切换**     在 SSMS中登录将要切换到的辅助副本，打开对象资源管理器，展开 “AlwaysOn 高可用性” - ”可用性组”  。
>     在 对应的可用性组上右键选择故障转移。
>     在确认故障转移可能丢失数据界面选择确认框。
>     一直点击“下一步”直到故障转移完成。
> 
> **继续同步**     在 SSMS中依次登录需要继续同步数据的辅助副本，打开对象资源管理器，展开 “AlwaysOn 高可用性” - ”可用性组” - ”可用性数据库” 。
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

## 服务器级的固定角色说明

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

## 固定数据库角色名说明

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

## 日志收缩

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



## 删除数据库

```
-- 官方语句

EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'test'
GO

/*
sql server 在每次备份和恢复数据库后，会向msdb系统数据库的备份和恢复历史表写入数据，
如果sql server经常备份、恢复，会造成msdb库变大，微软建议定期执行
sp_delete_backuphistory存储过程来删除msdb的内容。

-- 删除msdb数据库中，2022年1月1号之前的备份和恢复历史表的内容
msdb.dbo.sp_delete_backuphistory @oldest_date="01/01/2022" 

-- 删除msdb数据库中, TestDB数据库的所有备份和恢复历史表的内容
msdb.dbo.sp_delete_database_backuphistory @database_name ='TestDB'

*/

USE [master]
GO
/****** Object:  Database [test]
    Script Date: 2022/9/17 11:42:0 ******/
DROP DATABASE [test]
GO



```