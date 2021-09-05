# SQL Server笔记

* 查询数据库是否存在

```if DB_ID ("testDB") is not null;```

* 检查表是否存在

```sql
if OBJECT_ID ("textDB", "U") is not null;   --其中U代表用户表
```

* 数据库的创建和删除

```sql
create database databaseName;     --创建数据库
drop database databaseName;       --删除数据库
```

* 表的创建和删除

```sql
create table   --创建表
drop table tableName；   --删除表
```

* 创建新的登录账户

```sql
user master
go
exec sp_addlogin "xiaozhang", "1234"    --xiaozhang是账户， 1234是密码
```



* 删除登录账户

```sql
use master
go
exec sp_droplogin "xiaozhang"
```

登录账户删除后，该账户创建的数据库用户还在，并不会一同删除

* 添加/删除数据库用户

```sql
--创建数据库用户
use TestManageDB
go
exec sp_granddbaccess "xiaozhang", "xiaozhang03"

--删除数据库用户
use TestManageDB
go
exec sp_dropuser 'xiaozhang03'
```

* 给数据库用户授权

```sql
-- 注意：这里是将数据库中 数据表 的权限给数据库用户
-- grant 权限 on  表名  to  数据库用户

use SchoolDB
go
--为数据库用户分配权限（查询，修改，输入）
grant select,update,insert on UserInfo to xiaozhang03

--分配选项（创建数据表）
grant create table toxiaozhang03
```

* 收回数据库用户的权限

```sql
-- revoke 权限 on 表名 to 数据库用户

revoke select,update,insert on SchoolDB  to xiaozhang03

```



给单个数据库用户授权非常麻烦，可以定义一个角色，给该角色授权，再将角色赋给特点用

* 赋予/删除数据库用户角色

```sql
-- 赋予数据库用户固定角色
exec sp_addrolemember '数据库角色名称', '数据库用户名'

-- 删除角色成员
exec sp_droprolemember '数据库角色名称', '数据库用户名'
```

* 变量的分类

```sql
局部变量：（过程中使用）
	局部变量必须以标记 '@' 为前缀， 如 @age
	局部变量的使用也是先声明（declare），在赋值
	
全局变量：（任何时候都可以使用）
	全局变量以 '@@' 为前缀， 如 @@version
	全局变量有系统定义和维护，只能读取，不能修改
	部分全局变量:
		@@ERROR  -- 最后一个 T-SQL错误的错误号
		@@IDENTITY  -- 最后一次插入的标识值
		@@LANGUAGE  -- 当前使用的语言的名称
		@@MAX_CONNECTIONS  -- 可以创建的同时连接的最大数目
		@@ROWCOUNT  -- 受上一个SQL语句影响的行数
		@@SERVERNAME  -- 本地服务器的名称
		@@TRANSCOUNT  -- 当前连接打开的事务数
		@@VERSION  -- SQL Server 的版本信息
```

* 局部变量定义和赋值

```sql
-- 局部变量定义的语法
declare @变量名  数据类型

-- 赋值方法
set @变量名=值  
或 
select @变量名=值  -- 使用select赋值要确保筛选出的记录只有一条


```

* set  和 select 赋值比较

  | 使用场景           | set              | select                     |
  | ------------------ | ---------------- | -------------------------- |
  | 同时对多个变量赋值 | 不支持           | 支持                       |
  | 表达式返回多个值时 | 出错             | 将返回的最后一个值赋给变量 |
  | 表达式未返回值时   | 变量被赋值NULL值 | 变量保持原值               |

```sql
-- 定义变量
declare @strId int， @stuName nvarchar(20)

-- 多个变量赋值
set @stuId='1001', @stuName='小章'  -- 不允许这样赋值
select @stuId='1001', @stuName='小章'  -- 允许

-- 表达式返回多个值
set @stuId=(select * from Students)  -- 不允许
select @stuId=stuId from Students --得到最后一个数赋值给stuId

-- 表达式未返回值时
set @stuId=(select * from Students where 1<0)  --@stuId被赋NULL值
select @stuId=stuId from Students where 1<0  --@stuId保持原值

```

* 数据类型转换 convert/cast

  参考URL：https://blog.csdn.net/qq_41609957/article/details/102904617

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```

* 创

```sql

```





















