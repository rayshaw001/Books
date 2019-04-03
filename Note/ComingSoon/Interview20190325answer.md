Java
hashmap(红黑树)和concurrentHashMap hashtable 1.7 1.8（非常高频）
arraylist linkedlist linkedhashmap
线程池的使用（参数运用）(非常高频)
```
corePoolSize
核心线程数：每秒任务数*每个任务耗时

maxPoolSize
最大线程数

keepAliveTime
超时退出时间

allowCoreThreadTimeout
true:允许核心线程超时退出
false:不允许

queueCapacity
切忌以下写法：LinkedBlockingQueue queue = new LinkedBlockingQueue();//这样写默认大小就是Integer.MAX_VALUE
```
volatile 有什么作用
```
可见性
防止重排序
```
sychronized和lock有什么区别 (高频)
```

```
java多线程有哪些实战用过的
java反射原理
```
类信息
```
手写生产者消费者代码；使用concurrent包下的来实现生产者消费者
```
public class Container<T>{
    int size=0;
    Queue<T> q;
    public Container<T>(int size){
        q=LinkedList<T>();
        this.size=size;
    }

    synchronized public void put(T t){
        while(q.size()==size){
            this.wait();
        }
        q.add(t);
        this.notifiyAll();
    }

    synchronized public T take(){
        while(q.isEmpty()){
            this.wait();
        }
        this.notifyAll();
        return q.poll();
    }
}
```
同步异步阻塞非阻塞的差别
```
对于服务端来说，同步异步
对于调用者来说，阻塞非阻塞
```
AQS原理
多线程如何解决死锁  写个死锁
阻塞和等待之间的区别
LRU cache
Java的四种引用
双亲委派模型
java锁有哪些
synchronized优化 偏向锁
JDK读写锁 countdownlatch AtomicInteger

||private|default|protected|public|
|---|----|-------|---------|------|
|同类|true|true|true|true|
|同包|false|true|true|true|
|子类|false|false|true|true|
|全局|false|false|false|true|

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
```
read uncommitted
read committed
repeatable read
serilizable
```
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
```
先实例化，再set注入
```
SpringBean初始化
```

```
A和B两个bean的顺序加载   
```
@DependsOn({"a"})
```
BeanFactory和ApplicationContext的区别
Singleton和Prototype的区别   
```
单例和每次都new  默认是singleton 有状态的bean用Prototype
```
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


redis 计算机网络、操作系统、算法、项目、微服务
项目、LRU、可靠传输、进程间通信方式、进程和线程的区别、关系页面置换算法、做过什么项目

TCP UDP 区别、保证可靠的机制、HTTP和TCP的联系mysql存储引擎
redis数据结构 HASH内部实现 innodb 和myisam区别

项目（详细到具体用了哪些接口）
HTTP和https的区别，具体说明https原理
session与cookie，以及项目中如何运用的
链表的一些基本知识
一个网页具体是如何工作的
二叉树非递归中序遍历
数组最大子序列的和
```
    1   2   3   4   -8  5   6   7   6
    1   3   6   10  2   7   13  20  26

    -1  -2  -3  -4  -5
    -1  -2  -3  -4  -5
```
设计一个hashmap


一面： 进程和线程以及它们之间的区别，进程间的通信方式和对应的同步方式，你用过吗？具体怎么用？ TCP和UDP的区别 三次握手、四次挥手，为什么？ TCP如何保证传输的可靠性？ TCP的拥塞控制，具体过程是怎么样的？UDP有拥塞控制吗？如何解决？ 算法题： 一个链表，假设第一个节点我们定为下标为1，第二个为2，那么下标为奇数的结点是升序排序，偶数的结点是降序排序，如何让整个链表有序？假设我们有一个队列，可能存放几千万上亿的数据，我们应该如何设计这个队列？写出来看看？一个二维矩阵，从左到右是升序，从上到下是降序，找一个数是否存在于矩阵中。

二面： 前面面试官已经问了你三道算法了，那我就随便问一道吧：翻转链表，redis： 你知道redis有哪几种数据类型吗？你比较熟悉哪几种？为什么？ 讲讲redis里面的哈希表吧 一个URL从浏览器输入到响应页面，整个过程是怎么样的，能讲得多详细就讲多详细。 你说HTTP可以进行多路复用，具体是怎么复用？如果服务器挂掉或者客户端挂掉，会怎么样？ HTTP的各种头你了解吗？每种头具体是什么作用？说一下 你说arp会进行广播，会造成网络风暴，那应该怎么解决？ 你知道CDN吗？说一下 BIO NIO AIO说一下？epoll了解吗？用过吗？具体调用OS什么方法？webSocket呢？ 创建进程调用的是OS哪些方法？具体说说 我们聊聊JAVA吧，你了解JVM吗？给我讲讲 JVM具体会在什么时候进行垃圾回收？JMM具体说说？ 垃圾回收算法具体说说？各种垃圾回收器了解吗？

三面： 感觉应该是总监，很高冷。 说说项目？我们聊聊JAVA吧，现在我要求设计一个容器，容器满的时候生产者阻塞，容器空的时候消费者阻塞， 二叉树的最大路径。 好吧，今天就到这里了。 三面面完一度觉得自己凉透了，过两天收到offer call，然后就收到offer了。

总的来说，个人感觉头条面试算法题不难，不过绝对不能做不出来。基础一定要牢固，一些细节问题一定要搞清楚，一般还会问一些设计问题，这种问题就要靠灵机一动了。噢，对了，还有一件事，一面是要求自己写测试用例运行的，所以coding一定要快准狠


一面先让做个自我介绍，接着问了一下简历上的相关项目，然后开始问技术问题。首先问的问题是用shell脚本统计一个文件中出现频率最高的K个字符串，接着开始逐渐深入，比如文件很大，内存无法容纳，应该怎么做。过程中面试官也会给一下提示，注意沟通。最后让实现一个LRU Cache，缓存有最大容量限制，根据LRU进行淘汰，每条缓存有过期时间。    

二面比较直接，上来就直接问问题。比如， B 树、B+ 树、B* 树、跳表的特点和区别，MMAP 和 Direct IO 的区别，http 和 https 的区别。然后问用 shell 命令删除目录下最新的三个文件，进一步问，如何只保留最新的三个文件。最后开始编程，题目是对排序数组进行二分查找，不能用递归，很基本的问题，但要求写完整的程序运行起来，之后扩展了一下，对排序数组进行了平移，要求进行查找。