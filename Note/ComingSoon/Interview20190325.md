Java
hashmap(红黑树)和concurrentHashMap hashtable 1.7 1.8（非常高频）
arraylist linkedlist linkedhashmap
线程池的使用（参数运用）(非常高频)
volatile 有什么作用
sychronized和lock有什么区别 (高频)
java多线程有哪些实战用过的
java反射原理
手写生产者消费者代码；使用concurrent包下的来实现生产者消费者
同步异步阻塞非阻塞的差别
AQS原理
多线程如何解决死锁  写个死锁
阻塞和等待之间的区别
LRU cache
Java的四种引用
双亲委派模型
java锁有哪些
synchronized优化 偏向锁
JDK读写锁 countdownlatch AtomicInteger


JVM
GC回收 
CMS G1 ..
Java内存模型（重排序和可见性） ..
JVM内存布局  ..
full GC  young GC
Jvm调优是否有实战过  jvm分区
查GC频繁 内存泄漏
java类加载流程
outofmemory排查 ..
怎么判断对象存活
jvm一个对象分配到结束全过程
新生代引用老年代对象
JIT如何检测热点方法
Java栈内存溢出 软引用和弱引用


MySQL
Mysql隔离级别（非常高频） 
innodb和myisam的区别
mysql主从复制
索引原理  索引选择条件 组合索引如何存储  ..
b+索引和hash索引啥区别，分别适用啥？ 前缀 范围 
B和B+树的区别
聚簇和非聚簇的区别
悲观锁有表锁行锁，乐观锁有Mvcc  乐观锁悲观锁原理    ..


Spring
ioc，aop原理及实现，及其应用 DI（非常高频）
spring事务实现原理。抛出异常之后回滚情况。事务传播机制  ..
spring 如何解决循环依赖
SpringBean初始化
A和B两个bean的顺序加载   @DependsOn({"a"})
BeanFactory和ApplicationContext的区别
Singleton和Prototype的区别   单例和每次都new  默认是singleton 有状态的bean用Prototype
动态代理和静态代理有什么区别   aop静态代理在虚拟机启动时通过改变目标对象字节码的方式来完成对目标对象的增强 
Spring启动过程 
Springboot启动流程 
springmvc的工作流程


Redis
Redis数据结构   ..
zset （高频）
有序集合的实现
集群
Redis持久化相关  ..
Redis多路复用
Redis事务回滚
Redis的业务场景
uv hyperloglog


ZooKeeper
zk的watch机制
zab协议
满足cap的哪两个
zk选主算法  和paxos的区别
zookeeper面试题     https://segmentfault.com/a/1190000014479433


Kafka
kafka的可靠性 ..
高吞吐 ACK 会丢消息吗 怎么解决  有序吗 怎么保证  怎么实现顺序写
offset如何存储 索引文件格式  提交offset挂了 怎么保证消息不被重复消费


Dubbo
https://www.jianshu.com/p/cd7e17d26450   dubbo面试题！会这些，说明你真正看懂了dubbo源码
https://blog.csdn.net/zl1zl2zl3/article/details/83721147
数据传输过大有什么问题
异步调用
生产者如何发布服务、注册服务，消费者如何调用服务
负载均衡策略  一致性哈希算法

Tomcat
Tomcat类加载机制    https://www.cnblogs.com/aspirant/p/8991830.html



设计模式
手写单例模式 (高频)
单例：双重检查，枚举，饿汉懒汉，静态内部类
代理模式


IO
aio nio bio
select epoll区别
同步异步，阻塞非阻塞的区别

计算机原理
为什么会有线程，为什么线程切换比进程快
并行和并发的区别
页面置换
虚拟内存


网络
IP、http报头结构
301 302区别：永久和暂时~
TCP和UDP区别     ..
TCP可靠连接如何建立，为什么是三次  ..
TCP可靠传输如何实现
HTTP请求过程 
MMU（ Memory Management Unit，内存管理单元）
http://nommu.org/memory-faq.txt
DNS怎么工作
TCP和IP


算法
1.二叉树非递归后序遍历
2.旋转数组  ..
3.链表倒数第n个节点
4.找出数组中重复数字
5.简单字符转换
求阶乘和
二叉树层序遍历  ..
topK ..
反转链表    ..
连续子串和最大值
两个有序数组合并取中位数
给定二叉树显示最右边的那一列节点
一个树，找最长路径
找环入口 ..
图的存储方式
树的存储方式
ipv4地址和整型互转
判断链表是否有环
二叉树高度
归并排序


其他
分布式锁   Redis Zookeeper怎么实现分布式锁
雪崩场景
缓存穿透（null处理）
20亿 统计pv uv
限流 令牌桶
实现RPC
知道哪些序列化  jdk thrift怎么实现的
SOA和微服务
分布式事务处理 TCC
分布式唯一ID
分布式session如何实现
微服务的理解   常用的微服务方案Dubbo和Spring cloud比较
cap base
强一致性和弱一致性有什么方法来做
2pc