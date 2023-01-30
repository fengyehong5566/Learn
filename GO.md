# GO

# go语言基础特征：

**go文件名**：go的源文件以 **.go** 结尾，文件名均是小写字母。文件名如有多个部分，可以用下划线“_”进行分隔，如file_test.go。不包含空格和其他特殊字符

每一个go语言应用程序可以包含不同的包，必须有一个名为main的包

属于同一个包的源文件必须全部被一起编译，一个包即是编译时的一个单元，因此根据惯例，每个目录都只包含一个包。

如果对一个包进行更改或重新编译，所有引用了这个包的客户端程序都必须全部重新编译

**编写规则：**

    1、'{' 左打括号必须在代码行的最左边

    2、单行注释使用'//'，多行注释： '/* n...n */'

    

**go程序的一般结构：**

    1、首先使用import导入程序需要的包

    2、定义常量、变量和类型的定义和声明

    3、如果存在init函数，这对该函数进行定义（该函数先于main函数执行）

    4、如果当前包是main包，则定义main函数

    5、定义其余的函数，首先是类型的方法，接着是按照main函数中吸纳后调用的顺序来定义相关函数，如果有很多函数，则可以按照字母顺序来排序

    go程序的执行(程序启动)顺序如下：

        1、 按顺序导入所有被main报引用的其它包，然后再每个包中执行如下流程：

        2、如果该包又导入了其它的包，则从第一步开始递归执行，但是每个包只会被导入一次。  

        3、然后以相反的顺序在每个包中初始化常量和变量，如果该包含有 init 函数的话，则调用该函数。  

        4、在完成这一切之后，main 也执行同样的过程，最后调用 main 函数开始执行程序。

**编译顺序：**

Go 中的包模型采用了显式依赖关系的机制来达到快速编译的目的，编译器会从后缀名为 .o 的对象文件（需要且只需要  这个文件）中提取传递依赖类型的信息。  

如果 A.go 依赖 B.go ，而 B.go 又依赖 C.go ：  

编译 C.go , B.go , 然后是 A.go .  

为了编译 A.go , 编译器读取的是 B.o 而不是 C.o .  

这种机制对于编译大型的项目时可以显著地提升编译速度。

每段代码只会被编译一次。

**可见性规则：**【对象含常量、变量、类型、函数名、结构字段等】

        当对象标识符以大写字母开头，该对象对外部的包是可见的。称为导出

        当对象标识符以小写字母开头，该对象对外部的包是不可见的。

    当导入一个外部包后，只能够访问该包的导出对象

        

# 基础数据类型

​主要四种声明方式：

​ var  声明**变量**

​ const  声明**常量**

​ type  声明**类型**

​ func  声明**函数**

## 基本类型

又称为值类型

| 类型            | 长度    | 默认值   | 说明                        |
| ------------- | ----- | ----- | ------------------------- |
| bool          | 1     | false |                           |
| byte          | 1     | 0     | unit8                     |
| rune          | 4     | 0     | Unicode Code Point, int32 |
| int, uint     | 4 或 8 | 0     | 32 或64                    |
| int8, uint8   | 1     | 0     | -128~127,0~255            |
| int16, uint16 | 2     | 0     | -32768~32767,0~65535      |
| int32，uint32  | 4     | 0     | -21亿~21亿，0~42亿            |
| int64，unit64  | 8     | 0     |                           |
| float32       | 4     | 0.0   |                           |
| float64       | 8     | 0.0   |                           |
| complex64     | 8     |       |                           |
| complex128    | 16    |       |                           |
| uintptr       | 4或8   |       | 足以存储指针的uint32 或uint64整数   |
| array         |       |       | 值类型                       |
| struct        |       |       | 值类型                       |
| string        |       | ""    | UTF-8字符串                  |
| slice         |       | nil   | 引用类型                      |
| map           |       | nil   | 引用类型                      |
| channel       |       | nil   | 引用类型                      |
| interface     |       | nil   | 接口                        |
| function      |       |       | 函数                        |

空指针 的值是nil

## 常量

常量值必须是能够在编译时就能够确定的。

```textile
显示类型定义： const b string = "abc"
隐式类型定义： const b  = "abc"
```

**iota** 可以看做枚举值。【简单的理解，**iota每遇到const关键字，都会重置为0**】

```go
const (
    a = iota   //a=0   
    b = iota   //b=1
    c     //c=2 iota在新的一行被使用时，会自动加1
    d    // d=3
    e = 10 //e =10
    f     // f=10
    g = iota  //g=6
    h     //h=7

)

// 赋值两个常量，iota 只会增长一次，而不会因为使用了两次就增长两次
const (
    Apple, Banana = iota + 1, iota + 2 // Apple=1 Banana=2
    Cherimoya, Durian // Cherimoya=2 Durian=3
    Elderberry, Fig   // Elderberry=3, Fig=4
)
```

## 变量

**变量名定义规则：**

> 1、首字符可以是任意的Unicode字符或下划线
> 
> 2、剩余字符可以是Unicode、下划线、数字
> 
> 3、字符长度不限

**“_”** 又称为空白标识符，接收任何类型的值，但不会保存值

**匿名变量：** 没有名称的变量

**变量的定义：**

```go
语法：  
    var  varName varType
    var  varName varType  = varValue   //声明变量的同事进行赋值，否则为默认值
方法1：
var a int  //一次定义多个int变量： var  a,b,c,d int

方法2：
var (
    a int
    b string
)

方法3：
var a = 15   //go的编译器可以根据变量的值来自动推断期类型，编译时完成。

方法4：
a := 15   //在函数体内声明局部变量时推荐使用
```

**多变量赋值时，先计算所有相关值，然后再从左到右依次赋值。**

**重新赋值与定义新同名变量的区别**

```go
a := "hello"      
a,b := "world",10   //重新赋值: 与前 s 在同⼀一层次的代码块中，且有新的变量被定义
// 上面两个&a的值相同

{
    a, b = "nihao",20   //定义新同名变量: 不在同⼀一层次代码块。&a的值和上面不通
}
```

*

*值类型和引用类型：**

所有像 int、float、bool 和 string 这些基本类型都属于值类型，使用这些**类型的变量**直接指向存在内存中的值

数组、结构体这些复合类型也是值类型

<img src="file:///D:/Program%20Files/marktext/images/2022-05-21-23-45-47-image.png" title="" alt="" width="341">

可以使用形如 &i 的方式获取变量i的内存地址。值类型的变量  的值 存储在栈中。

引用类型：

    一个引用类型的变量 r1  存储的是 r1的值 所在的内存地址(数字)，或内存地址中第一个字节所在的位置。

<img src="file:///D:/Program%20Files/marktext/images/2022-05-21-23-43-59-image.png" title="" alt="" width="594">

```go
a,b = b,a //数值交换
```

引用类型包含slice、map、channel。他们有复杂的内部结构，除了申请内存外，还需初始化相关属性

**new函数：** 计算类型大小，为其分配零值内存，**返回指针**。

**make函数：** 会被编译器翻译成具体的创建函数，由其分配内存和初始化成员结构，**返回对象而非指针**

## 字符串

字符串是**不可变值类型**，内部使用指针指向UTF-8字节数组。

特点：

    默认值为空字符串，即  ""

    可使用索引访问某字节

    不能用序号获取字节元素指针，如&s[i]是非法的

    不可变类型，无法修改字节数组

    字节数组尾部不包含NULL

```go
struct string{
    byte* str;
    intgo  len;
}
```

使用 反引号"" ` "  定义字符串，编译器不做处理，且支持跨行【原样输出】

使用加号 " + " 可连接多行字符串，且加号必须在上行末尾

支持用两个索引号返回子串，子串依然指向原字节数组，仅修改了指针的长度和属性。

**要修改字符串，可先将其转换成[]rune 或者[]byte，修改完成后再转换为string，无论那种转换，都会重新分配内存，并复制字节数组。**

for循环遍历字符串，有byte和rune两种方式

## 指针

    默认值 nil

    操作符  "&" 获取变量地址； 操作符 "*" 透过指针访问目标对象

    不支持指针运算，不支持 "->" 运算符，直接用 "." 访问目标成员

    unsafe.Pointer 可以和任意类型指针间进行转换

```go
func main(){
    x := 0x12345678    
    p := unsafe.Pointer(&x)   //*int -> Pointer
    n := (*[4]byte)(p)     // Pointer  -> *[4]byte

    for i := 0; i < len(n); i++ {
        fmt.Printf("%X",n[i])
    }
}
//输出  78 56 34 12
```

    返回局部变量指针是安全的【会在堆上分配变量内存，但在内联时，也可能直接分配在目标栈】

    将 Pointer 转换成 uintptr， 可变相实现指针运算

```go
func main(){
    d := struct {
        s string
        x int
    }{"abc",100}
    p := uintptr(unsafe.Pointer(&d))  //*struct -> Pointer -> uintptr
    p += unsafe.Offsetof(d.x)  // uintptr + offset
    p2 := unsafe.Pointer(p)  // uintptr -> Pointer
    px := (*int)(p2)    //Pointer -> *int
    *px = 200      // d.x =200
    fmt.Printf("%#v\n",d)
}
//输出：struct{s string; x int}{s:"abc",x:200}
//注意： GC 把 uintptr 当成普通整数对象，它⽆无法阻⽌止 "关联" 对象被回收
```

## Array

```go
//定义且初始化
a := [3]int{1,2,3}  //未初始化元素值为0
b := [...]int{1,2,3,4,5}  //通过初始化值确定数组长度
c := [5]int{2:100, 4:200}  //使用索引号初始化元素


//多维度数组
a := [2][3]int{{1,2,3},{4,5,6}}
b := [...][2]int{{1,2},{3,4},{5,6},{7,8}}  //第2维度不能用 '...'
```

## slice

```go
//底层实现结构
struct slice {
    byte* array；
    uintgo  len；
    uintgo  cap；  
}


//创建1
sliceVar := arrayVar[low:high:max]  // len()= high-low; cap()= max-low
//上面表达式使用的是数组索引号，而非数量


//创建2
s ：= make([]int, 5, 8)  //使用make创建，指定len和cap值，如果省略

s ：= make([]int, 5) //如果省略cap，则cap=len
```

特点：

        引用类型。但自身是结构体，值拷贝传递；

        属性 len 表示可用元素数量，读写操作不能超过该限制；

        属性 cap 表示最大扩张容量，不能超出数组限制；

        如果slice ==nil， 那么len和cap获取的值都是0；

        读写操作实际目标是底层数组；

## init 函数

变量也可以init函数中初始化。它不能够被调用，而是在每个包完成初始化后自动执行，并且执行优先级比main函数高。

每个源文件都只能包含一个 init 函数。初始化总是以单线程执行，并且按照包的依赖关系顺序执行。

一个可能的用途是在开始执行程序之前对数据进行检验或修复，以保证程序状态的正确性。

```go
//init 函数也经常被用在当一个程序开始之前调用后台执行的 goroutine，
//如下面这个例子当中的 backend() ：
func init(){
    go backend()  
}
```

例子

```go
package main
var a string
func main()  {
    a = "G"
    print(a)   //a = 'G'
    f1()
} 
func f1() {
    a := "O"
    print(a)   //a='O'
    f2()
} 
func f2() {
    print(a)   //a='G' 原因在编译阶段已经决定了a的值， f2中&a = main中&a
}
```

# 附录

## 25个关键字：

> **break default func interface select**
> 
> **case defer go map struct**
> 
> **chan else goto package switch**
> 
> **const fallthrough if range type**
> 
> **continue for import return var**

## 37个保留字

> constants：
> 
> ​     **true FALSE iota nil**
> 
> Type：
> 
> ​ **int int8 int16 int32 int64**
> 
> ​ **uint uint8 uint16 uint32 uint64 unitptr**
> 
> ​ **float32 float64 complex64 complex128**
> 
> ​ **bool byte rune string error**
> 
> 内置函数:
> 
> **make len cap new append copy close delete**
> 
> **complex real imag**
> 
> ​ **panic recover**
