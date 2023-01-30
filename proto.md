<center>
<font color=blue size=10>
Protocol Buffer v3 笔记
</font>
</center>

```
syntax = "proto3";  //默认使用proto2， ** 必须 **在第一行声明

message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 page_size = 3;
}
```
**message** 定义需要指定3个字段： 字段类型、名称、唯一的编号
　　**字段类型**：例子中所有字段都是标量类型，page_number和page_size为整数类型，query为字符串类型。也可以使用符合类型，如枚举或消息类型。
　　**编号唯一性**：消息类型中每个字段的编号必须是唯一的，在二进制消息体中将会通过它来识别字段。
　　【【要注意的是，轻易不要改变使用中的消息类型的字段编号。在编码时，在1-15范围内的编号将占一个字节，其中不但包含编号，还有字段类型，而编号在16-2047范围内的字段将占两字节。因此建议把1-15留给使用频率较高的字段，而使用频率较低的字段建议使用15之后的编号。
编号最小值是1，最大值536870911，即2的29次方减1。但要记住，19000-19999之间的数是保留给protocol buffer内部使用，切记我们不要使用。】】

　**特定规则**：字段包括单数与复数两种情况。用repeated关键词修饰，则表明该字段是复数。数据传输时，数组顺序会被保留。在proto3中，repeated修饰的标量字段默认使用packed编码。
　
　**注释语法**：使用  “//” 和  “/\*...\*/”
　**保留字段**：如果我们以删除和注释掉字段的方式更新消息类型，将来其他用户在修改时可能会重新使用该编号。那么可能会因更新延迟导致一些问题，比如数据冲突、产生一些bug。如何解决这个问题？很简单，我们只要不使用那些可能产生问题的编号就好了。protobuf提供了一个保留字语法，可用于保留字段编号或名称，如下：
```
message Foo {
  reserved 2, 15, 9 to 11;
  reserved "foo", "bar";
}
```

#基本类型对照
不同语言与proto的基础类型的对照，如下是官方整理的对照表：

![Alt text](./1600745610973.png)

**默认值**：如果在消息传输时，部分字段未设定具体的值，那么会有相应的默认值。
```
string      默认值是空字符串
bytes       默认值是空字节序列
bool        默认值是false
number      默认值是0
enum        默认值是定义的第一个枚举值，且必须为0
message     默认值依赖具体的语言；
repeated    默认是空，在恰当的语言中，通常是空列表
```
要说明的是，在消息解析时，我们是不能知道字段的值是默认设置还是我们设置的。

#枚举
通过枚举，我们可以定义一个类型，它的值只能在预定义范围内。比如我们可以在前面定义的 SearchRequest 中加入一个类型来指定搜索类型，可能有图片、视频、文章、新闻等。假设枚举类型名为Corpus，定义在Request中。
```
message SearchRequest {
  string query = 1;
  int32 page_number = 2;
  int32 result_per_page = 3;
  enum Corpus {
    UNIVERSAL = 0;
    IMAGES = 1;
    ARTICLE = 2;
    NEWS = 3;
    VIDEO = 4;
  }
  Corpus corpus = 4;
}
```
如你所见，Corpus的第一个值是对应的是0。每个枚举类型的第一个值都必须是0，理由是

数值型的默认值为0
为了兼容proto2语法
如果设置allow_alias = true，我们就可以为相同的值定义不同的名称。默认情况下，如此定义编译器会报错。
```
enum EnumAllowingAlias {
  option allow_alias = true;
  UNKNOWN = 0;
  STARTED = 1;
  RUNNING = 1;
}
enum EnumNotAllowingAlias {
  UNKNOWN = 0;
  STARTED = 1;
  // RUNNING = 1;  // 注释掉这行，否则编译器会报警
}
```
枚举值是32位整数且采用可变长编码，因此使用负数会存在效率低下的问题，是不被推荐的。枚举类型可以定义在message内部，也可以定义在外部。我们重复使用定义的类型，如果在message内部定义，使用类似 MessageType.EnumType 的语法。

枚举类型在Java和C++中使用enum，在Python在通过一个特殊类EnumDescriptor实现。在反序列化时，可能会遇到一些无法识别的值。原因是部分语言的枚举限制并不是那么严格，可以指定非限制范围内的值。

#特点
对比常见的XML、Json数据存储格式，Protocol Buffer有什么特点
![Alt text](./1600746085383.png)
**应用场景**：
传输数据量大 & 网络环境不稳定 的 **数据存储、RPC 数据交换** 的需求场景

#数据存储方式（T - L -V）
定义：即 **Tag - Length  - Value **
作用：以 **标识 - 长度 - 字段值** 表示单个数据，最终将所有数据拼接成一个**字节流**，从而实现 数据存储 的功能
>　　其中 Length可选存储，如 储存Varint编码数据就不需要存储Length 
示意图：
![Alt text](./1600746683213.png)
优点：
从上图可知，T - L - V 存储方式的优点是：
　　不需要分隔符 就能 分隔开字段，减少了 分隔符 的使用
　　各字段 存储得非常紧凑，存储空间利用率非常高
　　若 字段没有被设置字段值，那么该字段在序列化时的数据中是完全不存在的，即不需要编码


#Protocol Buffer 语法
![Alt text](./1600754813346.png)

```
package protocobuff_Demo;
// 关注1：包名

option java_package = "com.carson.proto";
option java_outer_classname = "Demo";
// 关注2：option选项

// 关注3：消息模型
// 下面详细说明
// 生成 Person 消息对象（包含多个字段，下面详细说明）
message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    required string number = 1;
    optional PhoneType type = 2 [default = HOME];
  }

  repeated PhoneNumber phone = 4;
}

message AddressBook {
  repeated Person person = 1;
}
```
**代码解析**：
1、包名
```
package protocobuff_Demo;
// 关注1：包名
```
**作用**：防止不同 **.proto** 项目命名冲突
**解析过程**：
　　1、Prococol buffer的类型名称解析：从最内部开始查找，依次向外进行
	　　　　每个包会被 看作是其父类包的内部类
	　2、Protocol buffer编译器会解析**.proto**文件中定义的所有类型名
	　3、生成器会根据不同语言生成对应语言的代码文件
	　　　　即对 不同语言 使用了不同的规则进行处理

2、Option选项
```
option java_package = "com.carson.proto";
option java_outer_classname = "Demo";
// 关注2：option选项
```
**作用**：影响特定环境下的处理方式
　　不改变整个文件声明的含义
**常用Option选项**：
```
option java_package = "com.carson.proto";
// 定义：Java包名
// 作用：指定生成的类应该放在什么Java包名下
// 注：如不显式指定，默认包名为：按照应用名称倒序方式进行排序

option java_outer_classname = "Demo";
// 定义：类名
// 作用：生成对应.java 文件的类名（不能跟下面message的类名相同）
// 注：如不显式指定，则默认为把.proto文件名转换为首字母大写来生成
// 如.proto文件名="my_proto.proto"，默认情况下，将使用 "MyProto" 做为类名

option optimize_for = ***;
// 作用：影响 C++  & java 代码的生成
// ***参数如下：
// 1. SPEED (默认):：protocol buffer编译器将通过在消息类型上执行序列化、语法分析及其他通用的操作。（最优方式）
// 2. CODE_SIZE:：编译器将会产生最少量的类，通过共享或基于反射的代码来实现序列化、语法分析及各种其它操作。
  // 特点：采用该方式产生的代码将比SPEED要少很多， 但是效率较低；
  // 使用场景：常用在 包含大量.proto文件 但 不追求效率 的应用中。
//3.  LITE_RUNTIME:：编译器依赖于运行时 核心类库 来生成代码（即采用libprotobuf-lite 替代libprotobuf）。
  // 特点：这种核心类库要比全类库小得多（忽略了 一些描述符及反射 ）；编译器采用该模式产生的方法实现与SPEED模式不相上下，产生的类通过实现 MessageLite接口，但它仅仅是Messager接口的一个子集。
  // 应用场景：移动手机平台应用

option cc_generic_services = false;
option java_generic_services = false;
option py_generic_services = false;
// 作用：定义在C++、java、python中，protocol buffer编译器是否应该 基于服务定义 产生 抽象服务代码（2.3.0版本前该值默认 = true）
// 自2.3.0版本以来，官方认为通过提供 代码生成器插件 来对 RPC实现 更可取，而不是依赖于“抽象”服务

optional repeated int32 samples = 4 [packed=true];
// 如果该选项在一个整型基本类型上被设置为真，则采用更紧凑的编码方式（不会对数值造成损失）
// 在2.3.0版本前，解析器将会忽略 非期望的包装值。因此，它不可能在 不破坏现有框架的兼容性上 而 改变压缩格式。
// 在2.3.0之后，这种改变将是安全的，解析器能够接受上述两种格式。

optional int32 old_field = 6 [deprecated=true];
// 作用：判断该字段是否已经被弃用
// 作用同 在java中的注解@Deprecated
```
在 ProtocolBuffers 中允许 自定义选项 并 使用
该功能属于高级特性，有兴趣可查看官方文档

3、消息模型
**作用**：真正用于描述 数据结构
```
// 消息对象用message修饰
message Person {

  required string name = 1;
  required int32 id = 2;
  optional string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    optional PhoneType type = 2 [default = HOME];
  }

  repeated PhoneNumber phone = 4;
}

message AddressBook {
  repeated Person person = 1;
}
```
**组成**：在 Protocol Buffer中：
　　1、一个 **".proto"** 消息模型  **= **  一个**".proto"** 文件  **=** 消息对象 + 字段
　　2、一个消息对象（Message） = 一个  结构化数据
　　3、消息对象（Message）里的 字段 = 结构化数据里的成员变量

#消息对象&&字段
![Alt text](./1600755975928.png)
**消息对象**：
在 Protocol Buffer中：
　　一个消息对象（Message） = 一个 结构化数据
　　消息对象用  修饰符message 修饰
　　消息对象含有 字段:  消息对象（Message）里的  字段=结构化数据里的成员变量
![Alt text](./1600756193380.png)

a、尽可能将与 某一消息类型 对应的响应消息格式 定义到相同的 **.proto** 文件中
b、一个消息对象 里 可以定义另一个消息对象（即嵌套）

**字段：**
消息对象的字段 组成主要是： **字段 = 字段修饰符  + 字段类型  + 字段名  +  标识号**
![Alt text](./1600756438778.png)
**a、字段修饰符：**
**作用：** 设置该字段解析时的规则
具体类型如下：
![Alt text](./1600756529710.png)

**b、字段类型：**
　　基本数据  类型
　　枚举 类型
　　消息对象  类型
　　











#扩展：
###网络通信协议
1）序列化 & 反序列化 属于通讯协议的一部分
2）通讯协议采用分层模型：TCP/IP模型（四层） & OSI 模型 （七层）
![Alt text](./1600746358662.png)
序列化 / 反序列化 属于 TCP/IP模型 应用层 和 OSI`模型 展示层的主要功能：
　　1、（序列化）把 应用层的对象 转换成 二进制串
　　2、（反序列化）把 二进制串 转换成 应用层的对象
所以， Protocol Buffer属于 TCP/IP模型的应用层 & OSI模型的展示层

