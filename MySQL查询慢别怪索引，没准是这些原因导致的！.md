# 

# 数据库操作

```sql
-- 创建数据库
create database  databaseName

-- 删除数据库
drop database  databaseName

-- 显示所有数据库
show databases

--打开数据库
use databaseName

--创建表
create table tableName
(
    A char(10) not null primary key,
    B char(20) null
);

-- 显示表
show tables

-- 显示表结构
desc tableName
or
describe tableName;

-- 往表里添加值
insert into tableName('A','B'...) values('2022','xiaoming')
or
--下面的方法必须和定义列顺序一致
insert into tableName values('2022','xiaoming') 

-- 显示表的所有内容
select * from  tableName

------------ Alter 相关 ------------------
-- 添加字段和配置结构
    alter table student add    name char(4); 
-- 删除某个字段
    alter table student drop   name; 
-- 改变字段的结构，但不改变字段名
    alter table student modify name char(10); 
-- 改变字段名和字段结构
    alter table student change name names varchar(20); 
-- 给字段设置默认值 
    alter table student alter  names set default '女'; 
-- 删除字段的默认值 
    alter table student alter  names drop default; 
-- 重命名表名
    alter table student rename to student1; 

------------- 表里的数据操作 -------------
-- 插入数据
    insert into  kc set 课程号 = '401',课程名 = 'Java',
开课学期 = '1',学时 = '80',学分 = '10';

-- 主键一样的情况下替换数据
    replace into kc set 课程号 = '401',课程名 = 'PHP',
开课学期 = '2',学时 = '90',学分 = '20';

-- 修改数据
-- 无条件修改
    update kc  set 学分= 学分 + 10
-- 带条件修改
    update kc  set 学分= 学分 + 10 where 课程号 = '101';

-- 删除数据
delete from  kc where  课程号 = '101';

-- 从多个表中删除行（数据）
-- 假设有三个表，t1、t2、t3，他们都含有ID列（字段）。
-- 请删除t1中ID值等于t2中ID值的所有行和t2中的ID值等于t3中ID值的所有行。
delete t1,t2 from t1,t2,t3
    where t1.id = t2.id and t2.id = t3.id;
或
delete t1,t2 using t1,t2,t3
    where t1.id = t2.id and t2.id = t3.id;

-- 删除指定表中的所有数据，但参与了索引和视图的表不可用它来删，应用delete
    truncate table 表名

-------------- 数据查询  -------------
-- 选择知道的列
select 字段名 from 表名;
select * from 表名; --*通配符查询所有字段数据

-- 给列起别名
select name as 名字 from 表名;
--当别名有空格时需用''号括起来
select student as 'student number' from 表名;

-- 替换查询结果中的数据
-- 把数量这个字段起别名作为库存，根据条件替换数量字段里的内容(不是真实修
-- 改表内数据，只是查询时的修改)
select 图书编号,书名,
case 
    when 数量 is null then '尚未进货'
    when 数量 < 5 then '需进货' 
    when 数量 >= 5 and 数量 <= 50 then '库存正常' 
    else '库存积压' 
end as 库存 
from book;

-- 即使列值
select 图书编号,订购册数*订购单价 as 订购金额 
from sell
where 是否发货 = '已发货';

-- 消除结果中重复的行
--比如学生表里的专业名与总学分可能有很多相同的
select distinct 图书类别,出版社
from book;

--------------- 聚合函数 ----------
count(*|distinct|表达式)
select count(*) as 数量 from kc;

max(*|distinct|表达式)
select max(学分) as 最大值 from xs_kc;

min(*|distinct|表达式)
select min(学分) as 最大值 from xs_kc;

sum(*|distinct|表达式) --计算某个列所有值的总和
select sum(收入) from kc;

avg(*|distinct|表达式) --计算某个列所有值的平均值
select avg(收入) from kc;

-- 比较运算符的几个注意
<>不等于 <=>相等或都等于空时为true，两个有一个空或不空但值不相同都
为false !=不等于

-- 逻辑运算符
    and    &&    与
    or     ||    或
    not    !     非
    xor          异或运算 

-------- 立刻运算符 —— 模式匹配 -------
_ ：通配任意单一字符
% ：通配任意N个字符
-- 查询members表中姓“张”的信息
    select * from members where name like '张%';
-- 查询students表中学号倒数第二位是0的学生情况
    select * from students where 学号 like '%0_';
-- 查询book书名包含下划线的图书
-- 知识点补充（关键字）：
--    escape '#' 表示#后面是普通字符，即转义了，#号可以自定义
    select * from book where 书名 like '%#_%' escape '#';

-------- 范围比较 (between 和 in) --------
select * from book
where 出版时间 between '2010-1-1' and '2010-12-31';

select * from book
where 出版社 in ('高等教育出版社','人民邮电大学出版社');

------- 空值比较（is 和 is not） -------
select * from sell where 是否发货 is null;

------- 多表查询 -------------------
-- 不加条件的连接（xs是学生表_无成绩字段，xs_kc是课程表_无专业名字段）
select 专业名,成绩 from xs,xs_kc;

-- 加条件的连接理解：两个表中学号有不一样的，如果不加条件，
-- 则会把学号一样的和不一样的 学生专业名和成绩都查出来，
-- 加了条件后，只会把两个表中学号一样的学生（即同一个学生）的 
-- 专业名和成绩查出来。
select 专业名,成绩 from xs,xs_kc
where xs.学号 = xs_kc.学号;

------------- join连接 -----------
-- 两表连接
select 书名,订购册数
from book inner joim sell on book.图书编号 = sell.图书编号
where 书名 = '网页设计' and 订购册数 > 5;

-- 多表连接
select book.图书编号,会员名,书名,订购册数
from sell join book   on book.图书编号 = sell.图书编号
          join member on sell.身份证号 = member.身份证号
where 书名 = '网页程序设计' and 订购册数 > 5;

-- 自表连接：连接的两个表都是一个表，只不过给起了别名来区分 
-- 使用情况：比如查询sell表中，图书编号相同，但订单号不同的图书的订购
-- 用户
select a.订购用户 from sell as a join sell as b 
on a.图书编号 = b.图书编号
where a.订单号 != b.订单号;

-- using 子句
-- 当连接的表中列名相同，且连接的条件就是列名相等，可以用using
select distinct 会员姓名
from members join sell using(身份证号);

-- 子查询
-- 在 where 子句里套 select， 用 in 来校验 where里的select查询结果
-- 格式：expression [not] in (subquery)

select * frrom sell
where 身份证号 in (
    select 身份证号 from members where 会员姓名 = '张三'
);

------------ 分类汇总与排序 ----------
-- group by
-- 用于根据字段来分组。例如根据学生专业名来分组
select  count(专业名) from xs
group by 专业名；

-- having 
-- 该子句用在gruop by子句后，通常搭配聚合函数使用
-- 查询订购单数在2笔以上的人的身份证号
select 身份证号 from sell
group by 身份证号 having 订购单数 > 2;

-- order by
--用来对查询结果排序的，ASC表示升序，DESC表示降序
select 成绩 from xs_kc
    order by 成绩 DESC;
select 成绩 from xs_kc
    order by 成绩 ASC;

-- limit 子句
-- limit子句是select最后一个子句，用于限制select返回的行数
    limit 5 --返回前5条记录
    limit 3,5 --返回从第4条开始（包括第4条）的5条记录
```

# mysql 四类日志

    **错误日志、二进制日志（BINLOG 日志）、查询日志、慢查询日志**

## 错误日志：

        错误日志记录了当mysqld 启动和停止时，以及服务器在运行过程中发生任何严重错误时的相关信息。当数据库出现任何故障导致无法正常使用时，可以先查看此日志。

        该日志是默认 **开启** 的，查看日志位置指令：

```sql
show variables like 'log_error%';
```

## 二进制日志：

        二进制日志（BINLOG）记录了所有的 DDL 语句和 DML 语句，但是**不包括数据查询语句**。此日志对于灾难时的数据恢复起着极其重要的作用，MySQL 的主从复制， 就是通过该 binlog 实现的。

        该日志默认情况下是**关闭**的，需要到 MySQL 的配置文件中开启，并配置 MySQL 日志的格式。

    开启二进制日志：

    在 my.cnf 配置文件中，添加如下配置：

```context
# 配置开启 binlog 日志
log_bin=mysqlbin

#配置二进制日志的格式
binlog_format=MIXED
```

重启 mysqld 服务生效。配置生效后，系统会创建 mysqlbin.000001,mysqlbin.000002 这类格式的二进制文件。

    日志格式：

    binlog_format 有3 个值：

> **STATEMENT**     该日志格式在日志文件中**记录的都是SQL语句**（statement），**每
> 一条对数据进行修改的SQL都会记录**在日志文件中，通过 MySQL 提供
> 的 mysqlbinlog 工具，可以清晰的查看到每条语句的文本。主从
> 复制的时候，从库（slave）会将日志解析为原文本，并在从库重
> 新执行一次。
> 
> **ROW**     该日志格式在日志文件中**记录的是每一行的数据变更，而不是记
> 录 SQL 语句**。比如，执行SQL语句 ： 
> update tb_book set status='1' , 如果是 STATEMENT 日志
> 格式，在日志中会记录一行 SQL 文件； 如果是 ROW，由于是对全表
> 进行更新，也就是每一行记录都会发生变更，ROW 格式的日志中会记
> 录每一行的数据变更
> 
> **MIXED**     **默认的日志格式**，即混合了 STATEMENT 和 ROW 两种格式。
> 
> 默认情况下采用 STATEMENT，但是在一些特殊情况下采用 ROW
> 
> 来进行记录。MIXED 格式能尽量利用两种模式的优点，而避开他
> 
> 们的缺点。

    日志删除：

    有 4 种删除日志方法：

>     **Reset Master：** 指令删除全部 binlog 日志，删除之后，日志编号，将从 xxxx.000001重新开始。
> 
>     **purge master logs to 'mysqlbin.XXX'**，该命令将删除XXX编号之前的所有日志。
> 
>     **purge master logs before 'yyyy-MM-dd hh:mm:ss'**，该命令将删除日志为 "yyyy-MM-dd hh:mm:ss" 之前产生的所有日志。
> 
>     设置参数 --expire_logs_days=# ，此参数的含义是设置日志的过期天数， 过了指定的天数后日志将会被自动删除，这样将有利于减少DBA 管理日志的工作量。

  

## 查询日志：

    查询日志中记录了客户端的所有操作语句，而二进制日志不包含查询数据的 SQL 语句。

    默认情况下，查询日志是 **关闭** 的。

    开启查询日志：

    修改 my.cnf 日志

```context
# 该选项用来开启查询日志，可选值：0 -- 关闭； 1 -- 开启
general_log=1

#设置日志的文件名，如果没有指定，默认文件名为：host_name.log
general_log_file=file_name
```

    重启生效。

## 慢查询日志：

    慢查询日志记录了所有执行时间超过参数 long_query_time 设置值并且扫描记录数不小于 min_examined_row_limit 的所有的 SQL 语句的日志。

    long_query_time 默认为 10 秒，最小为 0 ，精度可以到微妙

    慢查询日志默认是 **关闭** 的。

    开启慢查询日志：

    修改my.cnf 文件

```context
# 控制慢查询日志是否开启，可取值：0 -- 关闭， 1 -- 开启
slow_query_log=1

# 指定慢查询日志的文件名
slow_query_log_file=/var/lib/mysql/slow_query.log


# 配置查询的时间限制，默认10s
long_query_time=10
```

    重启生效。

```sql
# 查看慢查询日志相关配置的值
show variables like '%quer%';
```

    查看慢查询日志文件：

    和错误日志、查询日志一样，慢查询日志记录的格式也是纯文本，可以被直接读取。

    如果慢查询日志内容很多，直接查看文件会比较麻烦，这个时候需要借助于 MySQL 自带的 **mysqldumpslow** 工具， 来对慢查询日志进行分类汇总。

> mysqldumpslow --help
> 
> -s：排序方式，后边接着如下参数
>  al：平均锁定时间
>  ar：平均返回记录书
>  at：平均查询时间
>  c：访问次数
>  l：锁定时间
>  r：返回记录
>  t：查询时间
> -t：返回前面多少条的数据
> -g：翻遍搭配一个正则表达式，大小写不敏感

```sql
# 例子
# 获取返回记录集最多的10个sql
mysqldumpslow -s r -t 10 /var/lib/mysql/slow-query.log

# 获取访问次数最多的 10 个sql
mysqldumpslow -s c -t 10 /var/lib/mysql/slow-query.log

# 获取按照时间排序的前 10 条里面含有左连接的查询语句
mysqldumpslow -s t -t 10 -g "left
 join" /var/lib/mysql/slow-query.log
```

# msyql主从复制

**主库操作：** 

```sql
# 首先新建一个数据同步的用户，让从库使用这个用户进行数据同步
create user 'slave'@'%' identified by 'password';

# 用户授权, %：代表任意IP
grant replication slave,replication client 
    on *.* to 'slave'@'%';

# 主库备份，如果没有业务访问，可以不用锁表。但最后先锁表再备份
flush tables  with  read lock;

# 使用 mysqldump 备份所需要同步的库
mysqldump -uroot -p --databases databaseName | 
    gzip >  mysql.bak.$(date +%F)sql.gz

# 记录file 和 Position 值
show master status；

# 解表
unlock tables；



```

**从库操作：** 

    把备份的数据刷到从服务器的数据库里

    修改my.conf, 一般只需要改两个值，把 server-id 改为唯一值

```context
# my.cnf
[mysqld]
log-bin=mysql-slave-bin
server-id=2


```

    重启从库数据库    

```sql
# 设置主从配置
change master to 
master_host='MasterIP',  
master_port=3306,   
master_user='slave', 
master_password='mypassword',  
master_log_file='mysql-bin.000014',   
master_log_pos= 154, 
master_delay=900, 
master_connect_retry=30;

/*
master_host ：主库的地址
master_port：主库的端口号
master_user：用于数据同步的用户
master_password：用于同步的用户的密码
master_log_file：指定 Slave 从哪个日志文件开始复制数
    据，即上文中提到的 File 字段的值
master_log_pos：从哪个 Position 开始读，即上文中提
    到的 Position 字段的值
master_delay：延迟复制配置，设置从数据库延时 N 秒
    后，再与主数据库进行数据同步复制
master_connect_retry：如果连接失败，重试的时间间
    隔，单位是秒，默认是 60 秒

*/

# 开启主从复制
start slave 


# 查看同步状态 
show slave status \G;

# SlaveIORunning 和 SlaveSQLRunning 的值都为yes，代表主从复制开启。



```

# 附录

## MySQL查询慢别怪索引，没准是这些原因导致的！

dbaplus社群 *2022-07-12 07:15* *发表于广东*

以下文章来源于小白debug ，作者小白

**dbaplus社群**

围绕Database、BigData、AIOps的企业级专业社群。资深大咖、技术干货，每天精品原创文章推送，每周线上技术分享，每月线下技术沙龙，每季度Gdevops&DAMS行业大会.

979篇原创内容

公众号

我熟练应用ctrl c和ctrl v 开发curd代码好多年了。

mysql查询为什么会慢，关于这个问题，在实际开发经常会遇到，而面试中，也是个高频题。

遇到这种问题，我们一般也会想到是因为索引。

**那除开索引之外，还有哪些因素会导致数据库查询变慢呢？**

**有哪些操作，可以提升mysql的查询能力呢？**

今天这篇文章，我们就来聊聊会导致数据库查询变慢的场景有哪些，并给出原因和解决方案。

**一、数据库查询流程**

我们先来看下，一条查询语句下来，会经历哪些流程。

比如我们有一张数据库表：

```
CREATE TABLE `user` (
```

我们平常写的应用代码（go或C++之类的），这时候就叫**客户端**了。

客户端底层会带着账号密码，尝试向mysql建立一条TCP长链接。

mysql的**连接管理模块**会对这条连接进行管理。

建立连接后，客户端执行一条查询sql语句。比如：

```
select * from user where gender = 1 and age = 100;
```

客户端会将sql语句通过网络连接给mysql。

mysql收到sql语句后，会在**分析器**中先判断下SQL语句有没有语法错误，比如select，如果少打一个l，写成**slect**，则会报错**You have an error in your SQL syntax;** 。这个报错对于我这样的手残党来说可以说是很熟悉了。

接下来是**优化器**，在这里会**根据一定的规则选择该用什么索引。**

之后，才是通过**执行器**去调用**存储引擎**的接口函数。

![图片](https://mmbiz.qpic.cn/mmbiz_png/ufWcjcomw8byOTvs7ycajm8XH5BG08b2rEXOzlXrXBqgaPLorfDHM0b0EOGliadRewpR3uCcnClFIYxg7uQ2jCg/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)Mysql架构

**存储引擎**类似于一个个组件，它们才是mysql真正获取一行行数据并返回数据的地方，存储引擎是可以替换更改的，既可以用不支持事务的MyISAM，也可以替换成支持事务的Innodb。这个可以在建表的时候指定。比如：

```
CREATE TABLE `user` (
```

现在最常用的是**InnoDB**。

我们就重点说这个。

InnoDB中，因为直接操作磁盘会比较慢，所以加了一层内存提提速，叫**buffer pool**，这里面，放了很多内存页，每一页16KB，有些内存页放的是数据库表里看到的那种一行行的数据，有些则是放的索引信息。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)bufferPool与磁盘

查询SQL到了InnoDB中。会根据前面优化器里计算得到的索引，去**查询相应的索引页，**如果不在buffer pool里则从磁盘里加载索引页。**再通过索引页加速查询，得到数据页**的具体位置。如果这些数据页不在buffer pool中，则从磁盘里加载进来。

这样我们就得到了我们想要的一行行数据。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)索引页与磁盘页的关系

最后将得到的数据结果返回给客户端。

**二、慢查询分析**

如果上面的流程比较慢的话，我们可以通过开启**profiling**看到流程慢在哪。

```
mysql> set profiling=ON;
```

然后正常执行sql语句。

这些SQL语句的执行时间都会被记录下来，此时你想查看有哪些语句被记录下来了，可以执行 **show profiles;**

```
mysql> show profiles;
```

关注下上面的**query_id，**比如**select * from user where age>=60**对应的query_id是1，如果你想查看这条SQL语句的具体耗时，那么可以执行以下的命令。

```
mysql> show profile for query 1;
```

通过上面的各个项，大家就可以看到具体耗时在哪。比如从上面可以看出Sending data的耗时最大，这个是指**执行器**开始查询数据并将数据发送给客户端的耗时，因为我的这张表符合条件的数据有**好几万条**，所以这块耗时最大，也符合预期。

一般情况下，我们开发过程中，耗时大部分时候都在**Sending data**阶段，而这一阶段里如果慢的话，最容易想到的还是索引相关的原因。

**三、索引相关原因**

索引相关的问题，一般能用explain命令帮助分析。通过它能看到**用了哪些索引，**大概会**扫描多少行**之类的信息。

mysql会在**优化器阶段**里看下选择哪个索引，查询速度会更快。

一般主要考虑几个因素，比如：

- 选择这个索引大概要扫描**多少行（rows）；**

- 为了把这些行取出来，需要读**多少个16kb的页；**

- 走普通索引需要回表，主键索引则不需要，**回表成本**大不大？

回到show profile中提到的sql语句，我们使用**explain select * from user where age>=60** 分析一下。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)explain sql

上面的这条语句，使用的**type**为ALL，意味着是**全表扫描**，**possible_keys**是指**可能用得到的索引**，这里可能使用到的索引是为age建的普通索引，但实际上数据库使用的索引是在**key**那一列，是**NULL**。也就是说**这句sql不走索引，全表扫描。**

这个是因为数据表里，符合条件的数据行数（rows）太多，如果使用age索引，那么需要将它们从age索引中读出来，并且age索引是**普通索引，**还需要**回表**找到对应的**主键**才能找到对应的**数据页**。算下来还不如直接走主键划算。于是最终选择了全表扫描。

当然上面只是举了个例子，实际上，mysql执行sql时，**不用索引或者用的索引不符合我们预期**这件事经常发生，索引失效的场景有很多，比如用了**不等号，隐式转换**等，这个相信大家背八股文的时候也背过不少了，我也不再赘述。

聊两个生产中容易遇到的问题吧。

**1、索引不符合预期**

实际开发中有些情况比较特殊，比如有些数据库表一开始数据量小，索引少，执行sql时，确实使用了符合你预期的索引。但随时时间边长，开发的人变多了，数据量也变大了，甚至还可能会加入一些其他重复多余的索引，就有可能出现用着用着，用到了不符合你预期的其他索引了。从而导致查询突然变慢。

这种问题，也好解决，可以通过**force index指定索引。**比如：

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)force index指定索引

通过explain可以看出，加了force index之后，sql就选用了idx_age这个索引了。

**2、走了索引还是很慢**

有些sql，用explain命令看，明明是走索引的，但还是很慢。一般是两种情况：

第一种是索引区分度太低，比如网页全路径的url链接，这拿来做索引，一眼看过去全都是同一个域名，如果**前缀索引**的长度建得不够长，那这走索引跟走**全表扫描**似的，正确姿势是尽量让索引的**区分度**更高，比如域名去掉，只拿后面URI部分去做索引。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)索引前缀区分度太低

第二种是索引中匹配到的数据太大，这时候需要关注的是explain里的**rows**字段了。

它是用于**预估**这个查询语句需要查的行数的，它不一定完全准确，但可以体现个大概量级。

当它很大时，一般常见的是下面几种情况。

如果这个字段具有**唯一**的属性，比如电话号码等，一般是不应该有大量重复的，那可能是你代码逻辑出现了**大量重复插入**的操作，你需要检查下代码逻辑，或者需要加个**唯一索引**限制下。

如果这个字段下的数据就是会很大，是否需要全部拿？如果不需要，加个limit限制下。如果确实要拿全部，那也不能一次性全拿，今天你数据量小，可能一次取一两万都没啥压力，万一哪天涨到了十万级别，那一次性取就有点吃不消了。你可能需要**分批次取**，具体操作是先用order by id排序一下，拿到一批数据后取最大id作为下次取数据的起始位置。

**四、连接数过小**

索引相关的原因我们聊完了，我们来聊聊，**除了索引之外，还有哪些因素会限制我们的查询速度的。**

我们可以看到，mysql的server层里有个**连接管理，**它的作用是管理客户端和mysql之间的长连接。

正常情况下，客户端与server层如果只有**一条**连接，那么在执行sql查询之后，只能阻塞等待结果返回，如果有大量查询同时并发请求，那么**后面的请求都需要等待前面的请求执行完成**后，才能开始执行。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)连接过少会导致sql阻塞

因此很多时候我们的应用程序，比如go或java这些，**会打印出sql执行了几分钟的日志，但实际上你把这条语句单独拎出来执行，却又是毫秒级别的。**这都是因为这些sql语句在**等待**前面的sql执行完成。

怎么解决呢？

如果我们能**多建几条连接**，那么请求就可以并发执行，后面的连接就不用等那么久了。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)增加连接可以加快执行sql

而连接数过小的问题，**受数据库和客户端两侧同时限制。**

**1、数据库连接数过小**

Mysql的最大连接数默认是100, 最大可以达到16384。

可以通过设置mysql的**max_connections**参数，更改数据库的最大连接数。

```
mysql> set global max_connections= 500;
```

上面的操作，就把最大连接数改成了500。

**2、应用侧连接数过小**

数据库连接大小是调整过了，但貌似问题还是没有变化？还是有很多sql执行达到了几分钟，甚至超时？

那有可能是因为你应用侧（go，java写的应用，也就是mysql的客户端）的连接数也过小。

应用侧与mysql底层的连接，是**基于TCP协议的长链接，**而TCP协议，需要经过**三次握手和四次挥手**来实现建连和释放。如果我每次执行sql都重新建立一个新的连接的话，那就要不断握手和挥手，这很**耗时**。所以一般会建立一个**长连接池**，连接用完之后，塞到连接池里，下次要执行sql的时候，再从里面捞一条连接出来用，非常环保。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)连接池原理

我们一般写代码的时候，都会通过第三方的**orm库**来对数据库进行操作，而成熟的orm库，**百分之一千万都会有个连接池。**

而这个连接池，一般会有个大小。这个大小就控制了你的连接数最大值，如果说你的连接池太小，都还没有数据库的大，那调了数据库的最大连接数也没啥作用。

一般情况下，可以翻下你使用的orm库的文档，看下怎么设置这个连接池的大小，就几行代码的事情，改改就好。比如go语言里的**gorm**里是这么设置的

```
func Init() {
```

**五、buffer pool太小**

连接数是上去了，速度也提升了。

曾经遇到过面试官会追问，**有没有其他办法可以让速度更快呢？**

那必须要眉头紧锁，假装思考，然后说：**有的。**

我们在前面的数据库查询流程里，提到了进了innodb之后，会有一层内存buffer pool，用于将磁盘数据页加载到内存页中，只要查询到buffer pool里有，就可以直接返回，否则就要走磁盘IO，那就慢了。

也就是说，**如果我的buffer pool 越大，那我们能放的数据页就越多，相应的，sql查询时就更可能命中buffer pool，那查询速度自然就更快了。**

可以通过下面的命令查询到buffer pool的大小，单位是Byte。

```
mysql> show global variables like 'innodb_buffer_pool_size';
```

也就是128Mb。

如果想要调大一点。可以执行：

```
mysql> set global innodb_buffer_pool_size = 536870912;
```

这样就把buffer pool增大到512Mb了。

但是吧，如果buffer pool大小正常，只是**别的原因**导致的查询变慢，那改buffer pool毫无意义。

但问题又来了。

**怎么知道buffer pool是不是太小了？**

这个我们可以看**buffer pool的缓存命中率。**

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)查看buffer pool命中率

通过 **show status like 'Innodb_buffer_pool_%'**;可以看到跟buffer pool有关的一些信息。

**Innodb_buffer_pool_read_requests**表示读请求的次数。

**Innodb_buffer_pool_reads** 表示从物理磁盘中读取数据的请求次数。

所以buffer pool的命中率就可以这样得到：

```
buffer pool 命中率 = 1 - (Innodb_buffer_pool_reads/Innodb_buffer_pool_read_requests) * 100%
```

比如我上面截图里的就是，1 - (405/2278354) = 99.98%。可以说命中率非常高了。

一般情况下**buffer pool命中率**都在**99%**以上，如果低于这个值，才需要考虑加大innodb buffer pool的大小。

当然，还可以把这个命中率做到**监控**里，这样半夜sql变慢了，早上上班还能定位到原因，就很舒服。

**六、还有哪些骚操作？**

前面提到的是在**存储引擎层**里加入了buffer pool用于缓存内存页，这样可以加速查询。

那同样的道理，**server层**也可以加个缓存，直接将第一次查询的结果缓存下来，这样**下次**查询就能立刻返回，听着挺美的。

按道理，如果命中缓存的话，确实是能为查询加速的。但这个功能限制很大，其中最大的问题是只要数据库表被更新过，表里面的**所有缓存都会失效，**数据表频繁的更新，就会带来频繁的缓存失效。所以这个功能只适合用于那些**不怎么更新的数据表。**

另外，这个功能在**8.0版本**之后，就被**干掉**了。所以这功能用来聊聊天可以，没必要真的在生产中使用啊。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)查询缓存被删除

**七、总结**

- 数据查询过慢一般是索引问题，可能是因为选错索引，也可能是因为查询的行数太多。

- 客户端和数据库连接数过小，会限制sql的查询并发数，增大连接数可以提升速度。

- innodb里会有一层内存buffer pool用于提升查询速度，命中率一般>99%，如果低于这个值，可以考虑增大buffer pool的大小，这样也可以提升速度。

- 查询缓存（query cache）确实能为查询提速，但一般不建议打开，因为限制比较大，并且8.0以后的Mysql里已经将这个功能干掉了。

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)

![图片](data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQImWNgYGBgAAAABQABh6FO1AAAAABJRU5ErkJggg==)
