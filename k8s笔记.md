<center>
<font size=10, color=blue>
Kubernetes 学习
</font>
</center>

# K8s介绍

Kubernetes 是容器集群管理系统，可以实现容器集群的自动化部署、自动扩缩容、维护等功能。

优点：  
　　1、快速部署应用  
　　2、快速扩展应用  
　　3、无缝对接新的应用功能  
　　4、节省资源，优化硬件资源的使用  

功能：  
　　1、多个进程（作为容器运行）协同工作（pod）  
　　2、存储系统挂载  
　　3、Distributing secrets  
　　4、应用健康检测  
　　5、应用实例的复制  
　　6、Pod自动伸缩/扩展  
　　7、Naming and discovering  
　　8、负载均衡  
　　9、滚动更新  
　　10、资源监控  
　　11、日志访问  
　　12、调试应用程序  
　　13、提供认证和授权  

组件：  
　　Master组件：  
　　　　kube-apiserver：用于暴露Kubernetes API。任何资源请求/调用操作都是通过kube-apiserver提供的接口进行。  

　　　　Etcd：k8s默认的存储系统，报错集群的所有数据，使用时要考虑备份计划。  

　　　　kube-Controller-manager：运行管理控制器，是集群中处理常规任务的后台线程。逻辑上，每个控制器是一个单独的进程，但为了降低复杂度，它们都被编译成单个二进制文件，并在单个进程中运行。  
　　　　控制器包括：  
　　　　　　节点（Node）控制器  
　　　　　　副本（Replication）控制器【负责维护系统中每个副本中的pod】  
　　　　　　端点（Endpoints）控制器【填充Endpoints对象（即连接Services&Pods）】  
　　　　　　Service Account和Token控制器【为新的Namespace创建默认账户访问API Token】  

　　　　Cloud-controller-manager：云控制器管理器负责与底层云提供商的平台交互。  
　　　　cloud-controller-manager 具体功能：
　　　　　　节点（Node）控制器  
　　　　　　路由（Route）控制器  
　　　　　　Service控制器  
　　　　　　卷（Volume）控制器  

　　　　kube-scheduler：kube-scheduler监视新创建没有分配到Node的Pod，为Pod选择一个Node  

　　节点组件：  
　　　　节点组件运行在Node，提供Kubernetes运行时环境，以及维护Pod  
　　　　Kubelet：主要的节点代理，它会监视已分配给节点的Pod。  
　　　　　　功能：  
　　　　　　　　1、安装pod所需要的volume  
　　　　　　　　2、下载pod的Secrets  
　　　　　　　　3、Pod中运行的docker容器  
　　　　　　　　4、定期执行容器健康检查  
　　　　　　　　5、Reports the status of the pod back to the rest of the system, by creating a mirror pod if necessary.  
　　　　　　　　6、Reports the status of the node back to the rest of the system.   

　　　　kube-proxy：通过在主机上维护网络规则并执行连接转发来实现k8s服务抽象。

**K8s 对象** 是Kubernetes系统中的持久实体，k8s使用这些实体来表示集群的状态。  
　　**对象（Object）** 规范和状态：
　　　　每个k8s对象都包含两个嵌套对象字段，用于管理Object的配置：Object Spec和Object Status  
　　　　Spec描述了对象所需的状态 - 希望Object具有的特性  
　　　　Status描述了对象的实际状态，并由Kubernetes系统提供和更新  

**K8s Name**  
Kubernetes REST API中的所有对象都用Name和UID来明确的表示，对于非唯一用户提供的属性，Kubernetes提供 labels 和 annotations。

**K8s Namespaces**  
Namespace为名称提供了一个范围，资源的Names在Namespace中具有唯一性。  
Namespace是一种将集群资源划分为多个用途的方法。  

> 　　创建：  
> 　　　　kubectl create namespce  new-namespace

> 　　file.yaml文件：  
> 　　　　apiVersion：V1  
> 　　　　kind：Namespace  
> 　　　　metadata：  
> 　　　　　　name： new-namespace  
> 　　　　kubectl create -f file.yaml

> 　　删除：  
> 　　　　kubectl delete namespaces new-namespace

**注意：**  
　　　　删除一个namespace会自动删除所有属于该namespace的资源  
　　　　default和kube-system命名空间不可删除  
　　　　PersistentVolumes是不属于任何namespace的，但PersistentVolumeClaim是属于某个特定namespace的  
　　　　Events是否属于namespace取决于events的对象  

> 　　查看：  
> 　　　　kubectl get namespaces

**Setting the namespace for a request**  
临时设置request的namespace  

> 　　kubectl --namespace=\<insert-namespace-name-here\> run nginx  --image=nginx  
> 　　kubectl --namespace=\<insert-namespace-name-here\> get pods  

**Setting the namespace perference**  
可以使用kubectl命令创建的Namespace可以永久保存在context中。  

> kubectl config  set-context $(kubectl config current-context) --namespace=\<insert-namespace-name-here\>

# 配置限额

**Namespce配置Pod配额**：设置Pod配额可以限制namespace中运行的Pod数量。

**Namespace配置默认的CPU请求与限额**  
**Namespace配置默认的内存请求与限额**  
**Namespace配置最小和最大内存限制**  
**namespace配置最小和最大cpu限制**  

# 标签（Labels）：

Lable是一对key/value。  
有效的标签包含两段：可选的前缀、名称，用斜杆(/)分隔。  
名称：必需的，最多63个字符。[a-z0-9A-Z]、虚线(-)、下划线(_)、点（.），必须以字母或数字开头/结尾。   
前缀：如果指定了前缀，那么必须是DNS子域：一系列的DNSlabel通过”.”来划分，不超过253个字符，以斜杠（/）结尾。  

# 标签选择器(Selectors)：

标签选择器是k8s中核心的组成部分。
API目前支持两种选择器：  
　　equality-based（基于平等）【3种运算符：=、==、!=】  
　　set-based（基于集合）【3种运算符：in、notin、exists】

支持set-based要求的资源：Job、Deployment、Replica Set、Daemon Set

# k8s网络

## 名词解释：

    网络的命名空间：

    Veth设备对：

    Iptables/Netfilter：

    网桥：

    路由：

## 一个service：

    **​定义：** 是 K8s 为屏蔽一些后端实例（Pod）的动态变化和对多实例的负载均衡而引入的资源对象。Service 通常与 deployment 绑定，定义了服务的访问入口地址，应用（Pod）可以通过这个入口地址访问其背后的一组由 Pod 副本组成的集群实例。Service 与其后端 Pod 副本集群之间则是通过 Label Selector 来实现映射。

    **type：** ClusterIP、NodePort、LoadBalancer

## 二个IP：

​ ClusterIP：仅作用于service，无法ping通，作用是为 Service 后端的实例提供统一的访问入口。默认轮询。有kube-proxy组件维护，两种方式：iptables和IPVS

​ PodIP：每个pod对象的IP地址

​ 注：nodeIP即物理IP，这里不在讲述

## 三个Port：

​ Port：是特指K8s中Service的port，是Service间的访问端口。它仅对进群内容器提供访问权限，而无法从集群外部通过该端口访问服务。与clusterIP“绑定”

​ nodePort：为外部机器提供了访问集群内服务的方式

​ targetPort：是容器的端口（最根本的端口入口），与制作容器时暴露的端口一致（DockerFile中EXPOSE）

## 集群内通信：

### 单节点通信：【两种情况】

​ 1、同一个pod内容器通信

​ 2、同一个节点，不通pod件通信

​ 以上两种情况，因不涉及跨节点访问，所以流程不经过物理网卡

 **1、Pod内通信：** 

​ 同一个pod内容器共享网络命名空间，容器之间可通过127.0.0.1:Port 直接访问，由 docker0网桥 进行转发。【这里涉及到Veth*】

 **2、pod间通信**： 

​ 由于 Pod 内共享网络的命名空间是 pause 容器创建，所以本质上也是同节点容器间的通信。同时，同一 Node 中 Pod 的默认路由都是 docker0 的地址，由于它们关联在同一个 docker0 网桥上，地址网段相同，所有它们之间应当是能直接通信的。

​ 访问同节点另一个pod内的容器，其请求的地址是PodIP而非容器的ip

### 跨节点通信：

​ CNI：容器网络接口

​ CNI 是一种标准，它旨在为容器平台提供网络的标准化。不同的容器平台（比如目前的 kubernetes、mesos 和 rkt）能够通过相同的接口调用不同的网络组件。

​ 在docker中，主流的跨主机通信方案主要有一下几种：

​ a、基于隧道的overlay网络：

​ 按隧道类型来说：不通公司或组织有不同的实现方案：

​ docker原生的overlay网络就是基于vxlan隧道实现的。flannel最新版默认基于vxlan实现overlay网络。

​ b、基于包封装的overlay网络：

​ 基于UDP封装等数据包包装方式，在docker集群上实现跨主机网络。典型的实现方案有：weave、flannel的早期版本

​ c、基于三层实现SDN网络：

​ 基于三层协议和路由，直接在三层上实现跨主机网络，并且通过iptables实现网络的安全隔离。典型方案：project calico，该方案还针对不支持三层路由的环境，提供了基于IPIP封装的跨主机网络实现。

## 外部访问集群：

从集群外访问集群有多种方式

​ nodeport和loadbalancer是service的两个基本类型，是将service直接对外暴露的方式。

​ ingress则是提供了七层负载均衡，其基本原理将外部流量转发到内部的service，再转发到后端endpoints。

​ 日常主要使用的方式：nodeport和ingress

图示：

​ NodePort：

​ ![image-20220322152345715](C:\Users\A\AppData\Roaming\Typora\typora-user-images\image-20220322152345715.png)

ingress：

![image-20220322152411978](C:\Users\A\AppData\Roaming\Typora\typora-user-images\image-20220322152411978.png)

Ingress 是推荐在生产环境使用的方式，它起到了七层负载均衡器和 Http 方向代理的作用，可以根据不同的 url 把入口流量分发到不同的后端Service。
