\# https://maimai.cn/article/detail?fid=1156053364&efid=OAPsP36u_EdRRceoHPwLuA

# 1 RabbitMQ
1.rabbitmq 的使用场景有哪些？
```
场景1：单发送单接收
场景2：单发送多接收
场景3：Publish/Subscribe
场景4：Routing (按路线发送接收)
场景5：Topics (按topic发送接收)
```
2.rabbitmq 有哪些重要的角色？
3.rabbitmq 有哪些重要的组件？
4.rabbitmq 中 vhost 的作用是什么？
5.rabbitmq 的消息是怎么发送的？
6.rabbitmq 怎么保证消息的稳定性？
7.rabbitmq 怎么避免消息丢失？
8.要保证消息持久化成功的条件有哪些？
9.rabbitmq 持久化有什么缺点？
10.rabbitmq 有几种广播类型？
11.rabbitmq 怎么实现延迟消息队列？
12.rabbitmq 集群有什么用？
13.rabbitmq 节点的类型有哪些？
14.rabbitmq 集群搭建需要注意哪些问题？
15.rabbitmq 每个节点是其他节点的完整拷贝吗？为什么？
16.rabbitmq 集群中唯一一个磁盘节点崩溃了会发生什么情况？
17.rabbitmq 对集群节点停止顺序有要求吗？

# 2 Kafka
18.kafka 可以脱离 zookeeper 单独使用吗？为什么？
19.kafka 有几种数据保留的策略？
20.kafka 同时设置了 7 天和 10G 清除数据，到第五天的时候消息达到了 10G，这个时候 kafka 将如何处理？
21.什么情况会导致 kafka 运行变慢？
22.使用 kafka 集群需要注意什么？

# 3 ZooKeeper
23.zookeeper 是什么？
24.zookeeper 都有哪些功能？
25.zookeeper 有几种部署模式？
26.zookeeper 怎么保证主从节点的状态同步？
27.集群中为什么要有主节点？
28.集群中有 3 台服务器，其中一个节点宕机，这个时候 zookeeper 还可以使用吗？
29.说一下 zookeeper 的通知机制？

# 4 MySQL
30.数据库的三范式是什么？
```
1NF: 必有主键
2NF：列必与主键有关系
3NF：列只能与主键有直接关系，不能有间接关系
```
31.一张自增表里面总共有 7 条数据，删除了最后 2 条数据，重启 mysql 数据库，又插入了一条数据，此时 id 是几？
8
32.如何获取当前数据库版本？
33.说一下 ACID 是什么？
34.char 和 varchar 的区别是什么？
35.float 和 double 的区别是什么？
36.mysql 的内连接、左连接、右连接有什么区别？
37.mysql 索引是怎么实现的？
38.怎么验证 mysql 的索引是否满足需求？
39.说一下数据库的事务隔离？
40.说一下 mysql 常用的引擎？
41.说一下 mysql 的行锁和表锁？
42.说一下乐观锁和悲观锁？
43.mysql 问题排查都有哪些手段？
44.如何做 mysql 的性能优化？

# 5 Redis
45.redis 是什么？都有哪些使用场景？
46.redis 有哪些功能？
47.redis 和 memecache 有什么区别？
48.redis 为什么是单线程的？
49.什么是缓存穿透？怎么解决？
50.redis 支持的数据类型有哪些？
51.redis 支持的 java 客户端都有哪些？
52.jedis 和 redisson 有哪些区别？
53.怎么保证缓存和数据库数据的一致性？
54.redis 持久化有几种方式？
55.redis 怎么实现分布式锁？
56.redis 分布式锁有什么缺陷？
57.redis 如何做内存优化？
58.redis 淘汰策略有哪些？
59.redis 常见的性能问题有哪些？该如何解决？

# 6 JVM
60.说一下 jvm 的主要组成部分？及其作用？
61.说一下 jvm 运行时数据区？
62.说一下堆栈的区别？
63.队列和栈是什么？有什么区别？
64.什么是双亲委派模型？
65.说一下类加载的执行过程？
66.怎么判断对象是否可以被回收？
67.java 中都有哪些引用类型？
68.说一下 jvm 有哪些垃圾回收算法？
69.说一下 jvm 有哪些垃圾回收器？
70.详细介绍一下 CMS 垃圾回收器？
71.新生代垃圾回收器和老生代垃圾回收器都有哪些？有什么区别？
72.简述分代垃圾回收器是怎么工作的？
73.说一下 jvm 调优的工具？
74.常用的 jvm 调优的参数都有哪些？


# 7 Dubbo
## Part 1
>1、默认使用的是什么通信框架，还有别的选择吗?  
>>**默认也推荐使用netty框架，还有mina。**
>
>2、服务调用是阻塞的吗？  
>>**默认是阻塞的，可以异步调用，没有返回值的可以这么做。**
>
>3、一般使用什么注册中心？还有别的选择吗？  
>>**Multicast、Zookeeper、Redis、Simple/推荐使用zookeeper**
>
>4、默认使用什么序列化框架，你知道的还有哪些？  
>>**hession是默认的序列化协议，hession、Java二进制序列化、json、SOAP文本序列化**
>
>5、服务提供者能实现失效踢出是什么原理？  
>>**服务失效踢出基于zookeeper的临时节点原理。**
>
>6、服务上线怎么不影响旧版本？  
>>**采用多版本开发，不影响旧版本。**
>
>7、如何解决服务调用链过长的问题？  
>>**可以结合zipkin实现分布式服务追踪。**
>
>8、说说核心的配置有哪些？  
```
dubbo:service/

dubbo:reference/

dubbo:protocol/

dubbo:registry/

dubbo:application/

dubbo:provider/

dubbo:consumer/

dubbo:method/
```
>9、dubbo推荐用什么协议？  
```
默认使用dubbo
rmi协议
hessian协议
http协议
webservice协议
thrift协议
memcached协议
redis协议
```
  
>10、同一个服务多个注册的情况下可以直连某一个服务吗？  
>>**可以直连，修改配置即可，也可以通过telnet直接某个服务。**
>11、画一画服务注册与发现的流程图  
>  
>12、集群容错怎么做？  
>>**读操作建议使用Failover失败自动切换，默认重试两次其他服务器。写操作建议使用Failfast快速失败，发一次调用失败就立即报错。**
>
>13、在使用过程中都遇到了些什么问题？  
> 
>14、dubbo和dubbox之间的区别？  
```
支持REST风格远程调用（HTTP + JSON/XML)；
支持基于Kryo和FST的Java高效序列化实现；
支持基于Jackson的JSON序列化；
支持基于嵌入式Tomcat的HTTP remoting体系；
升级Spring至3.x；
升级ZooKeeper客户端；
支持完全基于Java代码的Dubbo配置；
```
>15、你还了解别的分布式框架吗？  
```
Hessian	Montan	rpcx	gRPC	Thrift	Dubbo	Dubbox
```

## Part 2
>1、Dubbo是什么？
>>RPC远程服务调用方案
>>SOA服务治理方案
>
>2、为什么要用Dubbo？
>> 与传统MVC应用对比
>
>3、Dubbo 和 Spring Cloud 有什么区别？
>>
>4、dubbo都支持什么协议，推荐用哪种？
```
默认使用dubbo
rmi协议
hessian协议
http协议
webservice协议
thrift协议
memcached协议
redis协议
```
>5、Dubbo需要 Web 容器吗？
>>不需要
>
>6、Dubbo内置了哪几种服务容器？
>>SpringContainer、Log4jContainer、JettyContainer、JavaConfigContainer、LogbackContainer
>
>7、Dubbo里面有哪几种节点角色？

|节点|角色|
|---|----|
|Provider|暴露服务的提供方|
|Consumer|调用远程服务的服务消费方|
|Registry|服务注册与发现的注册中心|
|Monitor|统计服务的调用次数和调用时间的监控中心|
|Container|服务运行容器|
>8、画一画服务注册与发现的流程图
>
>9、Dubbo默认使用什么注册中心，还有别的选择吗？
>>Multicast、Zookeeper、Redis、Simple/推荐使用zookeeper
>
>10、Dubbo有哪几种配置方式？
```
1. XML 配置文件方式
2. properties 配置文件方式
3. annotation 配置方式
4. API 配置方式
```
>11、Dubbo 核心的配置有哪些？
```
dubbo:service/
dubbo:reference/
dubbo:protocol/
dubbo:registry/
dubbo:application/
dubbo:provider/
dubbo:consumer/
dubbo:method/
```
>12、在 Provider 上可以配置的 Consumer 端的属性有哪些？
```
timeout
retries
loadbalance
actives

Provider上的provider属性有：
threads
executes
```
>13、Dubbo启动时如果依赖的服务不可用会怎样？
>>会报错、可以设置服务的check=false来避免、默认值是true

>14、Dubbo推荐使用什么序列化框架，你知道的还有哪些？
```
hessian2
dubbo
json
java

另外还有专门针对Java语言的Kryo，FST，及跨语言的Protostuff、ProtoBuf，Thrift，Avro
```
>15、Dubbo默认使用的是什么通信框架，还有别的选择吗？
>>默认是netty，还有mina

>16、Dubbo有哪几种集群容错方案，默认是哪种？
```
默认是Failover Cluster
Failfast Cluster
Failsafe Cluster
Failback Cluster
Forking Cluster
Broadcast Cluster
```
>17、Dubbo有哪几种负载均衡策略，默认是哪种？
```
默认是random
其他还有roundrobin、leastaAtive、ConsustentHash
```
>18、注册了多个同一样的服务，如果测试指定的某一个服务呢？
>>可以配置环境点对点直连，绕过注册中心，将以服务接口为单位，忽略注册中心的提供者列表。
>
>19、Dubbo支持服务多协议吗？
>>Dubbo 允许配置多协议，在不同服务上支持不同协议或者同一服务上同时支持多种协议。
>
>20、当一个服务接口有多种实现时怎么做？
>>当一个接口有多种实现时，可以用 group 属性来分组，服务提供方和消费方都指定同一个 group 即可。
>
>21、服务上线怎么兼容旧版本？
>>可以用版本号（version）过渡，多个不同版本的服务注册到注册中心，版本号不同的服务相互间不引用。这个和服务分组的概念有一点类似。
>
>22、Dubbo可以对结果进行缓存吗？
>>可以，Dubbo 提供了声明式缓存，用于加速热门数据的访问速度，以减少用户加缓存的工作量。
>
>23、Dubbo服务之间的调用是阻塞的吗？
>>默认是同步等待结果阻塞的，支持异步调用。
>
>24、Dubbo支持分布式事务吗？
>>目前暂时不支持，后续可能采用基于 JTA/XA 规范实现
>
>25、Dubbo telnet 命令能做什么？
>>dubbo 通过 telnet 命令来进行服务治理
>
>26、Dubbo支持服务降级吗？
>>Dubbo 2.2.0 以上版本支持。
>
>27、Dubbo如何优雅停机？
>>Dubbo 是通过 JDK 的 ShutdownHook 来完成优雅停机的，所以如果使用 kill -9 PID 等强制关闭指令，是不会执行优雅停机的，只有通过 kill PID 时，才会执行。
>
>28、服务提供者能实现失效踢出是什么原理？
>>服务失效踢出基于 Zookeeper 的临时节点原理。
>
>29、如何解决服务调用链过长的问题？
>>zipkin分布式服务追踪
>
>30、服务读写推荐的容错策略是怎样的？
>>写操作failfast，读操作failover
>
>31、Dubbo必须依赖的包有哪些？
>>Dubbo 必须依赖 JDK，其他为可选。
>
>32、Dubbo的管理控制台能做什么？
>>路由规则，动态配置，服务降级，访问控制，权重调整，负载均衡，等管理功能。
>
>33、说说 Dubbo 服务暴露的过程。
>>Dubbo 会在 Spring 实例化完 bean 之后，在刷新容器最后一步发布 ContextRefreshEvent 事件的时候，通知实现了 ApplicationListener 的 ServiceBean 类进行回调 onApplicationEvent 事件方法，Dubbo 会在这个方法中调用 ServiceBean 父类 ServiceConfig 的 export 方法，而该方法真正实现了服务的（异步或者非异步）发布。
>
>34、Dubbo 停止维护了吗？
>>2014 年开始停止维护过几年，17 年开始重新维护，并进入了 Apache 项目。
>
>35、Dubbo 和 Dubbox 有什么区别？

```
Dubbox是当当网基于dubbo开源的扩展，支持更多特性
支持REST风格远程调用（HTTP + JSON/XML)；
支持基于Kryo和FST的Java高效序列化实现；
支持基于Jackson的JSON序列化；
支持基于嵌入式Tomcat的HTTP remoting体系；
升级Spring至3.x；
升级ZooKeeper客户端；
支持完全基于Java代码的Dubbo配置；
```
>36、你还了解别的分布式框架吗？
>>别的还有 Spring cloud、Facebook 的 Thrift、Twitter 的 Finagle 等。
>
>37、Dubbo 能集成 Spring Boot 吗？
>>可以
>
>38、在使用过程中都遇到了些什么问题？
>>Dubbo 的设计目的是为了满足高并发小数据量的 rpc 调用，在大数据量下的性能表现并不好，建议使用 rmi 或 http 协议。
>
>39、你读过 Dubbo 的源码吗？
>>
>
>40、你觉得用 Dubbo 好还是 Spring Cloud 好？
>>扩展性问题，没有好坏，只有合适不合适