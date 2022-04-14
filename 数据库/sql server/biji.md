#                                    T-sql
# T-sql语句分类
  DDL：数据定义语句
    create、alter、drop
  DML：数据操作语句
    select、insert、update、delete
  DCL：数据控制语句
    grant、revoke(收回权限，不禁止冲其他角色继承权限)、deny(和revoke相似，但其禁止从其他角色继承权限)

# 数据类型
  整数类型：
    int、smallint、tinyint、bigint、
  浮点数类型：
    real、float、decimal、
  字符类型：
    char
    varchar
    nchar
    nvarchar
  日期和时间类型
    date
    time
    datetime
    datetime2
    smalldatetime
  文本和图形数据类型
    text
    ntext
    image
  货币数据类型
    money
    smallmoney
  位数据类型：
    bit(值为0或1)
  二进制数据类型
    binary
    varbinary
  其他数据类型：
    rowversion
    timestamp
    uniqueidentifier
    cursor
    sql_variant
  自定义用户数据类型：
    语法
    ```
    sp_addtype [@typename=] type,
    [@phystype=] system_dat_type
    [,[@nulltype=]'null_type']
    [,[@owner=]'owner_name']
    ```
    参数解释:
      [@typename=]type 创建自定义类型的名称.
      [@phystype=] system_data_type: 该类型所依附的基本数据类型。
      [@nulltype=]'null_type': 指定该数据类型的空属性，其值可为 null、no null、 nonull
      
      
# 变量
## 常规标识符
    以 **字母、下划线（_）、@或#** 开头，后跟 **字母、下划线（_）、$、@或#**。【不能全是下划线、@、#】
    
## 局部变量定义：  
    ```
    declare  {@varname  var_type} [,...]
    ```
    
    局部变量注意：
      1、局部变量可以为除 text、ntext、image类型外的任何数据类型
      2、局部变量声明后均初始化为NULL，可以使用select、set进行赋值

    局部变量赋值：
    ```
    set  @varname=expression
    select {@varname=expression} [,...]
    ```
    注意：
      1、select语句返回多个值时，最后一个值赋给变量
      2、expression无返回值，则变量设为NULL
      3、一个select语句可以初始化多个局部变量
      
      
  局部变量显示：
    两种方法：
      ```
      print  @varname
      select  varname
      ```
     区别：
       print：显示结果再消息中，无结果
       select：显示结果中为表格样式，消息中显示受影响的行数

## 全局变量
  全局变量由 **系统提供且预先声明**，是sql server系统内部使用的变量。**用户不能创建声明全局变量，只能使用预定义的全局变量，也不能使用set语句修改全局变量值。**
  查看全局变量：
  ```
  select @@Variable
  ```
  
  常用全局变量：
  >@@CONNECTIONS —— 打印本次sql server启动以来连接或试图连接的次数
  >@@ERROR —— 打印最后执行sql语句的错误代码
  >@@ROWCOUNT —— 打印上一次语句影响的数据行的行数
  >@@SERVERNAME —— 打印sql server的本地服务器的名称
  >@@VERSION —— 返回sql server当前安装的日期、版本和处理器类型
  >@@LANGUAGE —— 返回当前sqlserver服务器的语言

## 注释符
  1、--：(双连字符) 单行注释
  2、/*...*/：多行注释

## 运算符
  算术运算符
    +(加)、-(减)、*(乘)、/(除)、%(模)
    注：
      加 和  减 运算符也可用于 datetime和 smalldatetime值的运算
      
  赋值运算符
    =(等号)
    
  位运算符
    &(与——AND)
    |(或——OR)
    ^(非)
    
  比较运算符
    =(等于)
    <>(不等于)
    >(大于)
    <(小于)
    >=(大于等于)
    <=(小于等于)
    
    注：
      1、比较运算符结果有布尔数据类型，它有3种值：TRUE、FALSE、UNKNOWN
      2、不能将布尔数据类型指定为表列或变量的数据类型，也不能再结果集中返回布尔数据类型
      3、当 set ANSI_NULLS 为on时，带有一个或2个NULL的表达式，将返回UNKONWN
         当 set ANSI_NULLS 为off是，上述规则同样适用，只不过如果两个表达式都为NULL，那么等号运算符将返回TRUE
         例如：
         ```
         set  ANSI_NULLS OFF
         NULL =NULL  //将返回TURE
         ```
         
  字符串串联运算符
  +(加号)
  
  字符串串联运算符允许通过加号(+)进行字符串串联，这个加号也被称为字符串串联运
算符。其他所有的字符串操作都可以通过字符串函数(例如 SUBSTRING 进行处理。

   逻辑运算：
     not
     and
  一元运算符
  +(正)：数值为正
  -(负)：数值为负
  ~(按位NOT)：返回数字的补数

  运算符优先级：
  一元运算  >  乘除模  >  加减串联  >  比较运算  >  位运算  >  逻辑非  >  逻辑与  >  逻辑或等(ALL > ANY > BETWEEN > IN > LIKE > OR > SOME)  >  赋值

## 通配符
  %(百分号)：零个或多个任意字符
  _ (下划线)：单个任意字符
  []：指定范围内的任意字符
  [^]：指定范围外的任意字符

# 流程控制
  流程控制关键字：
    BEGIN ... END：定义语句块
    BREAK：退出内层的while循环
    CONTINUE：继续执行下一轮循环
    GOTO label：调到label定义处，开始往后执行
    IF ... ELSE：条件判断
    RETURN：无条件退出
    WAITFOR：为语句的执行设置延迟
    WHILE：条件为true是重复执行语句块

  ## case语句
    case有2种语法：
    第一种：
      ```
      case <input_expression>
      when <when_expression>  then <result_expression>
      ...
      when <when_expression>  then <result_expression>
      [else  <else_result_expression>]
      ```
      执行顺序：
        1、先计算 input_expression的值
        2、按顺序对每个when子句执行 input_expression=when_expression的比较，如果返回为TRUE，则返回result_expression,如果
           所有when都返回false，则返回else下的else_result_expression。如果没有指定else子句，则返回NULL。
    
    第二种：
      ```
      case
      when <条件表达式> then <运算式>
      ...
      when <条件表达式> then <运算式>
      [else <运算式>]
      ```
    
  ## while循环语句
  语法：
  ```
  while boolean_expression
  [BEGIN]
    {sql_statement | statement_block}
  [END]
  ```  
  
  # return语句
  ```
  return [整数值]
  ```
  注：
    如果用户定义了返回值，就返回用户定义的值。如果没有指定返回值， SQLServer 系统会
  根据程序执行的结果返回一个内定值，如下所示。如果运行过程产生了多个
  错误，SQL Server系统将返回绝对值最大的数值，RETURN 语句不能返回 NULL 值。
  
  系统返回内定值：
    0：程序执行成功
    -1：找不到对象
    -2：数据类型错误
    -3：死锁
    -4：违反权限原则
    -5：语法错误
    -6：用户造成的一般错误
    -7：资源错误，如：磁盘空间不足
    -8：非致命的内部错误
    -9：已达到的系统的极限
    -10、-11：致命的内部不一致错误
    -12：表或指针破坏
    -13：数据库破坏
    -14：硬件错误

  ## goto跳转语句
    GOTO 命令用来改变程序执行的流程 使程序跳到标有标识符的指定的程序行再继续往下执行。
    例子：
    ```
    declare @x int
    select @x =1
    label:
    print @x
    select @x=@x+1
    wheile @x<6
    goto label
    ```

# 常用命令
  declare：
  print：
    注：
      1、print 打印返回字符串的表达式时，最长可达8000个字符，超过会被截断
      2、若要打印用户定义的错误信息(该消息用包含可由@@ERROR返回的错误号)，请使用raiserror，不要使用print
  backup：
    备份数据库
  restore
    还原数据库
















    
