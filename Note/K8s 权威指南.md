[TOC]

# 第一章 入门
## 1.1 Kubernetes 是什么（what）
```
它是一个全新的基于容器技术的分布式架构领先方案。是Google Borg的开源版本
```
### 基本知识
```
Service:
    1. unique name
    2. a virtual IP(Cluster IP, Service IP, VIP) and port
    3. able to provide some kind of remote service
    4. 被映射到了提供这种服务能力的一组容器应用上
Service 本身一旦创建之后就不再变化

Pod:
    1. 特殊容器Pause，其他容器称为业务容器
    2. 业务容器共享Pause容器的网络栈和Volume挂载卷
    3. 一组密切相关的服务应该进程放入同一个Pod 
```

---

```
集群管理:
Master Node:
    1. kube-apiserver, kube-controller-manager, kube-scheduler
    2. 以上进程实现了整个集群的资源管理，Pod调度，弹性伸缩，安全控制，系统监控，纠错等管理功能
    3. 自动管理

Worker Node:
    1. kubelet, kube-proxy
    2. 以上服务进程负责Pod的创建，启动，监控，重启，销毁，以及实现软件模式的负载均衡器
```

```
扩容和服务升级：
Replication Controller：
    1. 目标Pod的定义
    2. 目标Pod需要运行的副本数量（Replicas）
    3. 需要监控的目标Pod标签（Label）
```

## 1.2 为什么要用kubernetes （why）
```
1. 减小团队规模
2. 全面拥抱微服务
3. 屏蔽了底层网络细节
4. 超强的横向扩容能力
```

## 1.3 简单的例子
```
php + redis + mysql 留言板
```

## 1.4 K8S基本概念和术语
```
1. 资源对象：Node, Pod, Replication Controller, Service
2. 存储在etcd中
3. 通过kubectl或者API编程调用来执行增删改查操作
4. 自动化资源管理系统：通过跟踪对比etcd里面的“资源期望状态”和“实际资源状态”实现自动控制和自动纠错的高级功能
```
### 1.4.1 Master
```
Master是控制节点，运行一下关键进程
1. Kubernetes API Server（kube-apiserver）： 提供 HTTP REST API接口，所有资源的增删改查唯一入口，集群控制的入口进程
2. Kubernetes Controller Manager（kube-controller-manager）：所有资源对象的自动化控制中心
3. Kubernetes Scheduler（kube-scheduler）：资源调度进程
4. etcd Server： 保存资源对象数据
```

### 1.4.2 Node
```
1. kubelet: 负责Pod对应容器的创建、启停等任务
2. kube-proxy: 实现Kuberbetes Service 的通信与负载均衡机制的重要组件
3. Docker Engine (Docker): Docker 引擎，负责本机的容器创建和管理工作 
```
### 1.4.3 Pod
```
.           ____________________________
            |           Pod             |
            |   _____________________   |
            |   |       Pause       |   |
            |   |___________________|   |
            |   |  user container 1 |   |
            |   |___________________|   |
            |   |  user container 2 |   |
            |   |___________________|   |
            |___________________________|
.               Pod 组成与容器的关系
```

```
为什么涉及成这种组成结构？
1. Pause与业务无关且不易死亡，用它代表容器组的状态，而非N/M死亡率
2. Pod里面业务容器共享Pause容器的IP，共享Pause挂接的Volume,简化容器之间的通信，解决了容器之间的文件共享
```
```
一个Pod里面的容器和另外主机上的Pod容器能够直接通信。
两种类型的Pod：
1. 普通Pod：一旦被创建就会被存放在etcd中，随后会被K8S Master调度到某个具体的Node上并进行绑定
2. 静态Pod：存放在具体Node的一个具体文件中，不存放在etcd里面，只在这个具体的Node上运行。

#Note：
Pod里面某个container停止时，Kubernetes会自动检测到这个问题并且重新启动这个Pod

```
\# Node Pod Container 关系
```
graph TB
Master-->Node1
Master-->Node2
Master-->Node3
Node1 --> Pod1
Node1 --> Pod2
Node2 --> Pod3
Node2 --> Pod4
Node3 --> Pod5
Pod1  --> Container1
Pod1  --> Container2
Pod2  --> Container3
Pod2  --> Container4
Pod2  --> Container5
Pod3  --> Container6
Pod3  --> Container7
Pod3  --> Container8
Pod3  --> Container9
Pod4  --> Container10
Pod5  --> Container11
Pod5  --> Container12
```

### 1.4.4 Label（标签）
```
1. Label 是一个键值对，key和value可由用户自定义
2. Label 可以添加到各种资源对象上
3. 一个资源对象可以拥有多个Label
4. Label可以在创建的时候添加，也可以在运行时增加、删除
```
\# Label Selector
```
1. 基于等式
name = redis-slave
env != production:

2. 基于集合
name in (redis-master, redis-slave)
name not in (php-frontend)
```
\# Label Selector的几种应用场景
```
1. kube-controller进程通过资源对象RC上定义的Label Selector来筛选要监控的Pod副本数量
2. kube-proxy进程通过Service的Label Selector来选择对应的Pod，自动建立起每个Service到对应Pod的请求转发路由表
3. 通过对某些Node定义特定的Label，并且在Pod定义文件中使用NodeSelector这种标签调度策略，Kube-scheduler进程可以实现Pod"定向调度"的特性
```

### 1.4.5 Replication Controller （RC）
RC定义了一个期望场景：
```
1. Pod期待副本数
2. 用于筛选目标Pod的Label Selector
3. Pod副本数量小于预期数量的时候，哦那个与创建新Pod的Pod模板（template）
```
特性与作用：
```
1. Pod的创建与副本数量的自动控制
2. RC里包含完整额Pod定义模板
3. RC通过Label Selector机制实现对Pod副本的自动控制
4. 通过改变RC里的Pod副本数量，可以实现Pod的扩容或缩容功能
5. 通过改变RC里Pod模板中的镜像版本，可以实现Pod的滚动升级功能
```

### 1.4.6 Deployemt
Deployment 可以看做RC的升级,可以看到部署进度
```
典型应用场景：
    1. 创建一个Deployment对象来生成对应的Replica Set,并完成Pod副本的创建过程
    2. 检查Deployment的状态来看部署动作是否完成（Pod副本数量是否达到预期）
    3. 更新Deployment以创建新的Pod（比如镜像升级）
    4. 如果当前Deployment不稳定，则回滚到一个早先的Deployment版本
    5. 挂起或则恢复一个Deployment
```

### 1.4.7 Horizontal Pod Autoscaler （HPA、Pod自动横向扩容）
智能扩容
```
2种度量指标：
    1. CPUUtilizationPercentage
    2. 应用程序自定义的度量指标，比如服务在每秒内的相应请求数（TPS或QPS）
#Note
TPS: 每秒执行的事务数
QPS: req/sec = 请求数/秒，一般计算方式单个进程每秒请求服务器的成功次数
PV:  PV是指页面被浏览的次数
RPS: Requests Per Second
```


### 1.4.8 Service （服务）

#### 1.4.8.1 概述
    Pod RC Service 关系图
```
graph LR

A[Frontend Pod] --> B[Service]
B --> |Label: app=backend|C[Label Selector]
D[replicationController] --> |Label: app=backend replicas:3| C
C --> |Label: app=backend| E[Pod] 
C --> |Label: app=backend| F[Pod]
C --> |Label: app=backend| G[Pod]
```

    1. Service 定义了一个服务的入口访问地址
    2. Service与Pod通过Label Selector来实现“无缝对接”
    3. RC保证Service的服务能力和服务质量始终处于预期水平
    4. 前端Pod通过负载均衡算法决定访问后端Pod集群中的哪一个Pod
    5. DNS域名映射，pod或service重新create之后，重新映射（域名不变）
    
#### 1.4.8.2 Kubernetes 服务发现机制

    1. 早期通过注入环境变量来发现新的service
    2. Add On 增值包的方式引入了DNS系统，把服务名当作DNS域名

#### 1.4.8.3 外部系统访问Service
三种IP：

    #Node IP：Node 节点的IP地址
        每个节点的物理网卡IP地址
    #Pod IP：Pod的IP地址
        通过docker0 网桥的IP地址段进行分配，是一个虚拟的二层网络
    #Cluster IP: Service的IP地址
        它也是一个虚拟IP：
        1. 仅作用于Kubernetes这个对象
        2. 无法被ping, 因为没有“实体网络对象”响应
        3. Cluster IP只能结合Service Port 组成一个具体的通信端口，集群之外的节点如果要访问这个通信端口，则需要做一些额外的工作
        4. 集群内，Node IP、Pod IP与Cluster IP之间的通信，采用的是K8S自己设计的一种编程方式的特殊的路由规则，与我们熟知的IP路由有很大不同

```
NodePort
    1. 开放NodePort会在每个节点上开放一个监听端口
    2. 无法解决负载均衡的问题
    3. 在GCE公有云或者支持此特性的的驱动，将type=NodePort 改为type=LoadBalancer
```
### 1.4.9 Volume（存储卷）
Volume是Pod中能够被多个容器访问的共享目录

    1. K8S的Volume与Docker的Volume相似但不完全等价
    2. 定义在Pod中，被同一个Pod中的容器挂载
    3. 终止或者重启的时候，Volume中的数据不会丢失
    4. 支持多种类型的Volume：GlusterFS,Ceph等先进分布式文件系统
    
各种类型的Volume及其用途
```
1. emptyDir
    a. 临时空间，无需永久保留
    b. 长时间中间任务的中间CheckPoint的临时保存目录
    c. 一个容器需要从另外一个容器中获取数据目录

2. hostPath
    a. 容器的应用程序生成的日志文件需要永久保存的时候
    b. 需要访问宿主机文件系统的时候

# Note：
    a. 在不同的Node上具有相同配置的Pod可能会因为宿主机上的目录和文件不同而导致对Volume上目录和文件的访问结果不一致
    b. 如果使用了资源配额管理，则Kubernetes无法将hostPath在宿主机上使用的资源纳入管理

3. gcePersistentDisk
    a. Node节点需要是GCE虚拟机
    b. 虚拟机需要与PD(Google 公有云的永久磁盘 Persistent Disk，PD)

4.awsElasticBlockDisk
    a. Node 节点需要是AWS EC2实例
    b. 这些EC2实例需要与EBS volume在相同的regin和aailability-zone中
    c. EBS 只支持单个EC2实例mount一个Volume

5. NFS
    需要在系统中部署一个NFS Server
    
6. 其他类型的Volume
    a. iscsi            使用iSCSI存储设备上的目录挂载到Pod中
    b. flocker          使用Flocker来管理存储卷
    c. glusterfs        使用开源的GlusterFS网络文件系统的目录挂载到Pod中
    d. rbd              使用Linux块设备共享存储（Rados Block Device）挂载到Pod中
    e. gitRepo          通过挂载一个空目录，并从GIT库clone一个git repository以供使用
    f. secret:          一个secret volume用于为Pod提供加密信息，你可以将定义在Kubernetes中的secret直接挂载为文件让Pod访问。它是通过tmfs实现的，所以不会持久化
```

### 1.4.10 Persistent Volume (PV)
可以理解成K8S集群中的网络存储,与Volume类似，但有一下区别：

    1. PV只能是网络存储，不属于任何Node，但可以在每个Node上访问
    2. PV并不是定义在Pod上的，而是独立于Pod的定义
    3. PV目前只有几种类型：GCE Persistent Disks，NFS，RBD，iSCSCI，AWS ElasticBlockStore，GlusterFS等

accessModes

    1. ReadWriteOnce    读写权限、并且只能被单个Node挂载
    2. ReadOnlyMany     只读权限、允许被多个Node挂载
    3. ReadWriteMany    读写权限、允许被多个Node挂载
    
PV状态

    1. Available    空闲状态
    2. Bound        已经绑定到某个PVC
    3. Released     对应的PVC已经删除，但资源还没有被集群回收
    4. Failed       PV自动回收失败

\# Note
需要先定义 PersistentVolumeClaim （PVC），然后在Pod的Volume定义中引用上述PVC即可

### 1.4.11 Namespace（命名空间）
```
1. 实现资源隔离
2. 如果不特别指明Namespace ，Pod、RC、Service等资源对象会默认创建到default Namespace
```
### 1.4.12 Annotation（注解）
    1. Annotation与Label类似，使用key/value键值对定义
    2. Label有严格的命名规则，定义的对象是Metadata，并且用于Label Selector 
    3. Annotation则是用户任意定义的“附加”信息，便于外部工具查找，K8S自身也会通过Annotation标记一些资源对象的特殊信息

通常用Annotation记录的信息
```
1. build信息、release信息、Docker镜像信息，时间戳、release id号、PR号、镜像hash值、docker registry地址等
2. 日志库、监控库、分析库等资源库的地址信息
3. 程序调试工具信息，例如工具名称、版本号等
4. 团队的联系信息




```

### 1.4.13 小结
    1. 辅助配置资源对象     LimitRange、ResourceQuota
    2. 系统内部对象         Binding、Event

---



# 第二章 K8S实践指南
# 2.1 K8S安装与配置
### 2.1.1 安装K8S
```
软件：
1. Docker       https://www.docker.com
2. etcd         https://github.com/coreos/etcd/releases
3. Kubernetes   https://github.com/kubernetes/kuberbetes/releases
Master部署:
etcd、kube-api-server、kube-controller-manager、kube-scheduler服务进程
Node部署：
kubectl、kube-proxy
K8S提供了 all-in-one 的 hyperkube程序来完成对以上服务程序的启动
```

### 2.1.2 配置和启动Kubernetes服务
Master 上的 etcd、kube-apiserver、kube-controller-manager、kube-shceduler服务

```
1. etcd
2. kube-apiserver服务               需要在/etc/kunernetes/apiserver 里面的KUBE_API_ARGS里面指定etcd service 的地址和端口
3. kube-controller-manager服务      依赖于kube-apiserver    需要在/etc/kubernetes/controller-manager指定Master的地址和端口
4. kube-scheduler 服务              依赖于kube-apiserver    需要在/etc/kubernetes/scheduler指定Master的地址和端口
```
Node 上的kubelet、kube-proxy服务
```
1. kubelet服务      依赖于Docker服务    需要在/etc/kubernetes/kubelet指定Master地址和端口
2. kube-proxy服务   依赖于network服务   需要在/etc/kubernetes/proxy指定Master地址和端口
```
\# Note
kubelet 默认采用想Master自动注册Node的机制，在Master上查看各个Node的状态，当状态为ready表示Node已经成功注册并且状态为可用


### 2.1.3 Kubernetes集群的安全设置
```
1. 基于CA签名的双向数字证书
2. 基于HTTP BASE 或token的简单认证方式
```

### 2.1.4 Kubernetes 的版本升级
```
1. 获取最新的二进制文件
2. 逐个隔离Node，更新kubelet和kube-proxy服务文件，然后重启这两个服务
3. 更新Master的kube-apiserver、kube-controller-manager、kube-scheduler服务文件并重启
```


### 2.1.5 内网中的Kubernetes相关配置

```
1. Docker Private Registry (私有Docker 镜像库)      参考https://docs.docker.com.registry/deploying/
2. kubelet配置                                      kubelet 启动参数KUBELET_ARGS --pod_infra_container_image=(gcr.io/google_coontainers/pauser-amd64:3.0 || kubeguide/google_coontainers/pauser-amd64:3.0)  then restart kubelet
```

### 2.1.6 Kubernetes 核心服务配置详解
可以通过cmd --help查看
kube-apiserver、kube-controller-manager、kube-scheduler、kubelet、kube-proxy
```
1. 公共配置参数
2. ............
```

### 2.1.7 Kubernetes 集群网络配置方案
```
1. flannel          覆盖网络
2. Open vSwitch     虚拟机交换
3. 直接路由
```

## 2.2 kubectl 命令行工具用法详解

### 2.2.1 用法概述
```
kubectl [command] [type] [name] [flags]
```
### 2.2.2 kubectl子命令
```
[command]:
create、delete、apply、get、describe、log、run等
```

### 2.2.3 kubectl参数列表

### 2.2.4 kubectl输出格式
```
kubectl get pod podname -o wide/yaml/json/name/....
```

### 2.2.5 kubectl 操作示例

## 2.3 GuestBook示例：Hello World

```
1. redis-master
2. guestbook-redis-slave
3. guestbook-php-frontend
```

### 2.3.1 创建 redis-master RC和Service

### 2.3.2 创建 redis-slave RC和Service

### 2.3.3 创建 frontend RC和Service

### 2.3.4 通过浏览器访问frontend 页面

## 2.4 深入掌握Pod
### 2.4.1 Pod定义详解
### 2.4.2 Pod的基本用法
```
Kubernetes系统中对长时间运行容器的要求是：其主程序需要一直在前台执行，如果放在后台运行，kubelet会认为Pod执行结束并立即销毁该Pod，如果定义了ReplicationController，在Pod会陷入无限停止-启动的循环中
对于不能前台启动的应用，使用Supervisor可以满足K8S对容器的要求，参见http://supervisord.org
```

### 2.4.3 静态Pod

静态Pod是由kubelet进行管理的仅存在于特定Node上的Pod，他们不能通过API Server进行管理， 无法与ReplicationController、Deployment或者DaemonSet进行关联，并且kubeket也无法对他们进行健康检查，静态Pod总是由kubelet进行创建，并且总是在kubelet所在的Node上运行

```
创建静态Pod的两种方式：配置文件或者HTTP方式
1. 配置文件方式
2. 
```
### 2.4.4 Pod容器共享Volume
```
同一个Pod中的多个容器能够共享Pod级别的Volume
```

### 2.4.5 Pod的配置管理
1. ConfigMap: 容器应用的配置管理
```
a. 生成为容器内的环境变量
b. 设置容器启动命令的启动参数
c. 以Volume的形式挂载为容器内部的文件或目录
```
2. ConfigMap的创建:yaml 文件方式
3. ConfigMap的创建:kubectl命令行的方式
```
a. --from-file
    kubectl create configmap NAME --from-file=[key=]source --from-file=[key=]source
b. --from-file 参数从目录进行创建，该目录下每个文件名都被设置为key，文件的内容被设置为value
    kubectl create configmap NAME --from-file=config-files-dir
c. --from-literal从文本文件创建，直接将指定的key#=value创建为ConfigMap的内容
    kubectl create configmap NAME --from-literal=key1=value1 --from-literal=key2=value2
```
4. ConfigMap的使用：环境变量方式
5. ConfigMap的使用：volumeMount模式
6. 使用ConfigMap的限制条件
```
a. ConfigMap必须在Pod之前创建
b. ConfigMap可以定义在某个Namespace,只有处于同一个Namespace的Pod可以引用它
c. ConfigMap中的配额管理还未实现（K8S v1.3）v1.11支持限制namespace下configmap的数量
d. kubelet支持可以被API Server管理的Pod使用ConfigMap,静态Pod无法引用ConfugMap
e. 在Pod对ConfigMap进行挂载操作的时候，容器内部只能挂载为目录，无法挂载为文件，如果目录本身还存在文件，则会被覆盖，如果需要保留，则需要做额外操作

```

### 2.4.6 Pod生命周期和重启策略
```
1. Always:容器失效时，有kubelet自动重启该容器
2. OnFailure: 当容器终止运行且退出代码不为0时，由kubelet自动重启该容器
3. Never: 不论容器运行状态如何，kubelet都不会重启该容器
```
### 2.4.7 Pod健康检查
```
1. LivenessProbe探针：判断容器是否存活，如果没有设置值，那么kubelet认为容器的LivenessProbe返回的值永远是“Success”
    a. ExecAction:
    b. TCPSocketAction:
    c. HTTPGetAction: 状态码为200<=x<400认为正常
2. ReadinessProbe：用于判断容器是否启动完成（ready状态），可以接收请求。
# 需要设置的参数
    a. initialDelaySeconds: 启动容器后进行首次健康检查的等待时间，单位为秒
    b. timeoutSeconds: 健康检查发送请求后等待响应的时间，单位为秒。若超时，kubelet会认为容器已经无法提供服务
# 从实际使用的情况来看，会有探测失败x次才会认为容器无法提供服务
```

### 2.4.8 玩转Pod调度
#### 2.4.8.1 RC、Deployment：全自动调度
```
1. NodeSelector:定向调度，调度到指定label的Node
2. NodeAffinity：亲和性调度，是将来替换NodeSelector的下一代调度策略
    NodeAffinity 增加了In、NotIn、Exists、DoesNotExist、Gt、Lt等操作符来选择Node
    a. RequiredDuringSchedulingRequiredDuringExecution:类似于NodeSelector，但在Node不满足条件时，系统将从那个该Node上移除之前调度上的Pod
    b. RequiredDuringSchedulingIgnoredDuringExecution:类似RequiredDuringSchedulingRequiredDuringExecution，区别是在Node不满足条件时，系统不一定从该Node上移除之前调度上的Pod
    c. PreferredDuringSchedulingIgnoredDuringExecution:指定在满足调度条件的Node中，哪些Node应更优先地进行调度。同时在Node不满足条件时，系统不一定从该Node上移除之前调度上的Pod
3. 未来版本将加入 Pod Affinity的设置，判断是否有其他Pod在这个Node上运行。也就是Pod相关调度
```
#### 2.4.8.2 DaemonSet：特定场景调度
用于管理在集群中每个Node上仅运行一份Pod的副本实例
    
    在每个Node上运行一个monitor
```
graph TD

A[Kubernetes Master] --> |Node1|B[monitor Pod]
A[Kubernetes Master] --> |Node2|C[monitor Pod]
A[Kubernetes Master] --> |Node3|D[monitor Pod]
```
\# 应用场景
    
```
1. 在每个Node上运行一个GlusterFS存储或者Ceph存储的daemon进程
2. 在每个Node上运行一个日志采集程序，例如fluentd或者logstach
3. 在每个Node上运行一个健康采集程序，采集该Node的运行性能数据
```

#### 2.4.8.3 Job：批处理调度
```
graph TD
A(Work Item) --> B[Job]
C(Work Item) --> D[Job]
E(Work Item) --> F[Job]
```
```
Job Template Expansion 模式：Job于 work item 一一对应，通常用于数据量比较大，work item数量少的场景
```
```
graph TD
A(Work Item) --> B[Work Queue]
C(Work Item) --> B[Work Queue]
E(Work Item) --> B[Work Queue]
B --> D[Job]
D --> F[pod1]
D --> G[pod2]
D --> H[pod3]

```
```
Queue with Pod Per Work Item模式:采用一个任务队列存放Work Item，一个job对作为一个消费者去完成这些Work item，每个job启动N个Pod，每个Pod对应一个Work Item
```
```
graph TD
A(Work Item) --> B[Work Queue]
C(Work Item) --> B[Work Queue]
E(Work Item) --> B[Work Queue]
B --> D[Job]
D --> F[pod1]
D --> G[pod2]

```
```
Queue with Variable Pod Count模式:采用一个任务队列存放Work Item，一个job对作为一个消费者去完成这些Work item，每个job启动Pod的数量是可变的
``` 
```
Single Job with Static Work Assignment
```
```
1. 一个job 多个 Pod
2. 静态分配任务项
```

模式名称 | 是否是一个Job | Pod 的数量少于Work item | 用户程序是否要做相应的修改 | Kubernetes 是否支持
---|---|---|---|---
Job Template Expansion | / | / | 是 | 是
Queue with Pod Per Work Item | 是 | / | 有时候需要 | 是 
Queue with Variable Pod Count | 是 | / | / | 是
Single Job with Static Work Assignment | 是 | / | 是 | /

```
\# 关于并行
1. Non-parallel Jobs
    one job one pod
2. Parallel Jobs with a fixed completion count
    并行job启动多个pod
    job.spec.completions 设定pod数量
    job.spec.parallelism 控制并行度
3. Parallel Jobs with a work queue
    并行job需要独立的Queue
    work item 都在一个queue中存放
    不能设置job.spec.completions
    job有以下特性
        1. 每个Pod能独立判断和决定是否还有任务项需要处理
        2. 如果某个pod正常结束，则pod不会再启动新的Pod
        3. 如果一个Pod成功结束，则此时应该不存在其他Pod还在干活的情况，他们都应该处于即将结束、退出的状态
        4. 如果所有Pod都结束了，且至少有一个Pod成功结束，则整个Job算是成功结束
```

\# Other
```
Linux Cron定时任务
流程类批处理框架
```

### 2.4.9 Pod的扩容和缩容
```
kubectl scale rc redis-slave --replicas=3 -n core
```
### 2.4.10 Pod的滚动升级
```
rolling-update:
kubectl rolling-update
    创建新的RC
    自动控制旧的RC中副本的数量减少到0
    的RC中的Pod副本的数量从增加到目标值
    新旧RC需要在同一个命名空间
注意事项：
    1. 新旧RC的name不能相同
    2. selector中至少有一个Label与旧的RC的Label不同，以标识其为新的RC
    直接指定新的image来完成升级 kubectl rolling-update redis
```
## 2.5 深入掌握Service
```
    1. 为一组功能相同的容器提供一个统一的入口地址
    2. 将请求进行负载均衡分发到后端各个容器应用上
    3. Service的详细说明：
        Service的负载均衡
        外网访问
        DNS服务的搭建
        Ingress 7层路由机制
```
### 2.5.1 Service 的详细定义
yaml格式的Service定义文件的完整内容如下
```
apiVersion: v1          //Required
kind: Service           //Required
metadata:               //Required
    name: string        //Reuqired
    namespaces: string  //Required
    labels:
        - name: string
    annotation:
        - name: string
spec:                   //Required
    selector: []        //Required
    type: string        //Required
    clusterIP: string
    sessionAffinity: string
    ports:
    - name: string
        protocol: string
        port: int
        targetPort: int
        nodePort: int
    status:
        loadBalancer:
            ingress:
                ip: string
                hostname: string
```

### 2.5.2 Service 基本用法
```
    对外提供服务通过TCP/IP机制及监听IP和端口号来实现
    1. kubectl expose rc webapp
    2. kubectl create -f webapp-svc.yaml
    
    负载分发策略：
    1. RoundRobin： 轮询模式，讲请求转发到各个pod上（default策略）
    2. SessionAffinity：基于客户端IP地址进行进行会话保持模式，即相同的会话会被转发到同一个Pod上
```

### 2.5.3 集群外部访问Pod或Service
将Pod或Service的端口号映射到宿主机，以使得客户端应用能够通过物理机访问容器应用
```
    1. 讲容器应用的端口号映射到物理机
        a. 设置容器级别的hostPort，将容器应用的端口号映射到物理机上：
        spec:
          containers:
          - name: webapp
            image: tomcat
            ports:
            - containerPort: 8080
              hostPort: 8081
        b. 设置容器级别的hostNetwork=true,则默认hostPort等于containerPort，如果指定了hostPort，则hostPort必须等于containerPort的值
    
    2. 将Service 的端口号映射到物理机
        a. 通过设置nodePort映射到物理机，同事设置Service的类型为NodePort:
        apiVersion: v1
        kind: Service
        metadata:
          name: webapp
        spec:
          type: NodePort
          ports:
          - port: 8080
            targetPort: 8080
            nodePort: 8081
          selector:
            app: webapp
        b. 通过设置LoadBlancer映射到云服务商提供的LoadBalancer地址，对该Service的访问请求将会通过LoadBalancer转发到后端Pod上，负载分发的实现方式则依赖于云服务提供商的LoadBalancer的实现机制
        kind: Service
        apiVersion: v1
        metadata:
          name: my-service
        spec:
          selector:
            app: MyApp
          ports:
          - protocol: TCP
            port: 80
            targetPort: 9376
            nodePort: 30061
          clusterIP: 10.0.171.239
          loadBalancerIP: 79.11.24.19
          type: loadBalancer
        status:
          loadBalancer:
            ingress:
            - ip: 146.148.47.155
```
### 2.5.4 DNS服务搭建指南
```
Kubernetes 提供的虚拟DNS服务名为skydns，由四个组件组成
    1. etcd: DNS 存储
    2. kube2sky：讲Kubernetes Master中的Service（服务）注册到etcd
    3. skyDNS：提供DNS域名解析服务
    4. healthz：提供对skydns服务的健康检查功能
```
![Kubernetes DNS服务的总体架构](https://github.com/rayshaw001/common-pictures/blob/master/K8S/K8S%20DNS%20Service%20Diagram.jpg?raw=true)

#### 2.5.4.1 skydns配置文件说明
skynds-rc.yaml、skydns-svc.yaml
```
    几个主要的容器：
        1. etcd
        2. kube2sky
        3. skydns
        4. heakthz
    需要修改的几个配置参数
        1. kube2sky容器需要访问Kubernetes Master，所以要设置参数--kube_master_url的值为http://192.168.18.3:8080
        2. kube2sky容器和skydns容器的启动参数--domain，设置Kubernetes集群中Service所属的域名
        3. skydns的启动参数-addr=0.0.0.0:53表示使用本机TCP和UDP的53端口提供服务
```
skydns-svc.yaml
```
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app:kube-dns
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 169.169.0.100
  ports:
  - name: dns
    port:53
    protocol: UDP
  - name: dns-tcp
    port: 53
    protocol: TCP
```
\# Note
1. skydns服务使用的clusterIP需要手动指定一个固定的IP地址，每个Node的kubelet进程都将使用这个IP地址，不能通过Kubernetes自动分配
2. 这个IP地址需要在kube-apiserver启动参数--service-cluster-ip-range指定的IP地址范围内
3. 在创建skydns容器之前，先修改每个Node上kubelet的启动参数

#### 2.5.4.2 修改每台Node上的kubelet启动参数
```
    1. --cluster_dns=169.168.0.100: 为DNS服务的ClusterIP地址
    2. --cluster_domain=cluster.local: 为DNS服务中设置的域名
```

#### 2.5.4.3 创建skydns RC 和 Service

#### 2.5.4.4 通过DNS查找Service
通过创建一个带有nslookup工具的Pod来验证DNS服务是否能正常工作（container busybox）

#### 2.5.4.5 DNS服务的工作原理解析
1. kube2sky容器应用通过调用Kubernetes Master 的API获得集群中所有Service的信息，并持续监控新Service的生成，然后写入etcd
2. 根据kubelet启动参数的设置（--cluster_dns），kubelet会在每个新创建的Pod中设置DNS域名解析配置文件/etc/resolv.conf文件，在其中增加了一条nameserver配置和一条search配置：
    nameserver 169.169.0.100
    search default.svc.cluster.local svc.cluster.local cluster.local localdomain
3. 最后，应用程序就能够像访问网站域名一样，仅仅通过服务的名字就能访问到服务了

### 2.5.5 Ingress: HTTP 7层路由机制
![ingress sample](https://github.com/rayshaw001/common-pictures/blob/master/K8S/ingress%20sample.jpg?raw=true)

#### 2.5.5.1 创建Ingress Controller
使用Nginx来实现一个Ingress Controller，需要实现的基本逻辑如下
1. 监听apiserver，获取全部ingress的定义
2. 基于ingress的定义，生成Nginx所需的配置文件/etc/nginx/nginx.conf
3. 执行nginx -s reload命令 ，重新加载nginx.conf配置文件的内容

#### 2.5.5.2 定义Ingress

#### 2.5.5.3 访问http://mywebsite.com/web

#### 2.5.5.4 Ingress的发展路线
1. 支持跟多TLS选项，例如SNI、重加密等
2. 支持L4和L7负载均衡策略（目前只支持HTTP层的规则）
3. 支持更多的转发规则（目前仅支持基于URL路径的），例如重定向规则、会话保持规则等。

---
# 第三章 Kubernetes核心原理
## 3.1 Kubernetes API Server原理分析
1. 提供资源对象（Pod、RC、Service）的增删改查以及Watch等HTTP Rest接口
2. 是整个系统的数据总线和数据中心
3. 实际群管理的API入口
4. 是资源配额控制的入口
5. 提供了完备的集群安全机制

### 3.1.1 Kubernetes API Server 概述
1. --insecure-port （默认8080）
2. --secure-port    （默认6443）
3. 通常通过kubectl来与Kubernetes API Server交互，它们之间的接口是REST调用
```
/api/v1
/api/v1/pods
/api/v1/services
/api/v1/replicationcontrollers
```

### 3.1.2 独特的Kubernetes Proxy API 接口
/api/v1/proxy/nodes/{name}/*  pods\stats\spec and etc
/api/v1/{namespaces}/pods/{name}/proxy
/api/v1/proxy/namespaces/{namespace}/pod/{name}
/api/v1/proxy/namespaces/{namespace}/services/{name}

### 3.1.3 集群功能模块之间的通信
1. Kubernetes API Server作为集群核心，负责各模块之间的通信
2. 各模块通过API Server将信息存入etcd
3. 信息交互通过API Server提供的REST 接口实现（GET LIST WATCH）
4. 为了缓解API Server的压力。某些信息会被缓存到本地

## 3.2 Controller Manager 原理分析
1. Controller Manager是为集群内部的管理中心
2. 负责集群内的Node Pod副本 服务端点（Endpoint）、命名空间（Namespace）、服务账号（Service Account）资源定额（ResourceQuota）等的管理
3. 处理意外宕机、执行自动化修复流程
![Controller Manager](https://github.com/rayshaw001/common-pictures/blob/master/K8S/Controller%20Manager.jpg?raw=true)

### 3.2.1 Replication Controller
```
职责：
1. 确保当前集群中有且仅有N个Pod实例                         （重新调度）
2. 通过调整RC的spec.replicas属性值来实现系统扩容或者缩容    （弹性伸缩）
3. 通过改变RC中的Pod模板来实现滚动升级                      （滚动更新）
```

### 3.2.2 NodeController
etcd中存储的节点信息包括    节点健康状况、节点资源、节点名称、节点地址信息、操作系统版本、Docker版本、kubelet版本等
节点健康状况包括            就绪（True）    未就绪（False）     未知（Unknown）

Node Controller核心工作流程图：
```
graph TD

S[START] --> A
A["如果Controller Manager设置了 --cluster-cidr 参数，则为每个Node配置 spec.PodCIDR "] --> B["逐个读取Node信息，并和本地nodeStatusMap做比较"]
B --> |"没有收到节点信息或第一次收到节点信息，或在该处理过程中节点状态变成非“健康”状态"| C["用Master节点的系统时间作为探测时间和节点状态变化时间"]
B --> |"在指定时间内收到新的节点信息，且节点状态发生变化"| D["用Master节点的系统时间作为探测时间和节点状态变化时间"]
B --> |"在指定时间内收到新的节点信息，且节点状态没有发生变化"| E["用Master节点的系统时间作为探测时间,用上次节点信息中的节点状态变化时间作为该节点的状态变化时间"]
C --> F["如果在某一段时间内没有收到节点状态信息，则设置节点状态为未知"]
D --> F
E --> F
F --> G["删除节点或者同步节点信息"]
G --> H[END]
```


### 3.2.3 ResourceQuota Controller
支持三个层次的资源配额管理
1. 容器级别：       CPU和Memory
2. Pod级别：        可以对一个Oid内所有容器的可用资源进行限制
3. Namespace级别    为Namespace级别的资源限制，包括
    a. Pod数量
    b. Replication Controller 数量
    c. Service 数量
    d. ResourceQuota 数量
    e. Secret 数量
    f. 可持有的PV（Persistent Volume）数量

ResourceQuota Controller 流程图
![ResourceQuota Controller](https://github.com/rayshaw001/common-pictures/blob/master/K8S/ResourceQuota%20Controller.jpg?raw=true)


### 3.2.4 Namespace Controller

1. 通过 API Server 创建namespace并保存在etcd
2. 可设置删除期限，到期namespace状态会被设置成“Terminating”并保存到etcd
3. 删除namespace会同时Namespace Controller会删除该namespace下面的ServiceAccount 、 RC 、 Pod 、 Secret 、 PersistentVolume 、 ListRange 、 ResourceQuota和Event等资源对象
4. namespace状态被设置成“Terminating” 之后，由Admission Controller的NamespaceLifecycle插件来阻止该Namespace创建新的资源
5. Namespace中所有的资源对象被删除之后，由Namespace Controller对该Namespace 之心finalize操作，删除Namespace的spec.finalizers域中的信息
6. 如果spec.finalizers域值是空的，那么Namespace Controller 将通过API Server删除该Namespace资源

### 3.2.5 Service Controller 与 Endpoint Controller
![Service EndPoint Pod](https://github.com/rayshaw001/common-pictures/blob/master/K8S/Service%20EndPoint%20Pod.JPG?raw=true)

```
1. Endpoints 表示了一个Service对应的所有的Pod副本的访问地址
2. Endpoints Controller就是负责生成和维护所有Endpoints对象的控制器
3. 负责监听Service和对应的Pod副本的变化
4. 如果Service被删除，则删除和该Service同名的Endpoints对象
5. 如果Service被创建或者修改，则根据该Service信息获得相关的Pod列表，然后创建或者更新对应的Endpoints对象
6. 如果监测到Pod的事件，则更新他所对应的Service的Endpoints对象（增、删、改对应的Endpoint条目）
7. Endpoints在哪里被使用呢？    -------------       每个Node上的kubeproxy进程，kube-proxy进程获取每个Service的Endpoints，实现了Service的负载均衡功能

8. Service Controller的作用，它是K8s集群与外部的云平台之间的一个接口控制器
    Service Controller监听Service的变化
    如果是一个LoadBalancer类型的Service（externalLoadBalancers=true），则Service Controller确保外部的云平台上改Service对应的LoadBalancer实例被相应地创建、删除及更新路由转发表（根据Endpoints的条目）
```

## 3.3 Scheduler 原理分析
```
1. 承上：接收Controller Manager创建的新的Pod，为其安排一个目标Node
2. 启下：目标Node上的kubelet服务进程解挂后继的工作，负责Pod生命周期中的“下半生”
3. 涉及的三个对象：待调度Pod列表、可用Node列表、调度算法和策略
```


Kubernetes Scheduler当前提供的默认调度流程分为以下两步：
1. 预选调度过程，即便里所有目标Node，筛选出符合要求的候选节点。为此，Kubernetes内置了多种预选策略（xxx Predicates）供用户选择
2. 确定最优节点，在第1步的基础上，采用优选策略（xxx Priority）计算出每个候选节点的积分，积分高者胜出
\# 即先选择出符合条件的节点，再从符合条件的节点中选出最优节点
Kubernetes Scheduler的调度流程是通过插件方式加载的“调度算法提供者”（AlgorithmProvider）具体实现的。一个AlgorithmProvider其实就是包括了一组预选策略与一组有限选择策略的结构体，注册AlgorithmProvider的函数如下：
    func RegisterAlgorithmProvider（name string, predicateKeys,priorityKeys util.StringSet）
    他包含三个参数：
        name string：   算法名
        predicateKeys： 算法用到的预选策略集合
        priorityKeys：  为算法用到的优选策略集合
    
    AlgorithmProvider加载的预选策略Predicates包括：
        PodFitsPorts（PodFitsPorts）
        PodFitsResources（PodFitsResources）
        NoDiskConflict（NoDiskConflict）
        MatchNodeSelector（PodSelectorMatches）
        HostName（PodFitsHost）
    每个节点只有通过前面提及的5个默认预选策略后，才能初步被选中，进入下一个流程。

```
Scheduler中可用的预选策略包含：
1. NoDiskConflict
判断备选Pod的GCEPersistentDisk或AWSElasticBlockStore和备选的节点中已存在的Pod是否存在冲突，检测过程如下：
    A. 读取备选Pod的所有Volume信息（pod.spec.volumes），对每个Volume执行以下步骤进行冲突检测。
    B. 如果该Volume是GCEPersistentDisk，如果该Volume是GCEPersistentDisk/AWSElasticBlockStore，则将Volume进行比较，如果范县相同的GCEPersistentDisk/AWSElasticBlockStore，则返回false，表明磁盘存在冲突，检查结束，返回给调度器该节点不合适作为备选Pod。
    C. 如果检查完备选Pod的所有Colume均为发现冲突，则返回true，表明不存在磁盘冲突，反馈给调度器该备选节点适合备选Pod。
2. PodFitsResources
判断备选节点的资源是否满足备选Pod的需求，检测过程如下。
    A. 计算备选Pod和节点中已存在Pod的搜有容器的需求资源（内存和CPU）的总和
    B. 获得备选节点的状态信息，其中包含节点资源信息
    C. 如果备选Pod和节点中已存在Pod的所有容器的需求资源（内存和CPU）的总和，超出了备选节点拥有的资源，则返回false，表明备选节点不适合备选Pod，否则返回true，表明备选节点适合备选Pod
3. PodSelectorMatches
判断备选节点是否包含备选Pod的标签选择器指定的标签
    A. 如果Pod没有指定spec.nodeSelector标签选择器，则返回true
    B. 否则，获得备选节点的标签信息，判断节点是否包含备选Pod的标签选择器（spec.nodeSelector）所指定的标签，如果包含，则返回true，否则返回false
4. PodFitsHost
    判断备选Pod的spec.nodeName域所指定的节点名称和备选节点的名称是否一致，如果一致，则返回true，否则返回false。
5. CheckNodeLabelPresence
如果用户在配置文件中指定了该策略，则Scheduler会通过RegisterCustomFitPredicate方法注册该策略。该策略用于判断策略列出的标签在备选节点中存在时，是否选择该备选节点。
    A. 读取备选节点的标签列表信息
    B. 如果策略配置的标签列表存在于备选节点的标签列表中，且策略配置的presence值为false，则返回false，否则返回true；如果策略配置的标签列表不存在于备选节点的标签列表中，且策略配置的presebce值为true，返回false，否则返回true。
6. CheckServiceAffinity
    如果用户在配置文件中指定了该策略，则Scheduler会通过RegisterCustomFitPredicate方法注册该策略。该策略用于判断备选节点是否包含策略指定的标签，或包含和备选Pod在相同Service和Namespace下的Pod所在节点的标签列表。如果存在，则返回ture，否则返回false。
7. PodFitsPorts
    判断备选Pod所用的端口列表中的端口是否在备选节点中已被占用，如果被占用，则返回false，否则返回true。
```
```
Scheduler中的优选策略：
1. LeastRequestedPriority 该策略用于从备选节点列表中选出资源消耗最小的节点
    A. 计算出所有备选节点删运行的Pod和备选Pod的CPU占用量totalMilliCPU
    B. 计算出所有备选节点上运行的Pod和备选Pod的内存占用量ttalMemory
    C. 计算每个节点的得分，计算规则大致如下
    score=int(((nodeCpuCapacity-totalMilliCPU)*10)/nodeCpuCapacity+((nodeMemoryCapacity-totalMemory)*10)/nodeCpuMemory)/2)
2. CalculateNodeLabelPriority
    如果用户在配置文件中指定了该策略，则scheduler会通过RegisterCustomerPriorityFunction方法注册改策略。该策略用于判断策略列出的标签在备选节点中存在时，是否选择该备选节点。如果备选节点的标签在优选策略的标签列表中且优选策略的presence值为true，或者备选节点的标签不在优选策略的标签列表中且优选策略的presence值为false，则备选节点score=10，否则备选节点score=0
3. BalancedResourceAllocation 该优选策略用于从备选节点列表中选出各项资源使用率最均衡的节点
    A. 计算出所有备选节点删运行的Pod和备选Pod的CPU占用量totalMilliCPU
    B. 计算出所有备选节点上运行的Pod和备选Pod的内存占用量ttalMemory
    C. 计算每个节点的得分，计算规则大致如下
    score=int(10-math.Abs(totalMilliCPU/nodeCpuCapacity-totalMemory/nodeMemoryCapacity)*10)
```


## 3.4 kubelet运行机制分析
1. 用于处理Master节点下发到本节点的任务
2. 管理Pod及Pod中的容器
3. 每个kubelet进程会在API Server上注册节点自身的信息
4. 定期向Master节点汇报节点资源的使用情况
5. 通过cAdvisor监控容器资源

### 3.4.1 节点管理
```
--api-servers:      告诉kubelet API Server的位置
--kubeconfig:       告诉kubelet在哪儿可以找到用于访问API Server的证书
--cloud-provider:   gaoshu kubelet如何从云服务商（IaaS）那里读取到和自己相关的元数据
```

kubelet 在启动的时候通过API Server注册节点信息，并定时想API Server发送节点的新消息，API Server在接收到这些信息后，将这些信息写入etcd。通过kubelet的启动参数“node-status-update-frequency”设置kubelet每隔多少时间向API Server报告节点状态，默认为10秒.

### 3.4.2 Pod管理
```
    kubelet通过以下几种方式获取自身Node上所要运行的Pod清单
1. 文件：kubelet启动参数“--config”指定的配置文件目录下的文件（默认目录为“/etc/kubernetes/manifests/”）。通过--file-check-frequency设置检查该文件目录的时间间隔，默认为20秒
2. HTTP端点（URL）：通过“--manifest-url”参数设置。通过--http-check-frequency设置检查该HTTP端点的时间间隔，默认为20秒
3. API Server：kubelet 通过API Server监听etcd目录，同步Pod列表    
```

```
kubelet 监听etcd的修改，如果etcd中Pod信息变更（如创建、修改Pod任务），则做一下处理
1. 为该Pod创建一个数据目录
2. 从API Server 读取该Pod清单
3. 为该Pod挂载外部卷
4. 下载Pod用到的Secret
5. 检查已经运行在节点中的Pod，如果该Pod没有容器或Pause容器没有启动，则先停止Pod里所有容器的进程。如果Pod中有需要删除的内容，则删除这些容器。
6. 用kubernetes/pause镜像为每个Pod创建一个容器。该Pause容器用于接管Pod中所有其他容器的网络。没创建一个新的Pod，kubelet都会先创建一个Pause容器，然后创建其他容器
7. 为每个Pod容器做如下处理
    1) 为容器计算一个hash值然后用容器的名字去查询对应DOcker容器的hash值。若查找到容器，且两者的hash值不同,则停止Docker中容器的进程，并停止与之关联的Pause容器进程；若两者相同，则不做任何处理
    2) 如果容器被终止了，且没有指定的restartPolicy，则不做任何处理。
    3） 调用Docker Client下载容器镜像，调用Docker Client运行容器
```

### 3.4.3 容器健康检查
2种探针
```
1. LivenessProbe探针：如果没有设置LivenessProbe，则默认永远返回Success。若探测到不健康，则容器将被删除，包含以下三种实现方式。
    1) ExecAction: 在容器内部执行一个命令，如果该命令的推出状态码为0，则表明容器健康
    2) TCPSocketAction: 通过容器的IP地址和端口号执行TCP检查，如果能被访问，则表明容器健康
    3) HTTPGetAction: 通过容器的IP地址和端口号及路径调用HTTP Get方法，如果响应的状态码大于等于200且小于400，则认为容器状态健康

2. ReadinessProbe探针：用于判断容器是否启动完成且准备接受请求。如果ReadinessProbe探测到失败，则Pod的状态将被修改。Endpoint Controller 将从Service的Endpoint中删除包含该容器所在Pod的IP地址的Endpoint条目


```

### 3.4.4 cAdvisor 资源监控
    cAdvisor被集成到了Kubernetes代码中，它自动查找所有在其所在节点上的容器，自动采集CPU、内存、文件系统和网络使用的统计信息。并通过所在节点机的4191端口暴露一个简单的UI。

## 3.5 kube-proxy 运行机制分析
![Service 负载均衡转发规则](https://github.com/rayshaw001/common-pictures/blob/master/K8S/ServiceLoadBlancerForwardRule.JPG?raw=true)

## 3.6 深入分析集群安全机制

## 3.7 网络原理

# 第四章 Kubernetes开发指南

## 4.1 REST简述

## 4.2 Kubernetes API详解

## 4.3 使用Java程序访问Kubernetes API

# 第五章 Kubernetes运维指南

## 5.1 Kubernetes集群管理指南

## 5.2 Kubernetes 高级案例

## 5.3 Trouble Shooting 指导

## 5.4 Kuberntetes v1.3 开发中的新功能

# 第六章 Kubernetes 源码导读

## 6.1 Kubernetes 源码结构和编译步骤

## 6.2 kube-apiserver 进程源码分析

## 6.3 kube-controller-manager 进程源码分析

## 6.4 kube-scheduler 进程源码分析

## 6.5 kubelet 进程源码分析

## 6.6 kube-proxy 进程源码分析

## 6.7 kubectl 进程源码分析

# 后记
