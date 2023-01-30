

对于对时间特别敏感的程序，时间同步是一个很重要的操作。
对于Windows系统，系统时间的设置比较简单。设置后开机、关机不会有影响。系统时间自动保存到bios里，开启时自动同步bios里的硬件时间。
对于linux系统，系统时间和硬件时间不会自动同步，两者互不干扰。硬件时间靠bios电池来维持。系统时间靠cputick来维持。
系统开机时，会自动从bios中取硬件时间，来设置系统时间。

linux系统：
    date    #查看系统时间
    date  -s    #修改系统时间
    
    #查看硬件时间
    hwclock  
    hwclock --show
    hwclock -r    
    
    #修改硬件时间
    hwclock --set  --date=''    # '' 的格式：月/日/年 时:分:秒
    hwclock  -w   # 根据系统时间设置硬件时间
    
    #根据硬件时间修改系统时间
    hwclock --hctosys
    hwclock -s
    
    #根据系统时间修改硬件时间
    hwclock --systohc
    hwclock -w
    
    
# 不同服务器之间时间同步：
    ntpdate 命令：
        安装ntpdate命令：  yum  -y  install ntpdate
        手动同步时间：ntpdate [-nv] NtpserverIP
        
**ntpd 服务做时间同步，要好于ntpdate + crontab 组合的效果。但 ntpd 服务有一个自我保护机制：如果本地时间与上游时间服务器时间相差过大，ntpd不允许。**        
**建议：
    在启动 ntpd 服务之前，先使用 ntpdate 命令手动同步上游时间服务器，然后再启动 ntpd 服务**
    
   
    
**ntpd服务的相关设置文件如下：**

/etc/ntp.conf：这个是NTP daemon的主要设文件，也是 NTP 唯一的设定文件。

/usr/share/zoneinfo/:在这个目录下的文件其实是规定了各主要时区的时间设定文件，例如上海地区的时区设定文件在/usr/share/zoneinfo/Asia/Shanghai 。
这个目录里面的文件与底下要谈的两个文件(clock 与localtime)是有关系的。

/etc/sysconfig/clock：这个文件其实也不包含在NTP 的 daemon 当中，因为这个是linux的主要时区设定文件。每次开机后，Linux 会自动的读取这个文件来设定自己系统所默认要显示的时间。

/etc/localtime：这个文件就是“本地端的时间配置文件”。刚刚那个clock 文件里面规定了使用的时间设置文件(ZONE) 为/usr/share/zoneinfo/Asia/Shanghai ，
所以说，这就是本地端的时间了，此时， Linux系统就会将Beijing那个文件另存为一份/etc/localtime文件，所以未来我们的时间显示就会以Beijing那个时间设定文件为准。

/etc/timezone：系统时区文件    



**ntp.conf 配置文件详解：**
    # 1. 关于权限设定部分
	#　　权限的设定主要以 restrict 这个参数来设定，主要的语法为：
	# 　　restrict IP mask netmask_IP parameter
	# 　　其中 IP 可以是软件地址，也可以是 default ，default 就类似 0.0.0.0
	#　　至于paramter则有：
	#　　　ignore　：关闭所有的 NTP 联机服务
	#　　　nomodify：表示 Client 端不能更改 Server 端的时间参数，不过，
	
	#　　　Client 端仍然可以透过 Server 端来进行网络校时。
	#　　　notrust：该 Client 除非通过认证，否则该 Client 来源将被视为不信任网域
	#　　　noquery：不提供 Client 端的时间查询
	
	#　　　notrap：不提供trap这个远程事件登入
	
	#　　如果paramter完全没有设定，那就表示该 IP (或网域)“没有任何限制”
	
	restrict default nomodifynotrapnoquery　# 关闭所有的 NTP 要求封包
	restrict 127.0.0.1　　　 #这是允许本级查询
	restrict 192.168.0.1 mask 255.255.255.0 nomodify
	#在192.168.0.1/24网段内的服务器就可以通过这台NTP Server进行时间同步了

	# 2. 上层主机的设定
	#　　要设定上层主机主要以 server 这个参数来设定，语法为：
	#　　server [IP|HOST Name] [prefer]
	#　　Server 后面接的就是我们上层 Time Server ！而如果 Server 参数后面加上perfer的话，那表示我们的 NTP 主机主要以该主机来作为时间校正的对应。
	#　　另外，为了解决更新时间封包的传送延迟动作，所以可以使用driftfile来规定我们的主机
	#　　在与 Time Server 沟通时所花费的时间，可以记录在 driftfile 后面接的文件内。
	#　　例如下面的范例中，我们的 NTP server 与 cn.pool.ntp.org联机时所花费的时间会记录在 /etc/ntp/drift文件内
	server 0.pool.ntp.org
	
	server 1.pool.ntp.org
	
	server 2.pool.ntp.org
	
	server cn.pool.ntp.org prefer
	
	#其他设置值，以系统默认值即可
	
	server  127.127.1.0     # local clock
	
	fudge   127.127.1.0 stratum 10
	
	driftfile /var/lib/ntp/drift
	broadcastdelay  0.008
	keys /etc/ntp/keys
	
	总结一下，restrict用来设置访问权限，server用来设置上层时间服务器，driftfile用来设置保存漂移时间的文件。


[root@linux ~] # ntpq –p

指令“ntpq -p”可以列出目前我们的NTP与相关的上层NTP的状态，以上的几个字段的意义如下：

remote：即NTP主机的IP或主机名称。注意最左边的符号，如果由“+”则代表目前正在作用钟的上层NTP，如果是“*”则表示也有连上线，不过是作为次要联机的NTP主机。
refid：参考的上一层NTP主机的地址
st：即stratum阶层
when：几秒前曾做过时间同步更新的操作
poll：下次更新在几秒之后
reach：已经向上层NTP服务器要求更新的次数
delay：网络传输过程钟延迟的时间
offset：时间补偿的结果
jitter：Linux系统时间与BIOS硬件时间的差异时间


    ntp服务默认只会同步系统时间。如果想要让ntp同时同步硬件时间，可以设置/etc/sysconfig/ntpd文件。

    在/etc/sysconfig/ntpd文件中，添加 SYNC_HWCLOCK=yes 这样，就可以让硬件时间与系统时间一起同步。


restrict 控制相关权限：

    语法为： restrict IP地址 mask 子网掩码 参数
        其中IP地址也可以是default ，default 就是指所有的IP

    参数有以下几个：
    ignore  ：关闭所有的 NTP 联机服务
    nomodify：客户端不能更改服务端的时间参数，但是客户端可以通过服务端进行网络校时。
    notrust ：客户端除非通过认证，否则该客户端来源将被视为不信任子网
    noquery ：不提供客户端的时间查询：用户端不能使用ntpq，ntpc等命令来查询ntp服务器
    notrap ：不提供trap远端登陆：拒绝为匹配的主机提供模式 6 控制消息陷阱服务。陷阱服务是 ntpdq 控制消息协议的子系统，用于远程事件日志记录程序。
    nopeer ：用于阻止主机尝试与服务器对等，并允许欺诈性服务器控制时钟
    kod ： 访问违规时发送 KoD 包。

    restrict -6 表示IPV6地址的权限设置。
    


常见的错误：

25 Apr 15:30:17 ntpdate[11520]: no server suitable for synchronization found

其实，这不是一个错误。而是由于每次重启NTP服务器之后大约要3－5分钟客户端才能与server建立正常的通讯连接。当此时用客户端连接服务端就会报这样的信息。一般等待几分钟就可以了。




**ntpd、ntpdate的区别**

下面是网上关于ntpd与ntpdate区别的相关资料。如下所示所示：

使用之前得弄清楚一个问题，ntpd与ntpdate在更新时间时有什么区别。ntpd不仅仅是时间同步服务器，它还可以做客户端与标准时间服务器进行同步时间，而且是平滑同步，并非ntpdate立即同步，在生产环境中慎用ntpdate，也正如此两者不可同时运行。

时钟的跃变，对于某些程序会导致很严重的问题。许多应用程序依赖连续的时钟——毕竟，这是一项常见的假定，即，取得的时间是线性的，一些操作，例如数据库事务，通常会地依赖这样的事实：时间不会往回跳跃。不幸的是，ntpdate调整时间的方式就是我们所说的”跃变“：在获得一个时间之后，ntpdate使用settimeofday(2)设置系统时间，这有几个非常明显的问题：

第一，这样做不安全。ntpdate的设置依赖于ntp服务器的安全性，攻击者可以利用一些软件设计上的缺陷，拿下ntp服务器并令与其同步的服务器执行某些消耗性的任务。由于ntpdate采用的方式是跳变，跟随它的服务器无法知道是否发生了异常（时间不一样的时候，唯一的办法是以服务器为准）。

第二，这样做不精确。一旦ntp服务器宕机，跟随它的服务器也就会无法同步时间。与此不同，ntpd不仅能够校准计算机的时间，而且能够校准计算机的时钟。

第三，这样做不够优雅。由于是跳变，而不是使时间变快或变慢，依赖时序的程序会出错（例如，如果ntpdate发现你的时间快了，则可能会经历两个相同的时刻，对某些应用而言，这是致命的）。因而，**唯一一个可以令时间发生跳变的点，是计算机刚刚启动，但还没有启动很多服务的那个时候。其余的时候，理想的做法是使用ntpd来校准时钟，而不是调整计算机时钟上的时间。**

NTPD 在和时间服务器的同步过程中，会把 BIOS 计时器的振荡频率偏差——或者说 Local Clock 的自然漂移(drift)——记录下来。这样即使网络有问题，本机仍然能维持一个相当精确的走时。







参考：
https://blog.csdn.net/m0_67392010/article/details/126434390
