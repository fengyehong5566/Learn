
# GPU日志收集
  任意目录下执行：
    nvidia-bug-report.sh 
  会在当前目录下生产日志压缩包：nvidia-bug-report.log.gz
  
  
# GPU 基础状态检测
  > 对于GPU服务器建议客户维持较新的GPU驱动版本、禁用nouveau模块、打开GPU驱动内存常驻模式并配置开机自启动。
  
  处理GPU服务器故障时，只要涉及到服务器关机的操作，均建议对GPU基础状态进行检测，包括：
    nouveau模块是否禁用、GPU识别情况、GPU驱动内存常驻模式、GPU带宽、GPU ECC报错、 GPU ERR报错、GPU nvlink状态
    
## nouveau模块禁用检查
  nouveau是由一群开发人员构建的nvidia显卡开源驱动程序，会与nvidia官方gpu驱动发生冲突，需在系统下禁用nouveau模块
    # 以下命令没有任何输出表示nouveau模块已经禁用，有输出表示没有禁用
        lsmod | grep -i nouveau
    
    # 禁用 nouveau模块的方法，【centos7】
      #编辑或新建 blacklist-nouveau.conf wenj 
      vim  /usr/lib/modprobe.d/blacklist-nouveau.conf
      blacklist  nouveau
      options  nouveau  modeset=0
      
      #执行如下命令并重启系统内核生效
      dracut -force
      shutdown -ry  0

## GPU驱动内存常驻模式
  打开GPU驱动内存常驻模式可以减少GPU掉卡、GPU带宽降低、GPU温度监测不到等诸多问题。建议打开GPU驱动内存常驻模式并配置开机自启动。
  GPU驱动内存常驻模式检查常用方法：
    nvidia-smi 输出中Persistence-M状态为on
    nvidia-but-report.log中，Persistence Mode为Enabled
    
    nvidia-smi命令输出，查看Persistence
    
    命令：
      nvidia-smi  -pm 1
    或：
      # 以下命令对较新版本的GPU驱动有效
      nvidia-persistenced  --persistence-mode
      
    开机自启配置：
      vim /etc/rc.d/rc.local
        nvidia-smi -pm 1
      
## 检查GPU 是否识别    
    GPU识别状态检测时，首先要确保lspci命令识别所有GPU，其次确保nvidia-smi 命令识别所有GPU
    
    lspci 检查GPU识别情况
      lspci | grep -i nvidia 命令输出中确保所有GPU识别正常，并且每个GPU末尾标识为(rev a1)。
      输出信息末尾为(rev ff)，表示GPU异常。
    
    
## GPU带宽检查    
  需要确保GPU当前带宽和额定带宽一致，一般 X16表示正常
    # lspci 命令
      额定带宽：lspci -vvd 10de: | grep -i Lnkcap:
      当前带宽：lspci -vvd 10de: | grep -i Lnksta:
    
    # nvidia-smi 命令检查
      nvidia-smi -q | grep -i -A 2 'Link width'
    
    
## GPU ECC 计数检查
  GPU ECC计数可以通过以下方法进行检查
  > 如下输出中Pending 的标志为No表示所有ECC报错地址空间已经被屏蔽，报错地址空间后续不会再被软件程序调用，不会再影响程序运行。
  >    Pending :No
  >    Yes 表示有需要被屏蔽的ECC报错地址，需要重启系统或重置GPU使其变为No。
  
    # 使用 -i 参数指定GPU id查询某一块GPU的ECC计数
    # nvidia-smi -i <target gpu> -q -d PAGE_RETIREMENT
      ...
      Retired pages
      Single Bit ECC             : 2
      Double Bit ECC             : 0
      Pending                    : No

    # 不使用 -i 参数查询所有GPU的ECC计数
    # nvidia-smi -q -d PAGE_RETIREMENT
    
    也可通过nvidia-smi | grep -i 'bit ecc' 命令进行查看。
    GPU ECC计数请根据公司指标要求进行GPU更换，另需确保有ECC计数的GPU 报错地址空间已经被屏蔽，即Pending ：No。
    
## GPU ERR 报错检查
  GPU运行过程中会出现Fan ERR以及功率ERR报错，可以通过检查 nvidia-smi 输出中是否包含ERR 报错判断
    
    
## GPU 序列号查询
    nvidia-smi  -q | grep -i serial
     
    # 可以通过nvidia-smi -q -i id 来检查指定id的GPU序列号
    # nvidia-smi -q -i 0 | grep -i serial
      Serial Number                   : 0324018045603
    
    
    

# nvidia-smi常见操作

  ## nvidia-smi 命令输出解析
    GPU：表示本机中GPU编号（从0开始）
    Fan：风扇转速（0%--100%） N/A 表示没有风扇
    Name：GPU类型
    Temp：GPU温度（GPU温度过高会导致GPU的频率下降）
    Perf：GPU的性能状态，从P0（最大性能）到P12（最小性能），图上是：P0
    Persistence-M：持续模式的状态，持续模式虽然耗能大，但是在新的GPU应用启动时花费的时间更少，图上显示的是：off
    Pwr：Usager/Cap：能耗表示，Usage：用了多少，Cap总共多少
    Bus-Id：GPU总线相关显示，domain：bus：device.function
    Disp.A：Display Active ，表示GPU的显示是否初始化
    Memory-Usage：显存使用率
    Volatile GPU-Util：GPU使用率
    Uncorr. ECC：关于ECC的东西，是否开启错误检查和纠正技术，0/disabled,1/enabled
    Compute M：计算模式，0/DEFAULT,1/EXCLUSIVE_PROCESS,2/PROHIBITED
    Processes：显示每个进程占用的显存使用率、进程号、占用的哪个GPU

  每隔几秒刷新显存状态
    nvidia-smi -l 2  【每隔2秒刷新一次】
    
  
    
    
    
    
    
    
    
