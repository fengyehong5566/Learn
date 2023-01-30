<mark>TDSQL学习</mark>

    TDSQL 是腾讯基于mysql分支(mariadb/percona)为金融联机交易场景推出的强一致分布式数据库集群系统。

    腾讯云数据库包含三大产品系列：

        分析型数据库TDSQL-A （Tencent Analytical Database）

        云原生数据库TDSQL-C （Tencent CloudNative Database）

        分布式数据库TDSQL （Tencent DistributedDatabase）

# 架构

架构：

![](D:\Program%20Files\marktext\images\3a9c982594db294b726236062085d8827a28342f.png)

高可用恢复：

![](D:\Program%20Files\marktext\images\a9c149dd9f0f31b1b36daa7c08b529db0ec609fc.png)

参考：

[TDSQL架构及运营介绍 - 腾讯云开发者社区-腾讯云](https://cloud.tencent.com/developer/article/1336503)

# 产品术语

    **节点：** Set 或称为数据节点、分片。基于 MySQL 数据库主从协议联结成若干组。Set 是分布式实例中最小数据单元。每个 set 内部都具有一主 N 备的高可用架构。一个分布式实例是由 N 个 Set 组成，每个 Set中存有不同范围的数据，所有 set 加到一起是一份全量的数据

    **分片键：** 根据分片键把一份全量数据进行切分，每份数据称为数据分片

    **分布式实例：** Group_Shard，数据分布在 n 个 set 上面。也可以简称为shard

    **分片表：** 即水平拆分表（又名 Shard 表）；分表需指定一个字段，使用不同的分片算法（hash、list、range），将数据分布到不同的 set 当中。hash 分片算法使用 shardkey 语法，list 和 range 分片算法采用tdsql_distributed by 语法

    **单片表：** 又名 Noshard 表，用于存储一些无需分片的表，该表的数据全量存在第一个物理分片（set）中。所有单片表的数据都放在第一个物理分片（set）中。由于单片表默认放置在第一个 set 上，如果在分布式实例中建立了大量的单片表，则可能导致第一个 set 的负载太大

    **广播表：** 又名小表广播，该表的所有操作都将广播到所有节点（set）中，每个 set 都有该表的全量数据，常用于业务系统的配置表等

    **一级分区表：** 分片表的同义词

## 业务访问流程

    当业务访问时，首先通过负载均衡LVS转发流量，负载均衡是基于TCP/IP协议高性能的连接，然后通过SQL引擎解析路由信息，解析其中的SQL语句，读写分离判断，产生全局唯一值。SQL引擎通常设置3台，且没有主备之分全是对等的。解析完之后的SQL语句分发到对应的set上的MySQL底层，再由MySQL去执行。MySQL上有一个agent，通过agent与zookeeper关联。在部署的时候，agent和MySQL部署在一起。整个架构的核心是SQL引擎，MySQL存储引擎和zookeeper管理节点。

    **Zookeeper** 分布式协调系统管理维护整个集群元数据管理和通知作用。

    **Hadoop** 负责备份，数据库的数据。

    **Kafka** 主要是负责SQL的审计、多源同步。

    **赤兔管理平台** 负责操作整个系统，通过赤兔平台设置任务，监控，采集，备份以完成日常基本的运维服务。

# 数据类型

    TDSQL 分布式数据库支持 MySQL 所有数据类型，包括数字类型、字符类型、日期时间类型、Json 数据类型。

**数字类型：**  

    整型：TINYINT(1B)、SMALLINT(2B)、MEDIUMINT(3B)、INTEGER、INT(4B)、BIGINT(8B)

    浮点类型支持 FLOAT 和 DOUBLE，格式 FLOAT(M,D) 、REAL(M,D) 或 DOUBLE PRECISION(M,D)

    定点类型支持 DECIMAL和NUMERIC，格式 DECIMAL(M,D)

**字符：** 

    CHAR、VARCHAR 

    BINARY、VARBINARY

    BLOB、TEXT、TINYBLOB、TINYTEXT，MEDIUMBLOB、MEDIUMTEXT、LONGBLOB、LONGTEXT

    ENUM

    SET

    char、varchar最常用，LOB 和 TEXT 类型不建议使用

> CHAR 和 VARCHAR 类型相似，但存储和检索的方式不同。 它们在最大长度和是否保留尾随空格方面也不同。  
> 
> **CHAR** 和 VARCHAR 类型声明的长度指示要存储的最大字符数。 例如，CHAR(30) 最多可容纳 30 个字符。CHAR 列的长度固定为您在创建表时声明的长度。长度可以是 0 到 255 之间的任何值。存储 CHAR 值时，它们会用空格右填充到指定的长度。 
> 
> **VARCHAR** 列中的值是可变长度的字符串。长度可以指定为 0 到 65,535 之间的值。

**日期：** 

    TDSQL支持如下时间类型：

        DATE、 DATETIME、 TIMESTAMP 
        TIME 
        YEAR 

**空间：** 

    TDSQL支持如下空间类型：    

        GEOMETRY
        POINT
        LINESTRING
        POLYGON

        MULTIPOINT
        MULTILINESTRING
        MULTIPOLYGON
        GEOMETRYCOLLECTION

**Json：** 

    支持存储 JSON 格式的数据，使得对 JSON 处理更加有效，同时又能提早检查错误：

> **注意：**
> 
> 对 JSON 类型的字段进行排序时，不支持混合类型排序。如不能将 string 类型和 int 类型做比较，同类型排序只支持数值类型，string 类型，其它类型排序不处理。对下表来说，不支持`select * from t1 order by t1->"$.key2"`，因为排序列中包含了数值和字符串类型。

# TDSQL 使用限制

    TDSQL 分布式实例中所编写的 SQL 语句中凡是包含 shardkey、parition、distributed by 等关键字的会交由 proxy 处理，语句的剩余部分会发送到 DB,按照 MYSQL 语法执行。所有 TDSQL 分布式 SQL 不支持使用 DELAYED 和 LOW_PRIORITY，不支持对于变量的引用和操作，比如 SET @c=1,@d=@c+1; SELECT @c, @d 等

## TDSQL 大类限制

• 不支持自定义函数、事件、表空间  
• 不支持视图、存储过程、触发器、游标  
• 不支持外键、自建分区、临时表  
• 不支持复合语句，例如：BEGIN END，LOOP，UNION 的语句  
• 不支持主备同步相关的 SQL 语言

## TDSQL 小语法限制

TDSQL 分布式实例不支持 DDL、DML、管理 SQL 语言的部分语法，具体限  
制如下：  

– DDL  

    • 不支持 CREATE TABLE ... SELECT  

    • 不支持 CREATE TEMPORARY TABLE  

    • 不支持 CREATE/DROP/ALTER SERVER  

    • 不支持 CREATE/DROP/ALTER LOGFILE GROUP  

    • 不支持 ALTER 对分表键进行改名，但可以修改类型  

    • 不支持 RENAME  

– DML  

    • 不支持 SELECT INTO OUTFILE/INTO DUMPFILE/INTO  

        var_name  

    • 不支持 query_expression_options，如：  

        HIGH_PRIORITY/STRAIGHT_JOIN/SQL_SMALL_RESULT/SQL_BIG_RESULT/SQL_BUFFER_RESULT/SQL_CACHE/SQL_NO_CACHE/SQL_CALC_FOUND_ROWS  

    • 不支持窗口函数  

    • 不支持非 SELECT 的子查询  

    • 不支持不带列名的 INSERT/REPLACE  

    • 不支持不带 WHERE 条件的 UPDATE/DELETE  

    • 不支持 LOAD DATA/XML  

    • 不支持 SQL 中使用 DELAYED 和 LOW_PRIORITY  

    • 不支持 SQL 中对于变量的引用和操作，比如 SET @c=1, @d=@c+1; SELECT @c, @d  

    • 不支持 INDEX_HINT  

    • 不支持 HANDLER/DO  

    • 管理 SQL 语句  

– 不支持 ANALYZE/CHECK/CHECKSUM/OPTIMIZE/REPAIR TABLE，  

        需要用透传语法  

– 不支持 CACHE INDEX  

– 不支持 FLUSH  

– 不支持 LOAD INDEX INTO CACHE  

– 不支持 RESET  

– 不支持 SHUTDOWN  

– 不支持 SHOW BINARY LOGS/BINLOG EVENTS  

– 不支持 SHOW WARNINGS/ERRORS 和 LIMIT/COUNT 的组合

# DDL 语句

## create database

```sql
CREATE {DATABASE | SCHEMA} [IF NOT EXISTS] db_name
[create_option] ...

create_option: [DEFAULT] {
CHARACTER SET [=] charset_name
| COLLATE [=] collation_name
}
```

> 注意事项：  
> 
> • CREATE DATABASE 创建具有给定名称的数据库。CREATE SCHEMA 是 CREATE DATABASE 的同义词。  
> 
> • 如果数据库存在并且您没有指定 IF NOT EXISTS，则会发生错误。  
> 
> • 在具有活动 LOCK TABLES 语句的会话中不允许 CREATE DATABASE。  
> 
> • CHARACTER SET 选项指定默认的数据库字符集。 COLLATE 选项指定默认的数据库排序规则。
> 
> 要查看可用的字符集和排序规则，请使用 SHOW CHARACTER SET 和 SHOW COLLATION 语句

## create table

    TDSQL 分布式实例支持创建**分表、单表和广播表**。

    分表即自动水平拆分的表（Shard 表），水平拆分是基于分表键采用类似于一致性 Hash、Range、List 等方式，根据计算后的值分配到不同的节点组中的一种技术方案。可以将满足对应条件的行将存储在相同的物理节点组中。这种场景称为组拆分（Groupshard）,可以迅速提高应用层联合查询等语句的处理效率。

    TDSQL支持 LIST、RANGE、HASH 三种类型的**一级分区**，同时支持 RANGE、LIST两种格式的**二级分区**。

**创建一级 hash 分区表语法：** 

```sql
CREATE TABLE [IF NOT EXISTS] tbl_name
    [(create_definition)]
    [local_table_options]
    shardkey=column_name  

create_definition: {
    col_name column_definition
| {INDEX | KEY} [index_name] [index_type] (key_part,...)
    [index_option] ...
| [INDEX | KEY] [index_name] (key_part,...)
    [index_option] ...
| [CONSTRAINT [symbol]] PRIMARY KEY
    [index_type] (key_part,...)
    [index_option] ...
| [CONSTRAINT [symbol]] UNIQUE [INDEX | KEY]
    [index_name] [index_type] (key_part,...)
    [index_option] ...
}

column_definition: {
    data_type [NOT NULL | NULL] [DEFAULT]
        [AUTO_INCREMENT] [UNIQUE [KEY]] [[PRIMARY] KEY]
        [COMMENT 'string']
        [COLLATE collation_name]
        [COLUMN_FORMAT {FIXED | DYNAMIC | DEFAULT}]
        [ENGINE_ATTRIBUTE [=] 'string']
    | data_type
        [UNIQUE [KEY]] [[PRIMARY] KEY]
        [COMMENT 'string']
}

key_part: {col_name [(length)]} [ASC | DESC]

index_type:
    USING {BTREE}

index_option: {
    index_type | COMMENT 'string'
}
[local_table_options]
Local_table_option: {AUTO_INCREMENT [=] value
    | [DEFAULT] CHARACTER SET [=] charset_name
    | [DEFAULT] COLLATE [=] collation_name
    | COMMENT [=] 'string'
    | ENGINE [=] engine_name
    | ROW_FORMAT [=] {DEFAULT | DYNAMIC | FIXED | COMPRESSED
    | REDUNDANT| COMPACT}
    | STATS_AUTO_RECALC [=] {DEFAULT | 0 | 1}
    | STATS_PERSISTENT [=] {DEFAULT | 0 | 1}
    | STATS_SAMPLE_PAGES [=] value)
}
```

**创建一级 range| list 分区表语法：** 

```sql
CREATE TABLE [IF NOT EXISTS] tbl_name
    [(create_definition)]
    [local_table_options]
    TDSQL_DISTRIBUTED BY range|list (column_name) 
    [partition_options]


create_definition: {
    col_name column_definition
    | {INDEX | KEY} [index_name] [index_type] (key_part,...)
        [index_option] ...
    | [INDEX | KEY] [index_name] (key_part,...)
        [index_option] ...
    | [CONSTRAINT [symbol]] PRIMARY KEY
        [index_type] (key_part,...)
        [index_option] ...
    | [CONSTRAINT [symbol]] UNIQUE [INDEX | KEY]
        [index_name] [index_type] (key_part,...)
        [index_option] ...
}


column_definition: {
    data_type [NOT NULL | NULL] [DEFAULT]
    [AUTO_INCREMENT] [UNIQUE [KEY]] [[PRIMARY] KEY]
    [COMMENT 'string']
    [COLLATE collation_name]
    [COLUMN_FORMAT {FIXED | DYNAMIC | DEFAULT}]
    [ENGINE_ATTRIBUTE [=] 'string']
    | data_type
        [UNIQUE [KEY]] [[PRIMARY] KEY]
        [COMMENT 'string']
}

index_type:
    USING {BTREE}

index_option: {
index_type | COMMENT 'string'
}

[local_table_options]
Local_table_option: {AUTO_INCREMENT [=] value
| [DEFAULT] CHARACTER SET [=] charset_name
| [DEFAULT] COLLATE [=] collation_name
| COMMENT [=] 'string'
| ENGINE [=] engine_name
| ROW_FORMAT [=] {DEFAULT | DYNAMIC | FIXED | COMPRESSED 
| REDUNDANT | COMPACT}
| STATS_AUTO_RECALC [=] {DEFAULT | 0 | 1}
| STATS_PERSISTENT [=] {DEFAULT | 0 | 1}
| STATS_SAMPLE_PAGES [=] value)
}

partition_options:
    PARTITION BY
        | RANGE{(expr)}
        | LIST{(expr)}
    [(partition_definition [, partition_definition] ...)]

partition_definition:
    PARTITION partition_name
        [VALUES
            {LESS THAN {(expr | value_list) | MAXVALUE}
            |
            IN (value_list)}]
        [[STORAGE] ENGINE [=] engine_name]
        [COMMENT [=] 'string']


```

## 一级HASH分区表

    在TDSQL 中，分表也叫一级分区表。有 hash、range、list 三种规则。一级hash分区使用 shardkey 关键字指定拆分键。range和list 分区使用tdsql_distributed by 语法指定拆分键。

**一级hash分区：** 

    一级hash分区支持类型：

        - DATE  DATETIME

        - TINYINT  SMALLINT  MEDIUMINT  INT BIGINT

        - CHAR  VARCHAR

**一级 hash 分片注意事项：** 

    • Shardkey 字段必须是主键以及所有唯一索引的一部分  

    • Shardkey 字段的值不能为中文，因为 Proxy 不会转换字符集，所以不同字符集可能会路由到不同的分区  

    • Shardkey=a 需放在 SQL 语句的最后

## 一级RANGE分区表

一级 range 分区支持类型  

    – DATE，DATETIME，TIMESTAMP  

    – TINYINT, SMALLINT, MEDIUMINT, INT, and BIGINT  

    – CHAR，VARCHAR  

注意事项：  

– tdsql_distributed by ...语法放置于 create table ...的末尾      

– 创建一级 range 分区表语句中指定的 s1 和 s2 是每个 set 的别名，基于实现原理，s1、s2 不能自定义，只能按照顺序依次命名为 s1、s2…  

– set 的别名可通过/*proxy*/show status;获取到

## 一级LIST分区表

一级 list 分区支持类型 
    – DATE，DATETIME，TIMESTAMP      

    – TINYINT, SMALLINT, MEDIUMINT, INT, and BIGINT  

    – CHAR，VARCHAR  

注意事项：  

    – 分区键为字符串时，不要使用中文  

    – tdsql_distributed by ...语法放置于 create table ...的末尾  

    – 创建一级 list 分区表语句中指定的 s1 和 s2 是每个 set 的别名，基于实现原理，s1、s2 不能自定义，只能按照顺序依次命名为 s1、s2…  

    – set 的别名可通过/*proxy*/show status;获取到

# 附录

## 函数支持

### 控制流操作：

| Name     | Description                  |
| -------- | ---------------------------- |
| CASE     | Case operator                |
| IF()     | If/else construct            |
| IFNULL() | Null if/else construct       |
| NULLIF() | Return NULL if expr1 = expr2 |

### 字符串函数：

| Name               | Description                                                                                                                        |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| ASCII()            | Return numeric value of left-most character                                                                                        |
| BIN()              | Return a string containing binary representation of a number                                                                       |
| BIT_LENGTH()       | Return length of argument in bits                                                                                                  |
| CHAR()             | Return the character for each integer passed                                                                                       |
| CHAR_LENGTH()      | Return number of characters in argument                                                                                            |
| CHARACTER_LENGTH() | Synonym for CHAR_LENGTH()                                                                                                          |
| CONCAT()           | Return concatenated string                                                                                                         |
| CONCAT_WS()        | Return concatenate with separator                                                                                                  |
| ELT()              | Return string at index number                                                                                                      |
| EXPORT_SET()       | Return a string such that for every bit set in the value bits, you get an on string and for every unset bit, you get an off string |
| FIELD()            | Return the index (position) of the first argument in the subsequent arguments                                                      |
| FIND_IN_SET()      | Return the index position of the first argument within the second argument                                                         |
| FORMAT()           | Return a number formatted to specified number of decimal places                                                                    |
| FROM_BASE64()      | Decode to a base-64 string and return result                                                                                       |
| HEX()              | Return a hexadecimal representation of a decimal or string value                                                                   |
| INSERT()           | Insert a substring at the specified position up to the specified number of characters                                              |
| INSTR()            | Return the index of the first occurrence of substring                                                                              |
| LCASE()            | Synonym for LOWER()                                                                                                                |
| LEFT()             | Return the leftmost number of characters as specified                                                                              |
| LENGTH()           | Return the length of a string in bytes                                                                                             |
| LIKE               | Simple pattern matching                                                                                                            |
| LOAD_FILE()        | Load the named file                                                                                                                |
| LOCATE()           | Return the position of the first occurrence of substring                                                                           |
| LOWER()            | Return the argument in lowercase                                                                                                   |
| LPAD()             | Return the string argument, left-padded with the specified string                                                                  |
| LTRIM()            | Remove leading spaces                                                                                                              |
| MAKE_SET()         | Return a set of comma-separated strings that have the corresponding bit in bits set                                                |
| MATCH              | Perform full-text search                                                                                                           |
| MID()              | Return a substring starting from the specified position                                                                            |
| NOT LIKE           | Negation of simple pattern matching                                                                                                |
| NOT REGEXP         | Negation of REGEXP                                                                                                                 |
| OCT()              | Return a string containing octal representation of a number                                                                        |
| OCTET_LENGTH()     | Synonym for LENGTH()                                                                                                               |
| ORD()              | Return character code for leftmost character of the argument                                                                       |
| POSITION()         | Synonym for LOCATE()                                                                                                               |
| QUOTE()            | Escape the argument for use in an SQL statement                                                                                    |
| REGEXP             | Pattern matching using regular expressions                                                                                         |
| REPEAT()           | Repeat a string the specified number of times                                                                                      |
| REPLACE()          | Replace occurrences of a specified string                                                                                          |
| REVERSE()          | Reverse the characters in a string                                                                                                 |
| RIGHT()            | Return the specified rightmost number of characters                                                                                |
| RLIKE              | Synonym for REGEXP                                                                                                                 |
| RPAD()             | Append string the specified number of times                                                                                        |
| RTRIM()            | Remove trailing spaces                                                                                                             |
| SOUNDEX()          | Return a soundex string                                                                                                            |
| SOUNDS LIKE        | Compare sounds                                                                                                                     |
| SPACE()            | Return a string of the specified number of spaces                                                                                  |
| STRCMP()           | Compare two strings                                                                                                                |
| SUBSTR()           | Return the substring as specified                                                                                                  |
| SUBSTRING()        | Return the substring as specified                                                                                                  |
| SUBSTRING_INDEX()  | Return a substring from a string before the specified number of occurrences of the delimiter                                       |
| TO_BASE64()        | Return the argument converted to a base-64 string                                                                                  |
| TRIM()             | Remove leading and trailing spaces                                                                                                 |
| UCASE()            | Synonym for UPPER()                                                                                                                |
| UNHEX()            | Return a string containing hex representation of a number                                                                          |
| UPPER()            | Convert to uppercase                                                                                                               |
| WEIGHT_STRING()    | Return the weight string for a string                                                                                              |

### 数字函数和操作：

| Name            | Description                                                    |
| --------------- | -------------------------------------------------------------- |
| ABS()           | Return the absolute value                                      |
| ACOS()          | Return the arc cosine                                          |
| ASIN()          | Return the arc sine                                            |
| ATAN()          | Return the arc tangent                                         |
| ATAN2(), ATAN() | Return the arc tangent of the two arguments                    |
| CEIL()          | Return the smallest integer value not less than the argument   |
| CEILING()       | Return the smallest integer value not less than the argument   |
| CONV()          | Convert numbers between different number bases                 |
| COS()           | Return the cosine                                              |
| COT()           | Return the cotangent                                           |
| CRC32()         | Compute a cyclic redundancy check value                        |
| DEGREES()       | Convert radians to degrees                                     |
| DIV             | Integer division                                               |
| /               | Division operator                                              |
| EXP()           | Raise to the power of                                          |
| FLOOR()         | Return the largest integer value not greater than the argument |
| LN()            | Return the natural logarithm of the argument                   |
| LOG()           | Return the natural logarithm of the first argument             |
| LOG10()         | Return the base-10 logarithm of the argument                   |
| LOG2()          | Return the base-2 logarithm of the argument                    |
| -               | Minus operator                                                 |
| MOD()           | Return the remainder                                           |
| %, MOD          | Modulo operator                                                |
| PI()            | Return the value of pi                                         |
| +               | Addition operator                                              |
| POW()           | Return the argument raised to the specified power              |
| POWER()         | Return the argument raised to the specified power              |
| RADIANS()       | Return argument converted to radians                           |
| RAND()          | Return a random floating-point value                           |
| ROUND()         | Round the argument                                             |
| SIGN()          | Return the sign of the argument                                |
| SIN()           | Return the sine of the argument                                |
| SQRT()          | Return the square root of the argument                         |
| TAN()           | Return the tangent of the argument                             |
| *               | Multiplication operator                                        |
| TRUNCATE()      | Truncate to specified number of decimal places                 |
| -               | Change the sign of the argument                                |

### 时间函数：

| Name                                   | Description                                                                                                                 |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| ADDDATE()                              | Add time values (intervals) to a date value                                                                                 |
| ADDTIME()                              | Add time                                                                                                                    |
| CONVERT_TZ()                           | Convert from one time zone to another                                                                                       |
| CURDATE()                              | Return the current date                                                                                                     |
| CURRENT_DATE(), CURRENT_DATE           | Synonyms for CURDATE()                                                                                                      |
| CURRENT_TIME(), CURRENT_TIME           | Synonyms for CURTIME()                                                                                                      |
| CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP | Synonyms for NOW()                                                                                                          |
| CURTIME()                              | Return the current time                                                                                                     |
| DATE()                                 | Extract the date part of a date or datetime expression                                                                      |
| DATE_ADD()                             | Add time values (intervals) to a date value                                                                                 |
| DATE_FORMAT()                          | Format date as specified                                                                                                    |
| DATE_SUB()                             | Subtract a time value (interval) from a date                                                                                |
| DATEDIFF()                             | Subtract two dates                                                                                                          |
| DAY()                                  | Synonym for DAYOFMONTH()                                                                                                    |
| DAYNAME()                              | Return the name of the weekday                                                                                              |
| DAYOFMONTH()                           | Return the day of the month (0-31)                                                                                          |
| DAYOFWEEK()                            | Return the weekday index of the argument                                                                                    |
| DAYOFYEAR()                            | Return the day of the year (1-366)                                                                                          |
| EXTRACT()                              | Extract part of a date                                                                                                      |
| FROM_DAYS()                            | Convert a day number to a date                                                                                              |
| FROM_UNIXTIME()                        | Format Unix timestamp as a date                                                                                             |
| GET_FORMAT()                           | Return a date format string                                                                                                 |
| HOUR()                                 | Extract the hour                                                                                                            |
| LAST_DAY                               | Return the last day of the month for the argument                                                                           |
| LOCALTIME(), LOCALTIME                 | Synonym for NOW()                                                                                                           |
| LOCALTIMESTAMP, LOCALTIMESTAMP()       | Synonym for NOW()                                                                                                           |
| MAKEDATE()                             | Create a date from the year and day of year                                                                                 |
| MAKETIME()                             | Create time from hour, minute, second                                                                                       |
| MICROSECOND()                          | Return the microseconds from argument                                                                                       |
| MINUTE()                               | Return the minute from the argument                                                                                         |
| MONTH()                                | Return the month from the date passed                                                                                       |
| MONTHNAME()                            | Return the name of the month                                                                                                |
| NOW()                                  | Return the current date and time                                                                                            |
| PERIOD_ADD()                           | Add a period to a year-month                                                                                                |
| PERIOD_DIFF()                          | Return the number of months between periods                                                                                 |
| QUARTER()                              | Return the quarter from a date argument                                                                                     |
| SEC_TO_TIME()                          | Converts seconds to 'HH:MM:SS' format                                                                                       |
| SECOND()                               | Return the second (0-59)                                                                                                    |
| STR_TO_DATE()                          | Convert a string to a date                                                                                                  |
| SUBDATE()                              | Synonym for DATE_SUB() when invoked with three arguments                                                                    |
| SUBTIME()                              | Subtract times                                                                                                              |
| SYSDATE()                              | Return the time at which the function executes                                                                              |
| TIME()                                 | Extract the time portion of the expression passed                                                                           |
| TIME_FORMAT()                          | Format as time                                                                                                              |
| TIME_TO_SEC()                          | Return the argument converted to seconds                                                                                    |
| TIMEDIFF()                             | Subtract time                                                                                                               |
| TIMESTAMP()                            | With a single argument, this function returns the date or datetime expression; with two arguments, the sum of the arguments |
| TIMESTAMPADD()                         | Add an interval to a datetime expression                                                                                    |
| TIMESTAMPDIFF()                        | Subtract an interval from a datetime expression                                                                             |
| TO_DAYS()                              | Return the date argument converted to days                                                                                  |
| TO_SECONDS()                           | Return the date or datetime argument converted to seconds since Year 0                                                      |
| UNIX_TIMESTAMP()                       | Return a Unix timestamp                                                                                                     |
| UTC_DATE()                             | Return the current UTC date                                                                                                 |
| UTC_TIME()                             | Return the current UTC time                                                                                                 |
| UTC_TIMESTAMP()                        | Return the current UTC date and time                                                                                        |
| WEEK()                                 | Return the week number                                                                                                      |
| WEEKDAY()                              | Return the weekday index                                                                                                    |
| WEEKOFYEAR()                           | Return the calendar week of the date (1-53)                                                                                 |
| YEAR()                                 | Return the year                                                                                                             |
| YEARWEEK()                             | Return the year and week                                                                                                    |

### 聚合（GROUP BY）函数：

| Name    | Description                                   |
| ------- | --------------------------------------------- |
| AVG()   | Return the average value of the argument      |
| COUNT() | Return a count of the number of rows returned |
| MAX()   | Return the maximum value                      |
| MIN()   | Return the minimum value                      |
| SUM()   | Return the sum                                |

### 位操作：

| Name        | Description                            |
| ----------- | -------------------------------------- |
| BIT_COUNT() | Return the number of bits that are set |
| &           | Bitwise AND                            |
| ~           | Bitwise inversion                      |
| \|          | Bitwise OR                             |
| ^           | Bitwise XOR                            |
| <<          | Left shift                             |
| >>          | Right shift                            |

### 类型转换函数：

| Name      | Description                      |
| --------- | -------------------------------- |
| BINARY    | Cast a string to a binary string |
| CAST()    | Cast a value as a certain type   |
| CONVERT() | Cast a value as a certain type   |

> **cast 和 convert区别：** 
> 
> 语法：cast(字段a as 类型b)  
> 释义：把字段a的[类型转换](https://so.csdn.net/so/search?q=%E7%B1%BB%E5%9E%8B%E8%BD%AC%E6%8D%A2&spm=1001.2101.3001.7020)成类型b，as不可省略
> 
> 语法：convert(类型b，字段a )  
> 释义：把字段a的类型转换成类型b
> 
> 总结：函数cast和convert作用相同，只是语法稍有区别，会用一个就行 建议用cast。

## 网关分布式事务实现

网关提供begin供客户端开启事务，提供commit、rollback供客户端提交和回滚事务。

下面是网关处理begin、commit以及rollback请求时的具体操作：

[①]begin:

![](https://qqadapt.qpic.cn/txdocpic/0/913dc1382922f62c8c47ac39b1ffb57f/0?_type=png&w=940&h=190)

([i])网关接收到来自客户端的begin请求时，直接在内存中创建Gtxn结构体，便向用户返回OK.

([ii])创建gtxn的时候，会为当前事务分配一个事务id，例如"2-30-3296-59dcb546-ffff", 其中id的分区号部分尚未确定，因此为"ffff".

gtid的格式:‘网关id’-‘网关随机值’-‘序列号’-‘时间戳’-‘分区号’，例如 c46535fe-b6-dd-595db6b8-25

[②]事务中的普通sql：

![](https://qqadapt.qpic.cn/txdocpic/0/b1202090b225915b2c6bf64cb05db4b5/0?_type=png&w=1690&h=264)

客户端开启事务之后，即可发起SQL请求访问后端set:

([i])客户端第一条SQL请求可能会访问的一个或多个分区，网关从中随机选择一个分区作为该事务id的分区号部分,例如"2-30-3296-59dcb546-3"，将分区3作为id的分区号部分

([ii])当前事务下，如果客户端第一次访问某个set，例如上面的setx，proxy则会追加一条sql, 即"XA START 'xid'"，用来在setx上开启子事务。

[③]commit:

([i])正常的两阶段提交流程:

([a]) PREPARE阶段

![](https://qqadapt.qpic.cn/txdocpic/0/1c01aba2c5543a8605ad9bbf65672937/0?_type=png&w=1188&h=532)

(1) proxy收到client发送的commit请求时，先向所有的参与者发送"xa prepare 'xid'".

(2) 当所有的参与这都返回成功之后，proxy向gtid_log_t中插入一条记录('xid', 'commit')，标识要提交该事务.

(3) 一旦gtid_log_t写入成功，则向进入COMMIT阶段.

下面是set执行"xa prepare 'xid'"的流程(强同步)：

![](https://qqadapt.qpic.cn/txdocpic/0/5a3f37648d260407a24afb465518aa34/0?_type=png&w=1216&h=505)

(b) COMMIT阶段

![](https://qqadapt.qpic.cn/txdocpic/0/bd9bbc233f4392ae6b454dafca70d853/0?_type=png&w=1044&h=390)

(1) proxy一旦写gtid_log_t成功，就会向所有的参与这发送"xa commit 'xid'"

(2) proxy收到所有参与者的成功响应之后，就会向client返回ok

下面是set处于"xa commit 'xid'"的流程图，和处理"xa prepare 'xid'"的流程类似。

区别：

(1) 写入binlog的事件只包含"xa commit 'xid'"事件.

(2) 事务将被提交，持有的锁将被释放.

![](https://qqadapt.qpic.cn/txdocpic/0/557f1ec204e841cc43d3c325d085560c/0?_type=png&w=1216&h=506)

(ii) 两阶段提交故障

| PREPARE阶段的故障                                        | COMMIT阶段的故障                         |
| --------------------------------------------------- | ----------------------------------- |
| 1．XA PREPARE 'xid'失败: a. 强同步超时 \| b. 锁等待超时(例如ftwrl) | 1. XA COMMIT 'xid'失败2. proxy与db连接失败 |
| 2.写gtid_log_t超时                                     | <br>                                |
| 3.写gtid_log_t失败                                     | <br>                                |
| 4. proxy与db连接断开                                     | <br>                                |

对于PREPARE阶段中的(1),(3)错误，Porxy直接向后端set发送"xa rollback 'xid'"来回滚事务。

对于PREPARE阶段的(2)错误，Proxy将切断proxy与db的连接，由agent负责清理事务。

对于proxy与db连接断开错误，Proxy也将切断Proxy与db的连接，由agent负责清理事务。

下面是agent清理事务的流程：

1. 获取所有处于prepare状态的事务的xid

![](https://qqadapt.qpic.cn/txdocpic/0/013bdbe98fd19b8ef3133a9e8d2499a6/0?_type=png&w=838&h=296)

b.过滤出"一直处于prepare状态"且"持续时间超过阈值"的事务的xid.

c.向gtid_log_t插入('xid', 'abort')记录，其中'xid'为(b)中过滤出的xid,如果gtid_log_t中已经存在'xid'的记录，则此次插入失败.

![](https://qqadapt.qpic.cn/txdocpic/0/76ce39e28f62dfa38d46c92be6f4f8d6/0?_type=png&w=838&h=195)

d. 从gtid_log_t中读取'xid'的状态，如果为'commit'则提交该事务，如果为'abort'则回滚该事务.

![](https://qqadapt.qpic.cn/txdocpic/0/0b45512b1528db61bc95df6e0a9703b8/0?_type=png&w=836&h=469)

由于agent和proxy只能有一个会成功插入gtid_log_t，且agent根据gtid_log_t中xid的状态来决定提交或者回滚事务，因此会不会出现某个事务部分被提交部分被回滚的状态。

[④]死锁故障

(i)单set上的死锁：

![](https://qqadapt.qpic.cn/txdocpic/0/23792a50b0d4464b32cebd077483c343/0?_type=png&w=1336&h=288)

![](https://qqadapt.qpic.cn/txdocpic/0/d8d1203b7054838ab3790ff126f814d1/0?_type=png&w=1044&h=390)

当client1访问某个setx，而setx返回死锁错误，则说明setx上的子事务已经被回滚。

因此Proxy接收到setx的错误之后，就会向当前事务的所有参与者，例如setx和sety，发送"xa rollback 'xid'"将所有的子事务都回滚掉，最后，proxy向client返回死锁错误

(ii) 跨set的分布式死锁

| 客户端1                        | 客户端2                        |
| --------------------------- | --------------------------- |
| begin;                      | begin;                      |
| insert into t(id) value(1); | <br>                        |
| <br>                        | insert into t(id) value(2); |
| …………                        | …………                        |
| insert into t(id) value(2); | <br>                        |
| <br>                        | insert into t(id) value(1); |

假设t的结构为：create table t(id int key) shardkey= id; 并且id=1和id=2的列分布在不同的set上,则上述例子中client1和client2就会产生"分布式死锁"，如果不进行处理，则只能通过set上的锁超时机制来解决,但如果锁超时设置过长就会导致client的长时间等待。

为此proxy增加分布式死锁检测机制，原理如下：

a.proxy将SQL请求发往set之后就会开启计时，一旦收到SQL请求的响应就会取消计时。如果计时超时，则网关向后端各个set发送如下sql:

* "SELECT a.trx_xid, a.trx_mysql_thread_id as thread_id, a.trx_started, a.trx_rows_modified, b.trx_xid as blocking_trx FROM information_schema.innodb_lock_waits as lock_info JOIN information_schema.innodb_trx as a JOIN information_schema.innodb_trx as b ON lock_info.requesting_trx_id = a.trx_id AND lock_info.blocking_trx_id = b.trx_id AND a.trx_xa_type = 'external' and b.trx_xa_type = 'external'"

*

该sql将获取某个set上分布式事务之间的锁等待信息

b.proxy根据(b.1)获取的锁等待信息绘制全局的分布式事务锁等待图，并通过检测出图中的环结构来确定是否发送分布式死锁。然后按照相应的策略从环中挑选出一个事务作为死锁的牺牲者.

c.proxy将断开victim与set的sock连接，并通过kill命令来杀死victim在后端db的session。至此分布式死锁的环结构解开，其它事务可以继续执行.

d.proxy向victim对应的client返回死锁错误.

参考：[网关分布式事务实现](https://docs.qq.com/doc/DWHZjZ1hBbVhscWpp)

## 多源同步原理及相关详细介绍

参考：[多源同步产品文档](https://docs.qq.com/doc/DWER6YWtmek5qWFli)

## 附属文件：
