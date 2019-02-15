\# Alibaba
# Java
## I
### HashMap HashSet ArrayList LinkedList
1. hashset底层实现，hashmap的put操作
2. ArrayList和LinkedList的插入和访问时间复杂度？
3. HashMap在什么情况下会扩容，或者有哪些操作会导致扩容
4. hashmap 检测到hash冲突后，将元素插在链表末为还是开头
5. map怎么实现hashcode和equals，为什么重写equals必须重写hashcode
```
集合类持有的对象才需要
```
6. 1.8版本的hashmap 采用了红黑树，讲讲红黑树的特性，为什么一定要用红黑树而不是AVL树，B树，B+树
```
AVL： 完全平衡的二叉树
红黑树：AVL的简化版，放宽了一些限制
B/B+树：持有多个值，next指针也有多个
```

### Concurrent
1. 多线程的锁？怎么优化的？偏向锁、轻量级锁、重量级锁
```
偏向锁：只有一个线程进入临界区；
轻量级锁：多个线程交替进入临界区；
重量级锁：多个线程同时进入临界区。
```
2. Java里面的锁synchornized，Lock，实现的区别
3. synchronized锁升级的过程，用于解决那些问题
4. AtomicInteger，为什么要使用CAS而不是synchronized
5. AtomicInteger实现原理是什么？和你设计的计数器优劣比较？CAS怎么实现原子操作？
6. 公平锁，非公平锁怎么实现的，AQS原理介绍一下
7. Java容器有哪些？那些是同步容器，哪些是并发容器？
```
1. 同步容器：Collections.synchornizedXX
2. 并发容器：java.util.concurrent.*；
```
8. concurrentHashMap怎么实现？concurrenthashmap在1.8和1.7里面有什么区别
9. CountdownLatch、linkedHashMap、AQS实现原理
10. 使用过concurrent包下的哪些类，使用场景等等。
11. 线程池有哪些RejectedExecutionHandler，分别对应的使用场景
12. 线程池的工作原理，几个重要的参数，然后给几个具体的参数分析线程池会怎么做，最后问阻塞队列的作用是什么？
13. 线程池有哪些参数？分别有什么用？如果任务数超过核心线程数，会发生什么？阻塞队列大小是多少？
14. 数据库连接池介绍一下，底层实现说下
15. 线程安全的计数器
16. java线程安全queue需要注意的点
17. 死锁的原因，如何避免

### JVM
1. Java 内存分区
2. Java对象的回收方式
3. 回收算法
4. CMS和G1，CMS解决什么，说一下回收过程，CMS为什么停顿两次
5. 你了解哪些收集器，CMS和G1，G1的优点
6. 新生代分几个区？使用什么算法进行垃圾回收，为什么使用这个算法
7. Java什么时候发生内存溢出，Java堆呢
8. 集合类如何解决这个问题（集合类持有对象容易发生内存溢出）
9. 项目中的JVM调优
10. 说一下GC，什么时候进行Full GC·
11. OOM说一下，怎么排查？哪些会导致OOM
```
1. 死循环
2. 递归次数过多
3. List、Map、Set使用完未清除
4. 数据库查询一次性查询所有数据

Solution：增大：PermSize
```

### Spring Tomcat
1. Tomcat的类加载器结构
```

```
2. Spring 如何让两个bean按顺序加载      
```
A. 先写的先加载
B. 使用@DependOn注解
```
3. spring mvc 怎么处理请求全流程
4. spring 一个bean装配的过程
```
A. 转换对应beanName
B. 尝试从缓存中加载单例
C. bean实例化
D. 原型模式的依赖检查
E. 检测parentBeanFactory
F. 将存储的XML配置文件的GernericBeanDefinition 转换为 RootBeanDefinition
G. 寻找依赖
H. 针对不同的scope进行bean的创建
I. 类型转换
```

### Other
1. java反射原理，注解原理
```
类信息
```

## II
### Concurrent
1. volatile解释
2. 多线程，用到了哪些
3. 线程池由哪些组件组成，有那些线程池，**拒绝策略有哪些**
4. 什么时候多线程会死锁

### JVM 
1. jvm虚拟机老年代什么情况下会发生GC，给你一个场景：4cores 8G server 每2个小时就要出现一次老年代GC，现在有日志怎么分析是哪里出了问题

### Other
1. 自己的项目
2. 集合类，字符串集合，找出pdd并删除

## III
1. 自我介绍
2. 多线程线程数很多会怎么样？
3. 谈谈SpringBoot和SpringCloud的理解
4. 未来技术职业规划
5. 为什么选择阿里
6. 项目主要架构，你在里面做什么
7. 有什么比较复杂的业务逻辑讲一下
8. 最大的难点是什么，收获是什么

# redis
## II
1. redis 是单线程，分布式（redis集群）怎么做
```
数据分区
```
2. redis数据结构底层编码有哪些？有序链表采用了哪些不同的编码？

|数据结构（type）|实际类型|底层编码|值最大size|
|---------------|--------|-------|----------|
|字符串（string）|简单字符串，复杂字符串（XML，JSON），数字（浮点，整型），二进制（图片，视频，音频）|raw，int，embstr|512MB|
|哈希（hash）||ziplist（默认），hashtable（value大于64字节或者field个数超过512）|2^32-1|
|列表（list）||ziplist（默认），linkedlist（value大于64字节或者field个数超过512），quicklist(v3.2以后)|2^32-1|
|集合（set）||intset（默认），hashtable（元素个数大于512个）|2^32-1|
|有序集合（zset）||ziplist(默认),skiplist（元素个数大于128或value大于64字节）|2^32-1|

3. redis的hash结构最多能存多少个元素
```
2^32-1
```
4. 使用过那些NoSQL数据库？MongoDB和redis使用哪些场景
5. 分布式事务之TCC服务设计
6. redis和memcache有什么区别？redis为什么比memcache有优势
7. 考虑redis的时候，有没有考虑容量？大概数据量会有多少？

## III
1. redis有哪些数据结构？底层的编码有哪些？有序链表采用了哪些不同的编码？
2. redis扩容，失效key清理策略
3. redis持久化怎么做，aof和rdb，有什么区别，有什么优点

# MySQL
## I
1. 组合索引，B+树如何存储的
```
非叶子节点只存储一级索引信息
叶子节点按索引顺序排序
```
2. 为什么缓存更新策略是先更新数据库后删除缓存

## II
1. mysql的默认存储引擎，mysql存储引擎的区别
2. 数据库的事务，四个性质说一下，分别有什么用？怎么实现的？
3. 什么是幻读，如何解决
4. 不可重复读和幻读，怎么避免，底层怎么实现（行锁表锁）
5. 事务的隔离级别有什么？通过什么来实现的？分别解决了什么问题？
6. 乐观锁与悲观锁的使用场景、谈谈数据库乐观锁与悲观锁
7. 数据库索引，底层是怎么样实现的，为什么要用B树索引
8. 查询中那些情况不会使用索引、数据库索引有哪些？底层怎么实现的？数据库怎么优化
9. mysql主从同步的实现原理
10. mysql是怎么用B+树的？

## III
1. MySQL主从复制怎么做的，原理是什么，有什么优缺点
2. mysql有哪几种join方式，底层实现原理是什么
3. mysql数据库怎么实现分库分表，以及数据同步？

# 分布式
## III
1. cap了解吗
2. 负载均衡怎么做，为什么这么做
3. 分布式、消息队列，用在什么场景，削峰，限流、异步
4. 有哪些集群模式，各自的区别
5. 分布式全局唯一ID怎样来实现？
6. dubbo的生产者如何发布服务，注册服务，消费者如何调用服务
7. dubo负载均衡的策略有哪些？一致性哈希聊一下？
8. 分布式session如何实现
9. 为服务的理解，常用的服务方案dubbo、spring cloud的比较？
10. kafka怎么保证数据可靠性
11. 数据库主从同步数据一致性如何解决？技术方案的优劣势比较
12. 分布式锁怎么实现的，分布式锁的实现方式你知道有哪些？主流的解决方案是什么？
13. 介绍对你技术能力帮助最大的项目，重点讲讲架构设计思路

# 算法
1. 算法题，对一个链表进行归并排序
2. 了解哪些排序算法？讲讲复杂度
3. 归并排序

# Other
## I
0. B+树和B树的区别，优缺点
1. https和http的区别，有没有用过其他安全传输的手段
2. OSI七层结构，每层结构都是干什么的
3. 哪些设计模式？装饰器，代理==
4. linux查看系统负载

## II
1. 服务器如何负载均衡，有哪些算法，那个比较好，一致性哈希原理，怎么避免DDOS攻击请求打到少数机器
2. 三次握手，四次挥手
3. RPC了解吗
4. 自己实现RPC

## III
1. 单点登录是如何实现的？

# HR
1. 工作中遇到最大的挑战是什么，如何克服
2. 你最大的优点和缺点是什么，各说一个
3. 未来的职业规划是什么
4. 聊聊人生的经历
5. 聊印象深刻的人生经历
6. 说下技术方面或者生活方面你做得比较好的一个点和不足的一个点
7. 职业规划






\# Other
# sougou
## Part 1
1. 写一个单例模式
2. HashMap的底层源码实现，jdk1.8做了哪些优化
3. JVM 内存布局，**怎样查内存溢出**
4. **程序从数据库连接池里获取不到链接可，可能是什么原因？**
5. **kafka怎样存储offset，kafka的索引文件的格式是怎样的？为什么要这样设计**
6. **如果再提交offset的时候zk挂掉了，怎么保证消息不被重复消费？**
7. **zk的watch机制，zab协议**
8. **服务的注册与发现机制怎么实现？**
9. 老年代和新生代有哪些回收算法
```
老年代：G1、Serial Old、Parallel Old、CMS 
新生代：G1、Serial、ParNew 、Parallel Scavenge
```
10. CMS有哪几个阶段？分别做什么？
```
1. 初始标记 标记GC root能直接关联的对象
2. 并发标记 GC Root Tracing
3. 重复标记 标记并发标记期间用户线程新产生的对象
4. 并发清除 清除
```
11. **新生代里引用老年代的对象，GC会怎样处理？**

## Part 2

1. Redis 有哪些基本数据类型
```
String、Set、Hash、List
```
2. **Spring AOP的动态代理是怎样做的？**
3. **用过哪些设计模式？能举个例子吗？**
4. **Spring怎样避免循环依赖？看过源码吗？**
5. **Servlet里怎样注入Spring容器的bean？**
6. 写一段代码统计二叉树的高度
```
public class Solution{
    public int binaryTreeHeight(ListNode head){
        if(head==null){
            return 0;
        }
        return Math.max(1+binaryTreeHeight(head.left),1+binaryTreeHeight(head.right));
    }
}

```
7. **JIT怎样加测热点方法？**
8. **令牌桶算法有了解过吗？**
9. **怎样限制5分钟内10w的访问量？**
10. **Spring初始化和SpringBoot初始化有什么区别？**
11. 怎样找出Spring里有@XXX注解的bean，写一段代码
12. 一个RPC需要什么？怎样实现一个RPC？
13. 知道哪些序列化？JDK序列化怎样实现？thrift序列化怎样实现？
14. 你有什么想问我的？

\# 饿了么

## Part 1
1. 自我介绍
2. 先说一下你们目前用的技术栈，用过SpringCloud吗？
3. 讲一下Springoot的启动流程，重要的流程在纸上画一下
4. ipv4地址与整型数据互转，设计一个当打实现一下吧？
```
public class Solution{
    public int toInt(String ip){
        String[] ints = ip.split(".");
        int result = 0;
        for(int i=0; i<ints.length; i++){
            result += Integer.parseInt(ints[i]<<i*8);
        }
        return result;
    }

    public String toIp(int ip){
        int tmp = 0xff;
        String result = "";
        for(int i=0; i<4; i++){
            result = ip&tmp + result;
            ip>>8;
        }
        return result;
    }
}
```
5. 判断链表有没有环 时间复杂度O(n), 空间复杂度O(1)
```
public class Solution{
    public boolean hasCycle(LstNode head){
        ListNode tmp = head;
        ListNode next = head;
        while(tmp!=null&&tmp.next!=null&&next!=null&&next.next!=null) {
            tmp=tmp.next;
            next=next.next.next;
            if(tmp==next){
                return true;
            }
        };
        return false;
    }
}
```
6. **yang GC和full GC**
7. 目前用的什么版本的jdk 看过hashmap的源码吗？，jdk1.8hashmap的实现？，和concurrentHashMap的区别？Segment的数据结构？
8. ArrayList和linkedList的区别和底层实现
9. 写一个线程安全的单例模式
```
public class Solution{
    private static volatile Singleton singleton;
    private Solution(){

    }
    public getSigleton(){
        if(sigleton==null){
            synchornized(Solution.class){
                if(singleton==null){
                    sigleton = new Singleton();
                }
            }
        }
        return singleton;
    }

}

```
10. **已知一个服务大概有20E次访问，统计一下pv和uv**
11. 写一个shell命令，统计一下访问量在前100的接口
12. redis一般用在什么场景？写一个基于redis2.6的分布式锁
13. 具体说下mysql的事务的隔离级别，MyISMA和INNODB的区别。如果是90%都是查询的场景、选哪一个引擎？
14. Ltrace你主要负责哪块？实现的流程？
15. 乐观锁和悲观锁？

## Part 2

1. 为什么想这个时候离职
2. SpringBoot的启动流程，用了很多event和listener，有什么好处
3. 讲一下jdk1.8的hashmap做了哪些优化
