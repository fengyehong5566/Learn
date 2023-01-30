# 基础知识

**注释：**

    #   单行注释

    多行注释：三个单引号和双引号    

**规范化：**

    缩进：使用空格进行缩进

    代码注释：多谢注释

    空格使用：操作符，逗号   后加空格，函数、类、功能代码，空出一行

**命名：**

    模块：自己写的模块，文件名全部小写，长名字单词以下划线分隔

    类：驼峰命名。

    函数：首单词小写，其余单词首字母大写

    变量：都小写，单词以下划线分隔

**编码：**

    ASCII：美国信息交换标准码

    Unicode：万国码

    GB2312：中国国家标准总局发布处理汉字的标准编码

    GBK： GB2312 的扩展，向下兼容 GB2312

    UTF-8：针对 Unicode 的可变长度字符编码

    **decode()** 函数作用是将其他编码的字符串解码成 Unicode

    **encode()** 函数作用是将 Unicode 字符串编码变成能正常显示的编码

    

**\_\_name\_\_属性 :** 

    每个模块都有该属性，该属性的值就是模块名。

    如果执行运行python程序，该属性的值将是 '\_\_main\_\_' 

**help() 函数：** 

    help()就能查看模块的内部构造，包括类方法、属性等信息。

**dir() 函数：**

    dir()函数查看对象属性

# 数据类型

## 字符串

```python
HW =  "Hello World!"

len(HW)  # 字符串长度        
HW.capitalize()  # 首字母大写        
HW.count('l')  # 字符 l 出现次数       
HW.endswith('!')  # 感叹号是否结尾       
HW.startswith('w')  # w 字符是否是开头      
HW.find('w') # HW.index('W')  # w 字符索引位置       
Hello{0} world!".format(',')  # 格式化字符串:        
HW.islower()  # 是否都是小写       
HW.isupper()  # 是否都是大写       
HW.lower()  # 所有字母转为小写      
HW.upper()  # 所有字母转为大写      
HW.replace('!','.')  # 感叹号替换为句号      
HW.split(' ')  # 以空格分隔切分成列表     
HW.splitlines()  # 转换为一个列表       
HW.strip()  # 去除两边空格       
HW.swapcase()  # 大小写互换        
HW[0:5]  # 只要 Hello 字符串      
HW[0:-1]  # 去掉倒数第一个字符
```

## 列表：

```python
print = 123
multi_list =  ["Alice", 175, [80, 90, 70], print]  

1.可迭代
for item in muli_list:
    print(item)

2.列表的常见操作
second_item = multi_list[1]
multi_list[1]  #查看
multi_list[1] =165    #修改

multi_list.append()        #追加一个元素
multi_list.count('A')    #统计列表中A字符出现的次数

multi_list.index('A')    #查找元素A的索引位置
multi_list.insert(3,'A')     #在第3个索引位置，插入元素A

multi_list.pop()  #删除最后一个元素
multi_list.pop(3)  #删除第3个下标元素
multi_list.remove(5)  #删除元素是5，如果没有会返回错误

multi_list.reverse()   #倒序排列元素
multi_list.sort()   #正序排列元素

a = [1, 2, 3]
b = ['a', 'b', 'c', 'd']
a + b 
a.extend(b) #将一个列表作为元素添加到a列表中)   #正序排列元素


3.切片
multi_list =  ["Alice", 175, [80, 90, 70], print]  

multi_list[0]   # 返回第一个元素
multi_list[-1]   #返回倒数第一个元素
multi_list[0:-1]   # 获取非倒数第一个元素之外的元素
multi_list[0:4]   # 返回第一个至第四个元素
multi_list[::2]   # 步长切片


4.清空列表
方法1：multi_list = []
方法2：del multi_list = [:]
方法3：del multi_list    #删除列表变量

del multi_list[0:4]  #删除下标为0,1,2,3的元素
```

```python
reversed()  #函数倒序排序
sorted()  #函数正序排序

range() #序列生成器，生产一个列表

range(stop)
range(start, stop[, step])  #return: list of intergers
```

enumrate() ：返回可迭代数据的索引和值

```python
for index, value in enumerate(multi_list):
    print("index" —— "valuse")
```

## 元组

元组和列表类似，区别在于元组的元素不能修改

```python
# 元组定义
multi_tuple = ("Alice", 175, [80, 90, 70])

1.可迭代
for i in multi_tuple:
    print(i)


2.元组常见操作
second_item = multi_tuple[1]
#元组只支持查询，不支持删除、新增、修改，可以理解为只读列表
```

## 字典

字典是一个无序的  键值对集合，字典中的键必须互不相同

```python
pople_dict = {"name": "Alice", "height": 175, "score":[80,90,100]}


# 字典常见操作
name = people_dict["name"]

pople_dist['e'] = 4  # 添加键值
pople_dist.items()  # 获取所有键值
pople_dist.keys()  # 获取所有键

pople_dist.values()  # 获取所有值
pople_dist['a']  # 获取单个键的值,如果这个键不存在就会抛出 KeyError 错误
pople_dist.get('a','no')  # 获取单个键的值，如果不存在则返回自定义的值 no

pople_dist.popitem() # 删除第一个键值
pople_dist.pop('b')  # 删除指定键

d2 = {'a':1}
pople_dist.update(d2)  # 添加其他字典键值到本字典

dd = pople_dist.copy()  # 拷贝为一个新字典
pople_dist.has_key('a')  # 判断键是否在字典

# 如果字典中有 key 则返回 value，否则添加 key，默认值 None
pople_dist.setdefault('a')
pople_dist.setdefault('b', 2)

for k, v in people_dict.items():
    print(k,v)
```

字典迭代器：

    dist.items()  #获取所有键值

    dist.iterkeys()  #获取所有键

    dist.itervalues()  #获取所有值

## 集合

集合中的数据是无序、不重复的。主要功能用于删除重复元素和关系测试。

```python
# 集合定义
num_set = {1,3,4,5,6,6,6,6,6}  #输出{1, 3, 4, 5, 6}

multi_set.add('a')   #添加元素
multi_set.update('123') #把传入的元素拆分为个体传入到集合中，与set('1234')效果一样
multi_set.remove('4')   #删除元素，没有会报错
multi_set.discard('4')   #删除元素，没有也不会报错
multi_set.pop()   #删除第一个元素
multi_set.clear()   #清空集合

num_list = [1,3,4,5,6,6,6,6,6]
num_set = set(num_list)   #列表转换为集合，会去除重复的数据
num1_list =list(num_set)  #集合转换为列表
```

## 额外的数据类型：

    collections 包在内置数据类型基础上，又增加了几个额外的功能，替代内建的字典、列表、集  合、元组及其他数据类型。

   **namedtuple()**：函数功能是使用名字来访问元组元素

```python
from collections  import namedtuple   #只导入namedtuple方法
nt = namedtuple("point",['a', 'b', 'c'])
p = nt(1,2,3)

p.a   #输出1
p.b   #输出2
p.c   #输出3
```

namedtuple 函数规定了 tuple 元素的个数，并定义的名字个数与其对应。

**deque() 函数** 作用就是为了快速实现插入和删除元素的双向列表

```python
from collections import deque
q = deque(['a', 'b', 'c'])
q.append('d')
a.appendleft(0)  #在列表最前面插入元素
q.pop() #删除最后一个元素
q.popleft()  #删除第一个元素
```

**Counter()函数：** 计数器，用来计数

```python
from collections import Counter
c = Counter()
for i in "Hello world":
    c[i] += 1
```

结果是以字典的形式存储，实际 Counter 是 dict 的一个子类。

**OrderedDict() 函数：** 功能就是生成有序的字典

```python
d = {"a":1, "b":2, "c":3}   #d是无序的


from collections  import OrderedDict
od = OrderedDict()
od['a'] = 1
od['b'] = 2
od['c'] = 3   # od是有序的字典


import json
json.dumps(od)  # 输出字典的形式
```

OrderedDict 输出的结果是列表，元组为元素，如果想返回字典格式，可以通过 json 模块进行转化。

# 控制流

## 操作符

    and操作符判断表达式：如果a 和 b 都为真，返回b的值，否则返回 a 的值

    or 操作符判断表达式：如果a 和 b 都为真，返回a的值，否则返回 b 的值

    全为and时，返回最后一个值

    全为or时，返回第一个值

    

    python中，空数组、None、False、0、"" 都为false

## IF

```python
age = int(input("请输入您的年龄："))   #int() 强制变为int
if age >= 60:
    print("老年人")
elif age >= 30:
    print("中年人")
elif age >=18:
    print("成年人")
elif age >=16:
    pass
else:
    print("未成年人")
```

pass语句作用是不执行当前代码块，和shell里的冒号作用一样

## while

```python
flag = 0 
while flag < 10:
    print(flag)
    flag = flag + 1 
```

## for

```python
for i in range(10):
    print(i)


result = (x for x in range(5))  #使用小括号会生产一个生成器
result = [x for x in range(5)]  #列表解析表达式
```

## break、continue、pass

**break**：跳出所有循环

**continue**：跳出当前循环，进入下一次循环

**pass**：空语句，是为了保持结构的完整性

## else语句

else 不光可以与if搭配，也可以与for、while搭配

```python
count = 0
while count < 5:
    print count
    count += 1
else:
    print "end"
```

# 函数

语法：

```python
#定义无参函数
def functionName():
    code block
    return expression

#定义带参函数
def functionName(parms1, parms2, ...):
    code block
    return expression

#定义任意数量参数
def functionName(*args):  #参数会存储为一个元组
    code block
    return expression

def functionName(**kwargs):  #参数会存储为一个字典
    code block
    return expression
```

**作用域：** 即一个变量 或 代码段可以使用的范围，

作用域的范围：全局（global）   >   局部（local） >  内置（build-in）

## 嵌套函数

```python
def func():
    x = 2
    def  func2():
        return x
    return func2   #返回func2 函数

func()()  #调用
```

内层函数可以访问外层函数的作用域。内嵌函数只能被外层函数调用，但也可以使用 global 声明全局作用域

内层函数可以访问外层函数的作用域。但变量不能重新赋值

## 闭包

指的是一个拥有许多变量和绑定了这些变量的环境的表达式 （通常是一个函数），因而这些变量也是该表达式的一部分。

```python
def func(a):
    def func2(b):
        return a * b
    return func2
f=func(2)   #变量指向函数
f(5)  #返回10
```

func 是一个函数，里面又嵌套了一个函数 func2，外部函数传过来的 a 参数，这个变量会绑定到函  数 func2。 func 函数以内层函数 func2 作为返回值，然后把 func 函数存储到 f 变量中。当外层函数  调用内层函数时，内层函数才会执行（func()()），就创建了一个闭包。

## 推导式

```python
# 列表推导式：
good_list1 = [100, 200, 400, 800]
good_list2 = [28, 188, 888, 981]
f_list = [i1+i2 for i1,i2 in zip(good_list1,good_list2) if i1 +i2 >1000]

# 字典推导式：
letter_dict = {"A":1, "B":2, "C":3}
letter_dict1 = {v:k for k,v in letter_dict.items()}

# 集合推导式：

num_list = {i for i in range(1, 101) if i%2==1}
```

## 高阶函数

高阶函数是至少满足这两个条件的任意一个条件

    1、能接受一个或多个函数所谓输入

    2、输出一个函数

## 装饰器

```python
# 普通装饰器
def  decorate(func):
    print("decorate is running")
    def inner():
        print("inner is running")
    #返回的函数备替换了
    return inner
```

## 匿名函数

```python
f = lambda: a, b : a * b   #冒号左边是函数参数，右边是返回值
```

# 类

类是对一类具有共同特征的对象的抽象描述，对象是类的实体。类也是一种数据类型

> **对象 = 属性  + 方法**

属性：变量，方法：函数

**定义：**

```python
#类定义
class  ClassName（）：
    pass

#类中的方法
def funcName（self）：   #self代表类本身，类中所有函数的第一个参数必须是self。
    pass
```

**类方法调用：**

    1、类方法之间调用：self.<方法名>（参数），  参数不需要加self

    2、外部调用：<实例名>.<方法名>

## 类说明文档

```python
class MyClass:

"""
this is doc
"""
pass


#查看类帮助文档
print MyClass.__doc__
help(MyClass)
```

## 类内置方法

```python
# 初始化一个实例时，先调用__new__() 函数，再调用__init()__ 函数

__new__(cls, *args, **kwd)  # 实例的生成操作，在__init__(self)之前调用
__init__(self, ...)  # 初始化对象，在创建新对象时调用
__del__(self)        # 释放对象，在对象被删除之前调用


__str__(self)  # 在使用 print 语句时被调用，返回一个字符串
__getitem__(self, key)  # 获取序列的索引 key 对应的值，等价于 seq[key]

__len__(self)  # 在调用内建函数 len()时被调用
__cmp__(str, dst)  # 比较两个对象 src 和 dst 

__getattr__(s, name)  # 获取属性的值
__setattr__(s, name, value) # 设置属性的值
__delattr__(s, name)  # 删除属性 

__gt__(self, other)  # 判断 self 对象是否大于 other 对象
__lt__(self, other)  # 判断 self 对象是否小于 other 对象
__ge__(self, other)  # 判断 self 对象是否大于或等于 other 对象
__le__(self, other)  # 判断 self 对象是否小于或等于 other 对象
__eq__(self, other)  # 判断 self 对象是否等于 other 对象

__call__(self, *args)  # 把实例对象作为函数调用
```

## 类传参

```python
#!/usr/bin/python
#-*- coding:utf-8 -*-
class MyClass():
    def __init__(self,name):
        self.name = name

    def func(self, age):
        retrun "name: %s, age: %s" %(self.name,age)
mc = MyClass("xiaoming")  #第一个参数是默认定义好的，传入__init__()函数
print mc.func("22")
```

## 类私有化

**单下划线开头：** 实现模块级别的私有化，以单下划线开头的变量和函数只能类或子类才能访问。  当from modulename import * 时，将不会引入以单下划线开头的变量和函数

**双下划线开头：** 以双下划线开头的变量，表示私有变量，受保护的，只能类本身能访问，连子类也不能访问。避免子类与父类同名属性冲突

**首尾双下划线：** 一般保存催下的元数据.  

    dic(MyClass) 返回对象内变量、方法，不带参数时，返回当前范围内的变量、方法列表

## 继承

    子类将继承父类的所有方法和属性

    如果子类重写了构造函数，父类的构造函数将不会执行。需要显示的执行父类的构造函数

```python
#!/usr/bin/python
# -*- coding:utf-8 -*-
class Parent():
    def __init__(self):
        self.name_a = "xiaoming"
    def funcA(self):
        return "function A: is %s"% self.name_a


clase Child(Parent):
    def __init__(self):
        #Parent.__init__(self)   # 手动执行父类构造函数

        #使用super函数调用父类构造函数,只能拥有新式类 
        super(Child, self).__init__()
        self.name_b = "lisi"
    def funcB(self):
        return "function B: %s"% self.name_b
```

**多重继承：** 每个类可以拥有多个父类，如果调用的属性或方法在子类中没有，就会从父类中查找。多重继承  中，是依次按顺序执行。

> 注：
> 
>     经典类：默认没有父类，也就没有继承类。
> 
>     新式类：有继承的类，如果没有，可以继承object。在python3 中已经默认继承object类
> 
>     经典类在多重继承时，采用从左到右深度优先原则匹配，而新式类是采用 C3 算法（不同于广度优 先）进行匹配。两者主要区别在于遍历父类算法不同

**方法重载：** 直接在子类中定义和父类同名的方法。子类就修改了父类的动作

```python
# 四个可以对类对象增删改查的内建函数
getattr()  #返回一个对象属性或方法。
hasattr()  #判断一个对象是否具有属性或方法。返回一个布尔值。
setattr()   #给对象属性重新赋值或添加。如果属性不存在则添加，否则重新赋值。
delattr()   #删除对象属性
```

# 异常处理

语法：

```python
try:
    expression
except  [Except Type]:
    expression
else:   # try中的代码没有引发异常，则会执行else
    pass
finally:  # 无论是否异常，都会执行finally
    pass

#常见的异常类型：

try：
    expression
except ExceptionType, ERR:  #将错误信息保存到ERR变量
# except ExceptionType as ERR:  #将错误信息保存到ERR变量
    print ERR
```

## 自定义异常

**raise** 语句用来手动抛出一个异常：

> raise  excetpType(ExceptInfo)

raise 参数必须是一个异常的实例或Exception子类

## 断言语句

**assert**  语句用于检查条件表达式是否为真，不为真则触发异常。

```python
assert 1 == 1
assert 1 != 1   #则会引发AssertionError异常 


assert 1 != 1, "assert description"  #添加异常描述信息
```

# python 可迭代对象、迭代器、生成器

## 可迭代对象

```python
# 可迭代对象：只要实现了__iter__方法的对象就是可以迭代的
# __iter__ 方法会返回迭代器本身 

list = [1, 2, 3]
lst.__iter__()


#判断对象是否是可迭代对象
from  collections  import Iterable  # 只导入Iterable方法
isinstance('abc',Iterable)  #True
isinstance(1, Iterable)  #False
```

## 迭代器

    有 **next** 方法的对象都是迭代器。在调用 next 方法时，迭代器会返回它的下一个值。

    如果 next 方法被调用，但迭代器没有值可以返回，就会引发一个 StopIteration 异常。

```python
d = {'a':1, 'b':2, 'c':3}


#判断是否是迭代器
from collections  import Itertor
isinstance(d, Itertor)  #False
isinstance(d.iteritems, Itertor)  #True


iter_items = d.iteritems()
iter_items.next()
```

**iter() 函数** 转换成迭代器

```python
# 语法
iter(collection)  ——>  iterator
iter(collable, sentinel)  ——>  iterator


# 1. 例子
lst= [1, 2, 3]
isinstance(lst, itertor)  # False

#装换成迭代器
iter_lst = iter(lst)
isinstance(iter_lst, itertor)  # True
```

**itertools模块**  

    itertools 模块是python 内建模块，提供可操作性迭代对象的函数。可生产迭代器、无限的序列迭代器

**方法：**

```python
from itertools import *   # 导入所有方法
# count()  生成序列迭代器
# count(start = 0, step = 1)  ——> count object
counter = count()
counter.next()

# cycle() 用可迭代对象 生产 迭代器
# cycle(iterable) ——> cycle object
i = cycle(['a', 'b', 'c'])
i.next()

# repeat() 用对象生产迭代器
# repeat(object [, times]) ——>  创建一个任意对象的迭代器
i = repeat(1)
i.next() # 1
i.next() # 1
......    # 可以迭代任意次数

i = repeat(1, 2)  #知道times 次数
i.next() # 1
i.next() # 1
i.next() # 报错

# chain() 用多个可迭代对象生产迭代器
# chain(*iterables)  ——> chain object
i = chain("a", "b", "c")
i.next()  #a

#groupby() 将可迭代对象中重复的元素挑出来放到一个迭代器中
#groupby(iterable [, keyfunc]) ——> create an iterator which returns
for key, group in groupby('abccddDdcad')
    print key,list(group)
# groupby() 区分大小写，可以把大小写都放到一个迭代器中
for key, group in groupby('abccddDdcad', lambda c: c.upper())
    print key, list(group)

# imap() 处理多个可迭代对象
# imap(func, *iterable) ——> imap object
a = imap(lambda x, y: x * y, [1, 2, 3], [4, 5, 6])
a.next() 


# ifilter() 过滤序列
# ifilter(function or None，sequence)  ——> ifilter object
ii = ifilter(lambda x: x % 2 == 0, [1, 2, 3, 4, 5])
for i in ii:
    print i
```

当使用 for 语句遍历迭代器时，步骤大致这样的：

    先调用迭代器对象的__iter__方法获取迭代器对象

    再调用对象的__next__()方法获取下一个元素

    最后引发 StopIteration 异常结束循环

## 生成器

生成器：

    1、任何包含yield 语句的函数都称为 **生成器**

    2、生成器都是迭代器，但迭代器不一定是生成器

    在函数定义中使用 yield 语句就创建了一个生成器函数，而不是普通的函数。  
    当调用生成器函数时，每次执行到 yield 语句，生成器的状态将被冻结起来，并将结果返回__next__调用者。冻结意思是局部的状态都会被保存起来，包括局部变量绑定、指令指针。确保下一次调用时能从上一次的状态继续。

```python
def fab(max)
    n, a, b = 0, 0, 1
    while n < max:
        print b
        a, b = b, a+b
        n += 1
fab(5)

# 上面的语句可以优化成
def fab(max)
    n, a, b = 0, 0, 1
    while n < max:
        yield b
        a, b = b, a+b
        n += 1
print fab(5) # <generator object fab at 0x7f2369495820>

# 调用fab函数不会执行fab函数，而是直接返回一个生成器对象。因为生成器就是迭代器
f = fab(5)
f.next()


# 每次 fab 函数的 next 方法，就会执行 fab 函数，执行到 yield b 时， fab 函数返回
一个值，下一次执行 next 方法时，代码从 yield b 的吓一跳语句继续执行，直到再遇
到 yield。
```

**生成器表达式** 

    简化的for 和if 语句，使用小括号返回一个生成器，中括号返回一个列表

```python
result = (x for x in range(5))  #生成器表达式


result = [x for x in range(5)] # 列表解析式
```

# 文件IO

```python
# 文件的写入
with open("demo.txt", "w", encoding='utf-8') as f:
    f.write("line1\n")
    f.write("line2\n")


# 文件的读取
with open("demo.txt", "r", encoding="utf-8",) as f:
    #第一种读法：read()
    txt = f.read()
    #第二种读法：readline()
    line1 = f.readline()
    #第三种读法：readlines()   输出列表，每一个为一个元素
    line_txt = f.readlines() 
```

文件模式:

| 值       | 描述                  |
| ------- | ------------------- |
| 'r'     | 读取模式（默认）            |
| **'w'** | 写入模式                |
| **'x'** | 独占写入模式              |
| **'a'** | 附加模式                |
| **'b'** | 二进制模式（与其他模式结合使用）    |
| **'t'** | 文本模式（默认值，与其他模式结合使用） |
| **'+'** | 读写模式（与其他模式结合使用）     |

> raw_input()：任何输入的都转成字符串存储
> 
> input()：接受输入的是一个表达式，否则就报错

# 正则表达式

python语言的正则表达式是由re库提供。

**re 正则库常用方法：**

   

| 方法                                                   | 描述                            |
| ---------------------------------------------------- | ----------------------------- |
| re.compile(pattern, flags = 0)                       | 把正则表达式编译成一个对象                 |
| re.findall(pattern, string, flags = 0)               | 以列表形式返回所有匹配的字符串               |
| re.finditer(pattern, string, flags = 0)              | 以迭代器形式返回所有匹配的字符串              |
| re.match(pattern, string, flags = 0)                 | 匹配字符串开始，如果不匹配返回None           |
| re.search(pattern, string, flags = 0)                | 返回第一个匹配对象并终止匹配，否则返回None       |
| re.split(pattern, string, maxsplit = 0, flags = 0)   | 以匹配模式作为分隔符，切分字符串为列表           |
| re.sub(pattern, repl, string, count = =0, flags = 0) | 字符串替换，repl替换匹配字符串，repl可以是一个函数 |
| re.purge()                                           | 清除正则表达式缓存                     |

参数说明：

    pattern：正则表达式

    string：要匹配的字符串

    flags：标志位的修饰符，用于控制表达式匹配模式

标志位的修饰符：

| 修饰符                | 描述                                         |
| ------------------ | ------------------------------------------ |
| re.DEBUG           | 显示关于编译正则的debug信息                           |
| re.I/re.IGNORECASE | 忽略大小写                                      |
| re.L/re.LOCALE     | 本地化匹配，影响\W \w \B \b \S \s                  |
| re.M/re.MULTILINE  | 多行匹配，影响 ^   和\$                            |
| re.S/re.DOTAIL     | 匹配所有字符，包括换行符\n，如果没有这个标志将不匹配换行符             |
| re.U/re.UNICODE    | 根据Unicode字符集解析字符。影响\W \w \B \b \D \d \S \s |
| re.X/re.VERBOSE    | 允许编写更好看、更可读的正则表达式，也可以在表达式添加注释              |

**r“\Wabc\d”  含义：** r [表示原始字符，没有它，pattern中的 斜杠，就需要另一个斜杠转义]

```python
import re

prog = re.compile(pattern)
result = prog.match(string)

#上面效果等于
result = re.match(pattern, string)
```

## 贪婪 和 非贪婪 匹配

    贪婪模式：尽可能最多匹配  
    非贪婪模式，尽可能最少匹配，一般在量词（*、 +）后面加个问号就是非贪婪模式。

    贪婪匹配是尽可能的向右匹配，直到字符串结束。  
    非贪婪匹配是匹配满足后就结束

# 附录

## 附录1   格式化输出

| 操作符号 | 描述             |
| ---- | -------------- |
| %s   | 字符串（ str()  ）  |
| %r   | 字符串（ repr()  ） |
| %d   | 整数             |
| %f   | 浮点数            |

repr()  和反撇号把字符串转为python表达式

**彩色输出：**

| 字体颜色  | 字体背景颜色 | 显示方式     |
| ----- | ------ | -------- |
| 30：黑  | 40：黑   | 0：终端默认设置 |
| 31：红  | 41：深红  | 1：高亮显示   |
| 32：绿  | 42：绿   | 4：下划线    |
| 33：黄  | 43：黄色  | 5：闪烁     |
| 34：蓝色 | 44：蓝色  | 7：反白显示   |
| 35：紫色 | 45：紫色  | 8：隐藏     |
| 36：深绿 | 46：深绿  |          |
| 37：白色 | 47：白色  |          |

\033[1;31;40   #开启颜色模式

\033[0m     #关闭颜色模式

## 关系测试

| 符号     | 描述     |
| ------ | ------ |
| —      | 差集     |
| &      | 交集     |
|        |        |
| !=     | 不等于    |
| ==     | 等于     |
| in     | 是成员为真  |
| not in | 不是成员为真 |

## 内建函数

```python
join() # 用于连接字符串
eval()  #将字符串当成python表达式来处理len(A)  #获取A的长度
type()  #获取对象类型
id()   #获取对象的内存地址
ord()、chr()  #字符串和其对应编码的转换
max()、min()  #获取最大/小值
zip() #

#例子： 将下面两个列表合并为字典
attr_list = ["name","age", "height"]
value_list = ["Alice",18,165]

p_dist2 = dist(zip(attr_list, value_list))


2. 内置高阶函数
# map(function, sequence [, sequence, ...])  ——>  list

lst = [1, 2, 3, 4, 5]
map(lambda x: str(x) + ".txt", lst)


# filter(function or None, sequence) ——>  list or tuple or string
# 将序列中的元素通过函数处理返回一个新列表、元组或字符串
lst = [1, 2, 3, 4, 5]
filter(lambda  x: x % 2 == 0, lst)


# reduce(function, sequence [, initial]) ——> value
# reduce()是一个二元运算函数，所以只接受二元操作函数
lst = [1, 2, 3, 4, 5]
reduce(lambda x,y:x+y, lst)
```
