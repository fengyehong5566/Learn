<center>
<font color=blue size=7 >
Kubernetes笔记
</font>
</center>

# 第 1 章 K8s涉及理念

## 1.1 k8s组件

K8s由etcd、控制节点[即master节点]、服务节点[即node节点]组成。  
　　etcd：保存整个集群的状态  
　　控制节点组件：  
　　　　apiserver：资源操作的唯一入口，还提供认证、授权、访问控制、API注册和发现机制。  
　　　　controller manager：负责维护集群的状态，比如故障检测、自动扩展、滚动更新等  
　　　　scheduler：负责资源的调度，按照预定的调度策略将pod调度到相应的机器上  
　　服务节点组件：  
　　　　kubelet：负责维护容器的生命周期，也负责Volume（CVI）和网络（CNI）的管理  
　　　　Container runtime：负责镜像管理以及pod和容器的真正运行（CRI），常用的runtime如 docker  
　　　　kube-proxy：负责为Service提供cluster内部的服务发现和负责均衡    
　　额外的组件：
　　　　kube-dns：负责为整个集群提供DNS服务  
　　　　Ingress Controller：为服务提供外网入口  
　　　　Heapster：提供资源监控
　　　　Dashboard：提供GUI
　　　　Federation：提供跨可用区的集群
　　　　Fluend-elasticsearch：提供集群日志采集、存储与查询  

## 1.2 核心概念和API对象

　　API对象是k8s集群中的管理操作单元，k8s集群每支持一项新功能，引入一项新技术，一定会新引入对应的api对象，支持对该功能的管理操作。  

> 　　API对象3大类属性：  
> 　　　　metadata（元数据）：  
> 　　　　spec（规范）  
> 　　　　status（状态）  
> 　　metadata：用来标识API对象，每个对象至少有3个元数据(Namespace、name、uid)，此外还有各种各样的labels用来标识和匹配不同的对象  
> 　　spec：描述了用户期望k8s集群中分布式系统达到的理想状态。
> 　　status：描述了系统实际当前达到的状态。

### Pod

Pod是k8s集群中操作的最小单元。  
Pod的涉及理念是支持多个容器在一个pod中共享网络地址和文件系统，可以通过进程间通信和文件共享这种简单高效的方式组合完成服务。
k8s集群中的业务主要可以分为长期伺服型（long-running）、批处理型（batch）、节点后台支撑型（node-daemon）和有状态应用型（stateful application），分别对应deployment、job、daemonset、Petset  

### Replication Controller（RC，复制控制器）

RC是k8s集群最早的保证Pod高可用的API对象。通过监控 **运行中的pod** 来保证集群中运行指定数目的pod副本。按照指定副本数，**多则杀，少则启** 。即使仅启动1个pod，也比直接运行pod更明智。只适用于长期伺服型的业务类型。  

### Replica Set（RS，副本集）

RS是新一代RC，提供同样的高可用能力，主要区别 **RS支持更多种类的匹配模式**。副本集对象一般不单独使用，而是作为Deployment的理想状态参数使用。

### Deployment（部署）

deployment表示用户对k8s机器的一次更新操作。  
deployment是一个比RS应用模式更广的API对象，可以是创建新服务、更新服务、滚动升级服务。  
滚动升级服务，实际是创建一个新的RS，然后逐渐将新RS中副本数增加到理想状态，将旧RS中的副本数减小到0的复合操作；这样一个复合操作用一个RS是不太好描述的，所以用一个更通用的Deployment来描述。  
以K8s的发展方向，未来对所有长期伺服型的的业务的管理，都会通过Deployment来管理。

### Service（服务）

RC、RS和Deployment只是保证了支撑服务的微服务Pod的数量，但是没有解决如何访问这些服务的问题。一个Pod只是一个运行服务的实例，随时可能在一个节点上停止，在另一个节点以一个新的IP启动一个新的Pod，因此不能以确定的IP和端口号提供服务。要稳定地提供服务需要服务发现和负载均衡能力。服务发现完成的工作，是针对客户端访问的服务，找到对应的的后端服务实例。  
**在K8s集群中，客户端需要访问的服务就是Service对象。每个Service会对应一个集群内部有效的虚拟IP，集群内部通过虚拟IP访问一个服务。**  
在K8s集群中微服务的负载均衡是由Kube-proxy实现的。Kube-proxy是K8s集群内部的负载均衡器。它是一个分布式代理服务器，在K8s的每个节点上都有一个；这一设计体现了它的伸缩性优势，需要访问服务的节点越多，提供负载均衡能力的Kube-proxy就越多，高可用节点也随之增多。与之相比，我们平时在服务器端做个反向代理做负载均衡，还要进一步解决反向代理的负载均衡和高可用问题。  

### Job（任务）

**Job是K8s用来控制批处理型任务的API对象。**  
批处理业务与长期伺服业务的主要**区别**是批处理业务的运行有头有尾，而长期伺服业务在用户不停止的情况下永远运行。  
Job管理的Pod根据用户的设置把任务成功完成就自动退出了。  
**成功完成的标志** 根据不同的spec.completions策略而不同：单Pod型任务有一个Pod成功就标志完成；定数成功型任务保证有N个任务全部成功；工作队列型任务根据应用确认的全局成功而标志成功。  

### DaemonSet（后台支持服务集）

长期伺服型和批处理型服务的核心在业务应用，可能有些节点运行多个同类业务的Pod，有些节点上又没有这类Pod运行。  
**daemonset** 的核心关注点在K8s集群中的节点（物理机或虚拟机），要保证每个节点上都有一个此类Pod运行。节点可能是所有集群节点也可能是通过nodeSelector选定的一些特定节点。典型的后台支撑型服务包括，存储，日志和监控等在每个节点上支持K8s集群运行的服务。  

### PetSet（有状态服务集）

在云原生应用的体系里，有下面两组近义词：  

> 　　第一组：  
> 　　　　stateless（无状态）  
> 　　　　cattle（牲畜）  
> 　　　　nameless（无名）  
> 　　　　disposable（可丢弃）  
> 　　第二组：  
> 　　　　stateful（有状态）  
> 　　　　pet（宠物）  
> 　　　　having name（有名）  
> 　　　　non-disposable（不可丢弃）  

RC和RS主要是控制提供无状态服务的，其所控制的Pod的名字是随机设置的，一个Pod出故障了就被丢弃掉，在另一个地方重启一个新的Pod，名字变了、名字和启动在哪儿都不重要，重要的只是Pod总数；  

**PetSet是用来控制有状态服务，PetSet中的每个Pod的名字都是事先确定的，不能更改。**  

对于RC和RS中的Pod，一般不挂载存储或者挂载共享存储，保存的是所有Pod共享的状态，Pod像牲畜一样没有分别；  
对于PetSet中的Pod，每个Pod挂载自己独立的存储，如果一个Pod出现故障，从其他节点启动一个同样名字的Pod，要挂载上原来Pod的存储继续以它的状态提供服务。  

适合于PetSet的业务包括数据库服务MySQL和PostgreSQL，集群化管理服务Zookeeper、etcd等有状态服务。  
PetSet做的只是将确定的Pod与确定的存储关联起来保证状态的连续性。  

### Federation（集群联邦）

在云计算环境中，服务的作用距离范围从近到远一般可以有：同主机（Host，Node）、跨主机同可用区（AvailableZone）、跨可用区同地区（Region）、跨地区同服务商（Cloud    Service    Provider）、跨云平台。  

K8s的设计定位是单一集群在同一个地域内，因为同一个地区的网络性能才能满足K8s的调度和计算存储连接要求。而联合集群服务就是为提供跨Region、跨服务商K8s集群服务而设计的。  

运行逻辑：  
　　每个K8s    Federation有自己的分布式存储、API Server和Controller    Manager。  用户可以通过Federation的API Server注册该Federation的成员K8s    Cluster。当用户通过Federation的API Server创建、更改API对象时，Federation API Server会在自己所有注册的子K8s Cluster都创建一份对应的API对象。在提供业务请求服务时，K8sFederation会先在自己的各个子Cluster之间做负载均衡，而对于发送到某个具体K8sCluster的业务请求，会依照这个K8s    Cluster独立提供服务时一样的调度模式去做K8sCluster内部的负载均衡。而Cluster之间的负载均衡是通过域名服务的负载均衡来实现的。  

### Volume（存储卷）

和docker存储卷类似，都测ker的存储卷作用范围为一个容器，k8s的存储卷生命周期和作用范围是一个pod。每个pod声明的存储卷由pod内所有容器共享。

### Persistent Volume（PV，持久存储卷）和 Persistent Volume Claim（PVC，持久存储卷声明）

PV和PVC使得K8s集群具备了存储的逻辑抽象能力，使得在配置Pod的逻辑里可以忽略对实际后台存储技术的配置，而把这项配置的工作交给PV的配置者，即集群的管理者。  

**存储的PV和PVC的这种关系**跟计算的Node和Pod的关系是非常类似的；
**PV和Node是资源的提供者**，根据集群的基础设施变化而变化，由K8s集群管理员配置；而**PVC和Pod是资源的使用者**，根据业务服务的需求变化而变化，有K8s集群的使用者即服务的管理员来配置。  

### Node(节点)

K8s集群中的计算能力由Node提供，是所有pod运行的地方。即物理机或虚拟机。  

### Secret（密钥对象）

Secret是用来保存和传递密码、密钥、认证凭证这些敏感信息的对象。  
使用Secret的 **好处** 是可以避免把敏感信息明文写在配置文件里在K8s集群中配置和使用服务不可避免的要用到各种敏感信息实现登录、认证等功能，即意图明确，避免重复，减少暴漏机会。  

### User Account（用户账户） 和 Service Account（服务账户）

用户帐户为人提供账户标识，而服务账户为计算机进程和K8s集群中运行的
Pod提供账户标识。  
用户帐户和服务帐户的一个 **区别** 是作用范围：用户帐户对应的是人的身份，人的身份与服务的namespace无关，所以用户账户是跨namespace的；而服务帐户对应的是一个运行中程序的身份，与特定namespace是相关的。  

### Namespace（名字空间）

名字空间为K8s集群提供虚拟的隔离作用，K8s集群初始有两个名字空间，分别是默认名字空间default和系统名字空间kube-system。

### RBAC访问授权

K8s在1.3版本中发布了alpha版的 **基于角色的访问控制（Role-based    Access Control，RBAC）** 的授权模式。相对于 **基于属性的访问控制（Attribute-based Access Control，ABAC）**，RBAC主要是引入了角色（Role）和角色绑定（RoleBinding）的抽象概念。  
在ABAC中，K8s集群中的访问策略只能跟用户直接关联；而在RBAC中，访问策略可以跟某个角色关联，具体的用户在跟一个或多个角色相关联。  

K8s系统最核心的两个设计理念：  
　　一个是容错性，一个是易扩展性。容错性实际是保证K8s系统稳定性和安全性的基础，易扩展性是保证K8s对变更友好，可以快速迭代增加新功能的基础。  

# 第 2 章 K8s 基础

Kubernetes主要概念和对象介绍：  

```
    Pod,    Service,    Namespace和Node  
    Service  
    Volume和Persistent    Volume  
    Deployment  
    Secret  
    StatefulSet  
    DaemonSet  
    ServiceAccount  
    ReplicationController和ReplicaSet  
    Job  
    CronJob  
    SecurityContext  
    Resource    Quota  
    Pod    Security    Policy  
    Horizontal    Pod    Autoscaling  
    Network    Policy  
    Ingress  
    ThirdPartyResources  
```

## 2.1 Pod

　　Pod是一组紧密关联的容器集合，共享IPC、Network和 UTC Namespace，是k8s调度的基本单位。  

Pod删除的时候先给其内的进程发送SIGTERM，等待一段时间（grace period)后才强制停止依然还在运行的进程。
Pod一旦调度后就跟Node绑定，即使Node挂掉也不会重新调度，推荐使用
Deployments、Daemonsets等控制器来容错。  

## 2.2 Namespace

Namespace是对一组资源和对象的抽象集合.
常见的pods、service、replication controller和deployment等都属于某个namespace（默认属于default），而node、persistentVolumes等则不属于任何namespace。
namespace常用来隔离不同的用户。

namespace包含两种状态：  
　　Activing  
　　Terminationg

注：  
1、删除一个namespace会自动删除所有属于该namespace的资源
2、default和kube-system命名空间不可删除
3、PersistentVolumes不属于任何namespace，但PersistentVolumeClaim是属于某个特定namespace的。
4、Events是否属于namespace取决于产生events的对象。

## 2.3 Node

Node是Pod真正运行的主机，可是物理机，可是虚拟机。为了管理pod，每个node节点至少要运行container runtime、kubelet、kube-proxy服务

默认情况下，kubelet在启动时会向master注册自己，并创建Node资源。

每个node都包含以下状态信息：  
　　地址：hostname、外网IP和内网Ip  
　　条件：包括OutOfDisk、Ready、MemoryPressure和DiskPressure  
　　容量：node上可用的资源，cpu、内存和Pod总数等  
　　基本信息：内核版本、容器引擎版本、OS类型等  

**Taints和tolerations：**    

> Taints和tolerations用于保证Pod不被调度到不合适的Node上，Taint应用于Node上，而toleration则应用于Pod上（Toleration是可选的）。

**Node维护模式：**  
标志Node不可调度但不影响其上正在运行的Pod，这种维护Node时是非常有用的  

> **kubectl    cordon    $NODENAME**

**服务发现与负载均衡：**  
随着k8s使用场景的不断丰富，不断产生新的负载均衡机制：
k8s中大致可以分为以下几种机制：  

> 1、Service：直接用Service提供cluster内部的负载均衡，并借助cloud    provider提供的LB提供外部访问  
> 2、Ingress    Controller：还是用Service提供cluster内部的负载均衡，但是通过自定义LB提供外部访问  
> 3、Service    Load Balancer：把load balancer直接跑在容器中，实现Bare    Metal的Service Load Balancer  
> 4、Custom Load Balancer：自定义负载均衡，并替代kube-proxy，一般在物理部署Kubernetes时使用，方便接入公司已有的外部服务  

## 2.4 Service

Service是对一组提供相同功能的Pods的抽象，并为他们提供一个统一的入口。借助service，应用可以方便的实现服务发现与负载均衡，并实现应用的零宕机升级。  
Service通过标签来选取服务后端，一般配合Replication Controller或者Deployment来保证后端容器正常运行。

Service有四种类型：  
　　ClusterIP：默认类型，自动分配一个仅cluster内部可以访问的虚拟IP  
　　NodePort：在ClusterIP基础上为Service在每台机器上绑定一个端口，这样可以通过\<NodeIP\>:NodePort来访问服务。  
　　LoadBalancer：在NodePort的基础上，借助cloud Provider创建一个外部的负载均衡器，并将请求转发到\<NodeIP\>:NodePort
　　ExternalName：将服务通过DNS CNAME记录方式转发到指定的域名（通过spec.externalName设定）  

**不指定Selectors的服务：**  
创建不指定selector的Service，是用来将Service转发到kubernetes集群外部的服务（而不是Pod），目前支持两种方法：  
1、自定义endpoint：即创建同名的service和endpoint，在endpoint中设置外部服务的IP和端口  
2、通过DNS转发，在service定义中指定externalName。此时DNS服务会给\<service-name\>.\<namespace\>.svc.cluster.local创建一个CNAME记录，其值为my.database.example.com 。并且该服务不会自动分配ClusterIP，需要通过service的DNS来访问（这种服务也称为Headless Service）

**Headless服务：**  、
Headless服务即不需要Cluster IP的服务，即在创建服务的时候指定spec.clusterIP=None。包含两种类型：  
1、不指定Selectors，但设置externalName，通过CNAME记录处理
2、指定Selectors，通过DNS A记录设置后的endpoint列表

**保留源IP：**  
各种类型的Service对源IP的处理方法不同：  
1、ClusterIP Service：使用iptables模式，集群内部的源IP会保留（不做SNAT）  
2、NodePort Service：源IP会做SNAT，server pod看到的源IP是Node IP。为了避免这种情况，可以给service加上
annotation service.beta.kubernetes.io/external-traffic=OnlyLocal，
让service只代理本地endpoint的请求（如果没有本地endpoint则直接丢包），从而保留源IP。  
3、LoadBalancer Service：源IP会做SNAT，server pod看到的源IP是Node IP。在GKE/GCE中，添加
annotation service.beta.kubernetes.io/external-traffic=OnlyLocal    
后可以自动从负载均衡器中删除没有本地endpoint的Node。  

**Ingress Controller：**  
Service虽然解决了服务发现和负载均衡的问题，但它在使用上还是有一些限制，比如－    只支持4层负载均衡，没有7层功能    －    对外访问的时候，NodePort类型需要在外部搭建额外的负载均衡，而LoadBalancer要求kubernetes必须跑在支持的cloud    provider上面Ingress就是为了解决这些限制而引入的新资源，主要用来将服务暴露到cluster外面，并且可以自定义服务的访问策略。

注意Ingress本身并不会自动创建负载均衡器，cluster中需要运行一个ingress controller来根据Ingress的定义来管理负载均衡器。

**Service Load Balancer:**  
在Ingress出现以前，Service Load Balancer是推荐的解决Service局限性的方式。
Service Load Balancer将haproxy跑在容器中，并监控service和endpoint的变化，通过容器IP对外提供4层和7层负载均衡服务。
社区提供的Service LoadBalancer支持四种负载均衡协议：TCP、HTTP、HTTPS和SSL TERMINATION，并支持ACL访问控制。  

**Custom Load Balancer：**
虽然Kubernetes提供了丰富的负载均衡机制，但在实际使用的时候，还是会碰到一些复杂的场景是它不能支持的，比如：
　　1、接入已有的负载均衡设备
　　2、多租户网络情况下，容器网络和主机网络是隔离的，这样kube-proxy就不能正常工作
这个时候就可以自定义组件，并代替kube-proxy来做负载均衡。基本的思路是监控kubernetes中service和endpoints的变化，并根据这些变化来配置负载均衡器。比如weave    flux、nginx    plus、kube2haproxy等

## 2.5 Volume

| 类型                   | 特征                                                                                          |
| -------------------- | ------------------------------------------------------------------------------------------- |
| emptyDir             | Pod分配到Node上，只要pod在该node上允许，emptyDir就会存在不会被删除（容器内数据不会丢失），但如果pod被删除或删除，emptyDir就会被删除，数据也会永久丢失 |
| hostPath             | 允许挂载Node上的文件系统到Pod里面去。如果pod使用node上的文件也使用hostPath                                            |
| nfs                  | 网络文件系统，支持把NFS挂载到pod中，NFS的数据是可以永久保存的，但NFS需支持写操作。                                             |
| gecPersistentDisk    | 可以挂载GCE上的永久磁盘到用钱，需要k8s运行在gce的vm中                                                            |
| awsElasticBlockStore | 挂载AWS上的EBS盘到容器，需要k8s运行在AWS的EC2上                                                             |
| gitRepo              | 可以将git代码下拉到指定的容器路径中                                                                         |
| subPath              | Pod的多个容器使用同一个Volume时，这个非常有用                                                                 |
| FlexVolume           | 可自定义自己的Volume插件                                                                             |
| Projected Volume     | 将多个目录源映射到同一个目录中，支持secret、sownwardAPI和configMap                                              |

### Persistent Volume

PersistentVolume    (PV)和PersistentVolumeClaim    (PVC)提供了方便的持久化卷：PV提供网络存储资源，而PVC请求存储资源。

**Volume生命周期：**
Volume生命周期包括5个阶段:
　　1、Provisioning：创建PV，可以直接创建PV（静态方式），也可以使用StorageClass动态创建  
　　2、Binding：将PV分配给PVC
　　3、Using：Pod通过PVC使用该Volume  
　　4、Releasing：Pod释放Volume并删除PVC  
　　5、Reclaiming：回收PV，可以保留PV以便下次使用，也可以直接从云存储中删除

Volume的状态：  
　　Available：可用  
　　Bound：已经分配给PVC  
　　Released：PVC解绑但还未执行回收策略  
　　Failed：发送错误  

**PV：**  
pv三种访问模式：  
　　ReadWriteOnce（RWO）：是最基本的方式，可读可写，但只支持被单个Pod挂载。  
　　ReadOnlyMany（ROX）：可以以只读的方式被多个Pod挂载。  
　　ReadWriteMany（RWX）：这种存储可以以读写的方式被多个Pod共享。不是每一种存储都支持这三种方式，像共享方式，目前支持的还比较少，比较常用的是NFS。在PVC绑定PV时通常根据两个条件来绑定，一个是存储的大小，另一个就是访问模式。  

pv三种回收策略：  
　　Retain，不清理保留Volume（需要手动清理）  
　　Recycle，删除数据，即 rm -rf /thevolume/* （只有NFS和HostPath支持）  
　　Delete，删除存储资源，比如删除AWS    EBS卷（只有AWS    EBS,    GCE    PD,    AzureDisk和Cinder支持）  

**PVC：**  
PV是存储资源，而PersistentVolumeClaim    (PVC)    是对PV的请求。PVC跟Pod类似：Pod消费Node的源，而PVC消费PV资源；Pod能够请求CPU和内存资源，而PVC请求定大小和访问模式的数据卷。

**本地数据卷：**  
本地数据卷（Local    Volume）代表一个本地存储设备，比如磁盘、分区或者目录等。主要的应用场景包括分布式存储和数据库等需要高性能和高可靠性的环境里。

# 附录

## YAML编写

> 1、在同一个yaml文件中，使用"---" 开始，表明文档的开始  
> 2、在同一个yaml文件中，使用"..." 开始，表明文档的结束  
> 3、数组中所有成员都开始于 **相同的缩进级别**，且使用一个"-"(一个横杆  +  一个空格)  
> 4、字典由 **键：值** 的形式组成【冒号后必须有一个空格】  
> 5、Yaml大小写敏感
> 6、缩进只能使用空格，不能使用tab，不要求空格个数。
> 7、“#”用于注释
> 8、yaml允许表示三种格式：常量值，数组和字典
> 9、使用“!!”做强制类型转换
> 10、“>”在字符串中折叠换行，“|”保留换行符
> 11、“&”：定义锚点，“*”：引用锚点
> 12、合并：例子见下文

### 字典

> 格式：  
> 　　key: value

例：  

> key1：  
>     child-key1： value1  
>     child-key2： value2  

yaml还支持flow语法表示：  

> 　　key1：{child-key1：value1，child-key2：value2}

### 数组

使用一个短横线加一个空格代表数组项。

例： 

```
hobby:  
　　- Java  
　　- Go  
```

也可以写成：

```
 -  
 　- Java  
 　- Go  
```

相对复杂的例子：

```
companies:  
    -  
        id: 1  
        name: company1  
        price: 200W  
    -  
        id: 2  
        name: company2  
        price: 500W  
```

意思是companies属性是一个数组，每一个数组元素又是由id,name,price三个属性构成；  
数组也可以使用流式(flow)的方式表示：  

> companies: [{id: 1,name: company1,price: 200W},{id: 2,name: company2,price: 500W}]

### 合并

```
merge:
  - &CENTER { x: 1, y: 2 }
  - &LEFT { x: 0, y: 2 }
  - &BIG { r: 10 }
  - &SMALL { r: 1 }

sample1: 
    <<: *CENTER
    r: 10

sample2:
    << : [ *CENTER, *BIG ]
    other: haha

sample3:
    << : [ *CENTER, *BIG ]
    r: 100
```

## apiVersion含义

```
alpha
该软件可能包含错误。启用一个功能可能会导致 bug
随时可能会丢弃对该功能的支持，恕不另行通知

beta
软件经过很好的测试。启用功能被认为是安全的。
默认情况下功能是开启的
细节可能会改变，但功能在后续版本不会被删除

stable
该版本名称命名方式：vX 这里 X 是一个整数
稳定版本、放心使用
将出现在后续发布的软件版本中

v1
Kubernetes API 的稳定版本，包含很多核心对象：pod、service 等

apps/v1beta2
在 kubernetes1.8 版本中，新增加了 apps/v1beta2 的概念，apps/v1beta1 同理 DaemonSet，Deployment，ReplicaSet 和 StatefulSet 的当时版本迁入 apps/v1beta2，兼容原有的 extensions/v1beta1

apps/v1
在 kubernetes1.9 版本中，引入 apps/v1，deployment 等资源从 extensions/v1beta1, apps/v1beta1 和 apps/v1beta2 迁入 apps/v1，原来的 v1beta1 等被废弃。

apps/v1 代表：包含一些通用的应用层的 api 组合，如：Deployments, RollingUpdates, and ReplicaSets

batch/v1
代表 job 相关的 api 组合
在 kubernetes1.8 版本中，新增了 batch/v1beta1，后 CronJob 已经迁移到了 batch/v1beta1，然后再迁入 batch/v1

autoscaling/v1
代表自动扩缩容的 api 组合，kubernetes1.8 版本中引入。 这个组合中后续的 alpha 和 beta 版本将支持基于 memory 使用量、其他监控指标进行扩缩容

extensions/v1beta1
deployment 等资源在 1.6 版本时放在这个版本中，后迁入到 apps/v1beta2,再到 apps/v1 中统一管理

certificates.k8s.io/v1beta1
安全认证相关的 api 组合

authentication.k8s.io/v1
资源鉴权相关的 api 组合
```