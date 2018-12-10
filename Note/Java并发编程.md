# 1 并发编程的挑战
>并发编程的目的是为了让程序运行得更快,但是,并不是动更多的线程就能让程序最大限度地并发执行。在进行并发编程时,如果希望通过多线程执行任务让程序运行得更快,面临非常多的挑战,比如上下文切换的问题、死锁的问题,以及受限于硬件和软件的资源限制问题,本章会介绍几种并发编程的挑战以及解决方案。

## 1.1 上下文切换
### 1.1.1 多线程一定快吗
```
public class ConcurrencyTest {
    private static final long count = 100000000l;
    public static void main(String[] args) throws InterruptedException {
        concurrency();
        serial();
    }
    private static void concurrency() throws InterruptedException {
        long start = System.currentTimeMillis();
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                int a = 0;
                for (long i = 0; i < count; i++) {
                    a += 5;
                }
                System.out.print(",a="+a);
            }
        });
        thread.start();
        int b = 0;
        for (long i = 0; i < count; i++) {
            b--;
        }
        long time = System.currentTimeMillis() - start;
        thread.join();
        System.out.println("concurrency :" + time+"ms,b="+b);
    }
    private static void serial() {
        long start = System.currentTimeMillis();
        int a = 0;
        for (long i = 0; i < count; i++) {
            a += 5;
        }
        int b = 0;
            for (long i = 0; i < count; i++) {
            b--;
        }
        long time = System.currentTimeMillis() - start;
        System.out.println("serial:" + time+"ms,b="+b+",a="+a);
    }
}
```

### 1.1.2 测试上下文切换次数和时长
Tools:
1. Lmbench3     测试上下文切换的时长
2. vmstat       测量上下文切换次数      vmstat 1

### 1.1.3 如何减少上下文切换
```
无锁并发、CAS算法、使用最少线程、使用协程
```
|Title|Description|
|-----|-----------|
|无锁并发|多线程竞争锁时，会引起上下文切换，所以多线程处理数据时，可以用一些办法来避免使用锁，如将数据的ID按照Hash算法取模分段，不同的线程处理不同的数据|
|[CAS算法](https://zh.wikipedia.org/wiki/%E6%AF%94%E8%BE%83%E5%B9%B6%E4%BA%A4%E6%8D%A2)|Java的Atomic包使用CAS算法来更新数据，而不需要加锁|
|使用最少线程|避免创建不需要的线程，比如任务很少，但是创建了很多线程来处理，这样会造成大量线程都处于等待状态|
|协程|在单线程里实现多任务的调度，并在单线程里维持多个任务间的切换|

### 1.1.4 减少上下文切换实战
1. jstack dump线程信息
```
jps
jstack 31177 > /home/tengfei.fangtf/dump17
```
2. 统计所有线程分别处于什么状态
```
grep java.lang.Thread.State dump17 | awk '{print $2$3$4$5}' | sort | uniq -c
```
3. 打开dump文件查看处于WAITING（onobjectmonitor）的线程在做什么
4. 适当修改maxThreads
5. dump 线程信息并对比


## 1.2 死锁

>避免死锁的几个常见方法：
>1. 避免一个线程同时获取多个锁
>2. 避免一个线程在所内同时占用多个资源，尽量保证每个锁只占用一个资源
>3. 尝试使用定时锁，使用lock.tryLock(timeout)来替代使用内部锁机制
>4. 对于数据库锁，加锁和解锁必须在一个数据库连接里，否则会出现解锁失败的情况

## 1.3 资源限制的挑战

### 1.3.1 什么是资源限制
1. 硬件资源限制：带宽限制（上传、下载），硬盘读写速度、CPU处理速度
2. 软件资源限制：数据库的连接数、socket连接数

### 1.3.2 资源限制引发的问题
例如，之前看到一段程序使用多线程在办公网并发地下载和处理数据时，导致CPU利用率达到100%，几个小时都不能运行完成任务，后来修改成单线程，一个小时就执行完成了。

### 1.3.3 如何解决资源限制的问题
1. 对于硬件资源的限制，考虑使用集群并行执行程序
   ODPS、Hadoop、或者自己搭建服务器集群，不同的机器处理不同的数据。可以通过“数据ID%机器数”，计算得到一个机器编号，然后由对应编号的机器处理这笔数据。
2. 对于软件资源限制，考虑使用资源池将资源复用。比如使用连接池将数据库和Socket连接复用，或者在调用对方webservice接口获取数据时，只建立一个连接

### 在资源限制情况下进行并发编程
根据不同的资源限制调整程序的并发度，比如下载文件程序依赖于两个资源——带宽和硬盘读写速度

## 1.4 小结
强烈建议多使用JDK并发包提供的并发容器和工具类来解决并发
问题，因为这些类都已经通过了充分的测试和优化，均可解决了本章提到的几个挑战。

# 2 Java并发机制的底层实现原理

>Java代码在编译后会变成Java字节码，字节码被类加载器加载到JVM里，JVM执行字节码，最终需要转化为汇编指令在CPU上执行，Java中所使用的并发机制依赖于JVM的实现和CPU的指令。本章我们将深入底层一起探索下Java并发机制的底层实现原理。


## 2.1 volatile的应用
```
它比synchronized的使用和执行成本更低，因为它不会引起线程上下文的切换和调度。
```

### 2.1.1 volatile的定义与实现原理
Java语言规范第3版中对volatile的定义如下：

>Java编程语言允许线程访问共享变量，为了确保共享变量能被准确和一致地更新，线程应该确保通过排他锁单独获得这个变量。Java语言提供了volatile，在某些情况下比锁要更加方便。如果一个字段被声明成volatile，Java线程内存模型确保所有线程看到这个变量的值是一致的。

实现原理相关的CPU术语与说明：

|术语|英文单词|术语描述|
|---|--------|-------|
|内存屏障|memory barriers|是一组处理器指令,用于实现对内存操作的顺序限制|
|缓冲行|cache line|缓存中可以分配的最小存储单位。处理器填写缓存线时会加载整个缓存线,需要使用多个主内存读周期|
|原子操作|atomic operation|不可中断的一个或一系列操作|
|缓冲行填充|cache line fill|当处理器识别到从内存中读取操作数是可缓存的,处理器读取整个缓存行到适当的缓存(L1,L2,L3的或所有)|
|缓冲命中|cache hit|如果进行高速缓存行填充操作的内存位置仍然是下次处理器访问的地址时,处理器从缓存中读取操作数,而不是从内存读取|
|写命中|write hit|当处理器将操作数写回到一个内存缓存的区域时,它首先会检查这个缓存的内存地址是否在缓存行中,如果存在一个有效的缓存行,则处理器将这个操作数写回到缓存,而不是写回到内存,这个操作被称为写命中|
|写缺失|write misses the cache|一个有效的缓存行被写入到不存在的内存区域|

```
有volatile变量修饰的共享变量进行写操作的时候在多核处理器下会引发了两件事情:
1. 将当前处理器缓存行的数据写回到系统内存。
2. 这个写回内存的操作会使在其他CPU里缓存了该内存地址的数据无效。
```

### 2.1.2 volatile的使用优化
追加字节能优化性能？（共享变量追加到64字节）
为什么追加64字节能够提高并发编程的效率呢？
    如果队列的头节点和尾节点都不足64字节的话，处理器会将它们都读到同一个高速缓存行中，在多处理器下每个处理器都会缓存同样的头、尾节点，当一个处理器试图修改头节点时，会将整个缓存行锁定，那么在缓存一致性机制的作用下，会导致其他处理器不能访问自己高速缓存中的尾节点，而队列的入队和出队操作则需要不停修改头节点和尾节点，所以在多处理器的情况下将会严重影响到队列的入队和出队效率。
那么是不是在使用volatile变量时都应该追加到64字节呢？
    缓存行非64字节宽的处理器。
    共享变量不会被频繁地写。

## 2.2 synchronized的实现原理与应用

>介绍Java SE 1.6中为了减少获得锁和释放锁带来的性能消耗而引入的偏向锁和轻量级锁，以及锁的存储结构和升级过程。

>利用synchronized实现同步的基础：Java中的每一个对象都可以作为锁。具体表现为以下三种形式:
>1. 对于普通同步方法，锁是当前实例对象
>2. 对于静态同步方法，锁是当前类的Class对象
>3. 对于同步方法块，锁是synchonized括号里配置的对象。

### 2.2.0 当一个线程试图访问同步代码块时，它首先必须得到锁，退出或抛出异常时必须释放锁。那么锁到底存在哪里呢？锁里面会存储什么信息呢？
>monitorenter monitorexit
>    代码块同步是使用monitorenter和monitorexit指令实现的，而方法同步是使用另外一种方式实现的。但是，方法的同步同样可以使用这两个指令来实现。

### 2.2.1 Java对象头

>synchronized用的锁是存在Java对象头里的。如果对象是数组类型，则虚拟机用3个字宽（Word）存储对象头，如果对象是非数组类型，则用2字宽存储对象头。在32位虚拟机中，1字宽等于4字节，即32bit

|长度|内容|说明|
|----|---|----|
|32/64bit|Mark Word|存储对象的hashcode或锁信息等|
|32/64bit|Class Metadata Address|存储到对象类型数据的指针|
|32/32bit|Array length|数组的长度（如果当前对象是数组）|

```
32位JVM的Mark Word的默认存储结构如下：
```
|锁状态|25bit|4bit|1bit是否偏向锁|2bit锁标志位|
|-----|-----|----|-------------|------------|
|无锁状态|对象的hashcode|对象分代年龄|0|01|

```
在运行期间，Mark Word里存储的数据会随着锁标志位的变化而变化。Mark Word可能变化为存储以下4种数据
```
![MarkWorld Status Change](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/MarkwordInRuntime.jpg?raw=true)

```
64bit Mark Word
```
![64 bit Mark Word](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/64bitMarkWord.jpg?raw=true)

### 2.2.2 锁的升级与对比
```
Java SE 1.6 开始引入了“偏向锁”和“轻量级锁”，锁一共有4种状态，从高到低依次是：
无锁状态、偏向锁状态、轻量级锁状态、重量级锁状态
这几个状态会随着竞争情况逐渐升级。锁可以升级但不能降级，这种策略是为了提高获得锁和释放锁的效率。
```

#### 2.2.2.1 偏向锁

>大多数情况下，锁不仅不存在多线程竞争，而且总是由同一线程多次获得，为了让线程获得锁的代价更低而引入了偏向锁。
>偏向锁会记录锁对象当前的线程id，以及标记当前对象使用的是偏向锁


##### 2.2.2.1.1 偏向锁的撤销
>偏向锁使用了一种等到竞争出现才释放锁的机制，所以当其他线程尝试竞争偏向锁时，持有偏向锁的线程才会释放锁。偏向锁的撤销，需要等待全局安全点（在这个时间点上没有正在执行的字节码）。它会首先暂停拥有偏向锁的线程，然后检查持有偏向锁的线程是否活着，如果线程不处于活动状态，则将对象头设置成无锁状态；如果线程仍然活着，拥有偏向锁的栈会被执行，遍历偏向对象的锁记录，栈中的锁记录和对象头的Mark Word要么重新偏向于其他线程，要么恢复到无锁或者标记对象不适合作为偏向锁，最后唤醒暂停的线程

![Prefer Lock](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/PreferLock.jpg?raw=true)

##### 2.2.2.1.2 关闭偏向锁
>偏向锁在Java 6和Java 7里是默认启用的，但是它在应用程序启动几秒钟之后才激活，如有必要可以使用JVM参数来关闭延迟：-XX:BiasedLockingStartupDelay=0。
>如果你确定应用程序里所有的锁通常情况下处于竞争状态，可以通过JVM参数关闭偏向锁：-XX:-UseBiasedLocking=false，那么程序默认会进入轻量级锁状态。


#### 2.2.2.2 轻量级锁

##### 2.2.2.2.1 轻量锁加锁
>线程在执行同步块之前，JVM会先在当前线程的栈桢中创建用于存储锁记录的空间，并将对象头中的Mark Word复制到锁记录中，官方称为Displaced Mark Word。然后线程尝试使用CAS将对象头中的Mark Word替换为指向锁记录的指针。如果成功，当前线程获得锁，如果失败，表示其他线程竞争锁，当前线程便尝试使用自旋来获取锁。

##### 2.2.2.2.2 轻量锁的解锁
>轻量级解锁时，会使用原子的CAS操作将Displaced Mark Word替换回到对象头，如果成功，则表示没有竞争发生。如果失败，表示当前锁存在竞争，锁就会膨胀成重量级锁。


![Lite Lock Processes](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/LiteLock.jpg?raw=true)


>因为自旋会消耗CPU，为了避免无用的自旋（比如获得锁的线程被阻塞住了），一旦锁升级
成重量级锁，就不会再恢复到轻量级锁状态。当锁处于这个状态下，其他线程试图获取锁时，
都会被阻塞住，当持有锁的线程释放锁之后会唤醒这些线程，被唤醒的线程就会进行新一轮
的夺锁之争。

#### 2.2.2.3 锁的优缺点对比
|锁|优点|缺点|适用场景|
|--|---|----|-------|
|偏向锁|加锁和解锁不需要额外的消耗,和执行非同步方法相比亿存在纳秒级的差距|如果线程间存在锁竞争,会带来额外的锁撤销的消耗|适用于只有一个线程访问同步块场景|
|轻量级锁|竞争的线程不会阻塞，提高了程序的响应速度|如果始终得不到锁竞争的线程，使用自旋会消耗CPU|追求响应时间，同步块执行速度非常快|
|重量级锁|线程竞争不使用自旋，不会消耗CPU|线程阻塞，响应时间缓慢|追求吞吐量，同步块执行速度较长|

## 2.3 原子操作的实现原理
>原子（atomic）本意是“不能被进一步分割的最小粒子”，而原子操作（atomic operation）意为“不可被中断的一个或一系列操作”。在多处理器上实现原子操作就变得有点复杂。让我们一起来聊一聊在Intel处理器和Java里是如何实现原子操作的。

### 2.3.1 术语定义
|术语名称|英文|解释|
|-------|----|----|
|缓存行|Cache line|缓存的最小单位|
|比较并交换|Compare and Swap|CAS操作需要输入两个数值,一个旧值(期望操作前的值)和个新值,在操作期间先比较旧值有没有发生变化,如果没有发生变化,才交换成新值,发生了变化则不交换|
|CPU流水线|CPU pipeline|CPU流水线的工作方式就像工业生产上的装配流水线,在CPU中由5~6个不同功能的电路单元组成一条指令处理流水线,然后将一条X86指令分成5~6步后再由这些电路单元分别执行,这样就能实现在一个CPU时钟周期完成一条指令,因此提高CPU的运算速度|
|内存顺序冲突|Memory order violation|内存顺序冲突一般是由假共享引起的,假共享是指多个CPU同时修改同一个缓存行的不同部分而引起其中一个CPU的操作无效,当出现这个内存顺序冲突时,CPU必须清空流水线|

### 2.3.2 处理器如何实现原子操作
1. 使用总线保证原子性
2. 使用缓存锁保证原子性
\# 两种情况下处理器不会使用缓存锁定
    第一种情况：操作的数据不能被缓存在处理器内部，或操作的数据跨多个缓存行时，处理器会调用总线锁定。
    第二种情况是：有些处理器不支持缓存锁定

### 2.3.3 Java 如何实现原子操作
```
答案是循环CAS和锁
```
#### 2.3.3.1 使用循环CAS实现原子操作
    自旋CAS实现的基本思路就是循环进行CAS操作直到成功为止
\# 从Java 1.5开始，JDK的并发包里提供了一些类来支持原子操作，如AtomicBoolean（用原子方式更新的boolean值）、AtomicInteger（用原子方式更新的int值）和AtomicLong（用原子方式更新的long值）。这些原子包装类还提供了有用的工具方法，比如以原子的方式将当前值自增1和自减1。

#### 2.3.3.2 CAS实现原子操作的三大问题
1. [ABA问题](https://www.zhihu.com/question/23281499)
   ABA问题的解决思路就是使用版本号。在变量前面追加上版本号，每次变量更新的时候把版本号加1
2. 循环时间长开销大
    自旋CAS如果长时间不成功，会给CPU带来非常大的执行开销。如果JVM能支持处理器提供的pause指令，那么效率会有一定的提升。pause指令有两个作用：第一，它可以延迟流水线执行指令（de-pipeline），使CPU不会消耗过多的执行资源，延迟的时间取决于具体实现的版本，在一些处理器上延迟时间是零；第二，它可以避免在退出循环的时候因内存顺序冲突（Memory Order Violation）而引起CPU流水线被清空（CPU Pipeline Flush），从而提高CPU的执行效率。
3. 只能保证一个共享变量的原子操作
    对多个共享变量操作时，这个时候可以用锁。或者把多个变量合并成一个共享变量来操作

#### 2.3.3.3 使用锁机制实现原子操作
>锁机制保证了只有获得锁的线程才能够操作锁定的内存区域。
>有意思的是除了偏向锁，JVM实现锁的方式都用了循环CAS，即当一个线程想进入同步块的时候使用循环CAS的方式来获取锁，当它退出同步块的时候使用循环CAS释放锁。


## 2.4 小结
Java中的大部分容器和框架都依赖于本章介绍的volatile和原子操作的实现原理


# 3 Java内存模型

可见性：一个线程对共享变量值的修改，能够及时地被其他线程看到。
共享变量：如果一个变量在多个线程的工作内存中都存在副本，那么这个变量就是几个线程的共享变量。

## 3.1 Java内存模型基础

### 3.1.1 并发编程模型的两个关键问题
两个关键问题：
    1. 线程之间如何通信
    2. 线程之间如何同步
线程之间的通信机制有两种：内存共享和消息传递
**Java采用的是共享内存模型**
Java线程之间的通信总是隐式进行，整个通信过程对程序员完全透明。如果编写多线程程序的Java程序员不理解隐式进行的线程之间通信的工作机制，很可能会遇到各种奇怪的内存可见性问题。

### 3.1.2 Java内存模型的抽象结构
在Java中，所有实例域、静态域和数组元素都存储在堆内存中，堆内存在线程之间共享。
局部变量，方法定义参数和异常处理器参数不会再线程之间共享，它们不会有内存可见性的问题，也不会受内存模型的影响

![Java Memory Model](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/JavaMemoryModel.jpg?raw=true)

Java线程之间的通信由Java内存模型（本文简称为JMM）控制，JMM决定一个线程对共享变量的写入何时对另一个线程可见。从抽象的角度来看，JMM定义了线程和主内存之间的抽象关系：线程之间的共享变量存储在主内存（Main Memory）中，每个线程都有一个私有的本地内存（Local Memory），本地内存中存储了该线程以读/写共享变量的副本

线程A与线程B通信：
    1. 线程A把本地内存A中更新过的共享变量刷新到主内存中去。
    2. 线程B到主内存中去读取线程A之前已更新过的共享变量。
    
![Java Memory Model](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ThreadCommunication.jpg?raw=true)

从整体来看，这两个步骤实质上是线程A在向线程B发送消息，而且这个通信过程必须要经过主内存。JMM通过控制主内存与每个线程的本地内存之间的交互，来为Java程序员提供内存可见性保证。

### 3.1.3 从源代码到指令序列的重排序

在执行程序时，为了提高性能，编译器和处理器常常会对指令做重排序。重排序分3种类型：
    1. 编译器优化的重排序
    2. 指令级并行重排序
    3. 内存系统的重排序

![Reorder Flow](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ReorderFlow.jpg?raw=true)

上述的1属于编译器重排序，2和3属于处理器重排序。这些重排序可能会导致多线程程序出现内存可见性问题。对于编译器，JMM的编译器重排序规则会禁止特定类型的编译器重排序（不是所有的编译器重排序都要禁止）。对于处理器重排序，JMM的处理器重排序规则会要求Java编译器在生成指令序列时，插入特定类型的内存屏障（Memory Barriers，Intel称之为Memory Fence）指令，通过内存屏障指令来禁止特定类型的处理器重排序。

### 3.1.4 并发编程模型的分类
为了保证内存可见性，Java编译器在生成指令序列的适当位置会插入内存屏障指令来禁止特定类型的处理器重排序。JMM把内存屏障指令分为4类：

![Memory Bariers](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/MemoryBarriers.jpg?raw=true)

### 3.1.5 happens-before简介

在JMM中，如果一个操作执行的结果需要对另一个操作可见，那么这两个操作之间必须要存在happens-before关系。这里提到的两个操作既可以是在一个线程之内，也可以是在不同线程之间。

与程序员密切相关的happens-before规则如下：
```
程序顺序规则：一个线程中的每个操作，happens-before于该线程中的任意后续操作。

监视器锁规则：对一个锁的解锁，happens-before于随后对这个锁的加锁。

volatile变量规则：对一个volatile域的写，happens-before于任意后续对这个volatile域的读。

传递性：如果A happens-before B，且B happens-before C，那么A happens-before C。
```

JMMAndHappensBefore

![JMM And Happens Before](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/JMMAndHappensBefore.jpg?raw=true)

## 3.2 重排序
重排序是指编译器和处理器为了优化程序性能而对指令序列进行重新排序的一种手段。

### 3.2.1 数据依赖性

![Data Dependency](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/DataDependency.jpg?raw=true)

上面3种情况，只要重排序两个操作的执行顺序，程序的执行结果就会被改变。
前面提到过，编译器和处理器可能会对操作做重排序。编译器和处理器在重排序时，会遵守数据依赖性，编译器和处理器不会改变存在数据依赖关系的两个操作的执行顺序。
这里所说的数据依赖性仅针对单个处理器中执行的指令序列和单个线程中执行的操作，不同处理器之间和不同线程之间的数据依赖性不被编译器和处理器考虑。

### 3.2.2 as-if-serial语义
as-if-serial语义的意思是：不管怎么重排序（编译器和处理器为了提高并行度），（单线程）程序的执行结果不能被改变。编译器、runtime和处理器都必须遵守as-if-serial语义。
asif-serial语义使单线程程序员无需担心重排序会干扰他们，也无需担心内存可见性问题。

### 3.2.3 程序规则
在计算机中，软件技术和硬件技术有一个共同的目标：在不改变程序执行结果的前提下，尽可能提高并行度。编译器和处理器遵从这一目标，从happens-before的定义我们可以看出，JMM同样遵从这一目标。

### 3.2.4 重排序对多线程的影响

在单线程程序中，对存在控制依赖的操作重排序，不会改变执行结果（这也是as-if-serial语义允许对存在控制依赖的操作做重排序的原因）；但在多线程程序中，对存在控制依赖的操作重排序，可能会改变程序的执行结果。


## 3.3 顺序一致性
顺序一致性内存模型是一个理论参考模型，在设计的时候，处理器的内存模型和编程语言的内存模型都会以顺序一致性内存模型作为参照。

### 3.3.1　数据竞争与顺序一致性
当程序未正确同步时，就可能会存在数据竞争。Java内存模型规范对数据竞争的定义如下：

```
在一个线程中写一个变量
在另一个线程中度变量
而且写和读没有通过同步来排序
```

当代码中包含数据竞争时，程序的执行往往产生违反直觉的结果（前一章的示例正是如此）。如果一个多线程程序能正确同步，这个程序将是一个没有数据竞争的程序。

JMM对正确同步的多线程程序的内存一致性做了如下保证:

如果程序是正确同步的，程序的执行将具有顺序一致性（Sequentially Consistent）——即程序的执行结果与该程序在顺序一致性内存模型中的执行结果相同。马上我们就会看到，这对于程序员来说是一个极强的保证。这里的同步是指广义上的同步，包括对常用同步原语（synchronized、volatile和final）的正确使用。


### 3.3.2 顺序一致性内存模型
顺序一致性内存模型是一个被计算机科学家理想化了的理论参考模型，它为程序员提供了极强的内存可见性保证。顺序一致性内存模型有两大特性。
1）一个线程中的所有操作必须按照程序的顺序来执行。
2）（不管程序是否同步）所有线程都只能看到一个单一的操作执行顺序。在顺序一致性内存模型中，每个操作都必须原子执行且立刻对所有线程可见。


### 3.3.3 同步程序的顺序一致性效果
顺序一致性模型中，所有操作完全按程序的顺序串行执行。而在JMM中，临界区内的代码可以重排序（但JMM不允许临界区内的代码“逸出”到临界区之外，那样会破坏监视器的语义）。JMM会在退出临界区和进入临界区这两个关键时间点做一些特别处理，使得线程在这两个时间点具有与顺序一致性模型相同的内存视图。

### 3.3.4 未同步程序的执行特性

未同步程序在JMM中的执行时，整体上是无序的，其执行结果无法预知。未同步程序在两个模型中的执行特性有如下几个差异。
1）顺序一致性模型保证单线程内的操作会按程序的顺序执行，而JMM不保证单线程内的操作会按程序的顺序执行（比如上面正确同步的多线程程序在临界区内的重排序）。这一点前面已经讲过了，这里就不再赘述。
2）顺序一致性模型保证所有线程只能看到一致的操作执行顺序，而JMM不保证所有线程能看到一致的操作执行顺序。这一点前面也已经讲过，这里就不再赘述。
3）JMM不保证对64位的long型和double型变量的写操作具有原子性，而顺序一致性模型保证对所有的内存读/写操作都具有原子性。

## 3.4 volatile的内存语义
当声明共享变量为volatile后，对这个变量的读/写将会很特别。为了揭开volatile的神秘面纱，下面将介绍volatile的内存语义及volatile内存语义的实现。

### 3.4.1 volatile的特性
理解volatile特性的一个好方法是把对volatile变量的单个读/写，看成是使用同一个锁对这些单个读/写操作做了同步。

下面两段代码意义一样：
```
class VolatileFeaturesExample {
    volatile long vl = 0L; // 使用volatile声明64位的long型变量
    public void set(long l) {
        vl = l; // 单个volatile变量的写
    }
    public void getAndIncrement () {
        vl++; //复合（多个）volatile变量的读/写
    }
    public long get() {
        return vl; // 单个volatile变量的读
    }
}
```
```
class VolatileFeaturesExample {
    long vl = 0L; // 64位的long型普通变量
    public synchronized void set(long l) { // 对单个的普通变量的写用同一个锁同步
        vl = l;
    }
    public void getAndIncrement () { // 普通方法调用
        long temp = get(); // 调用已同步的读方法
        temp += 1L; // 普通写操作
        set(temp); // 调用已同步的写方法
    }
    public synchronized long get() { // 对单个的普通变量的读用同一个锁同步
        return vl;
    }
}
```

锁的happens-before规则保证释放锁和获取锁的两个线程之间的内存可见性，这意味着对一个volatile变量的读，总是能看到（任意线程）对这个volatile变量最后的写入。

简而言之，volatile变量自身具有下列特性:
1. 可见性。对一个volatile变量的读，总是能看到（任意线程）对这个volatile变量最后的写入。
2. 原子性：对任意单个volatile变量的读/写具有原子性，但类似于volatile++这种复合操作不具有原子性。

### 3.4.2 volatile写-读建立的happens-before关系
从JDK5开始，volatile变量的写-读可以实现线程之间的通信。
从内存语义的角度来说，volatile的写-读与锁的释放-获取有相同的内存效果：
1. volatile写和锁的释放有相同的内存语义；
2. volatile读与锁的获取有相同的内存语义。


### 3.4.3 volatile 写-读的内存语义
当写一个volatile变量时，JMM会把该线程对应的本地内存中的共享变量值刷新到主内存。

volatile读的内存语义如下：
当读一个volatile变量时，JMM会把该线程对应的本地内存置为无效。线程接下来将从主内存中读取共享变量。

下面对volatile写和volatile读的内存语义做个总结。
1. 线程A写一个volatile变量，实质上是线程A向接下来将要读这个volatile变量的某个线程发出了（其对共享变量所做修改的）消息。
2. 线程B读一个volatile变量，实质上是线程B接收了之前某个线程发出的（在写这个volatile变量之前对共享变量所做修改的）消息。
3. 线程A写一个volatile变量，随后线程B读这个volatile变量，这个过程实质上是线程A通过主内存向线程B发送消息。

### 3.4.4 volatile 内存语义的实现
JMM采取保守策略。下面是基于保守策略的JMM内存屏障插入策略：
1. ·在每个volatile写操作的前面插入一个StoreStore屏障。
2. ·在每个volatile写操作的后面插入一个StoreLoad屏障。
3. ·在每个volatile读操作的后面插入一个LoadLoad屏障。
4. ·在每个volatile读操作的后面插入一个LoadStore屏障。

### 3.4.5 　JSR-133为什么要增强volatile的内存语义
在功能上，锁比volatile更强大；在可伸缩性和执行性能上，volatile更有优势

## 3.5　锁的内存语义
众所周知，锁可以让临界区互斥执行。这里将介绍锁的另一个同样重要，但常常被忽视的功能：锁的内存语义。

### 3.5.1 锁的释放-获取简历的happens-before关系
锁是Java并发编程中最重要的同步机制。锁除了让临界区互斥执行外，还可以让释放锁的线程向获取同一个锁的线程发送消息。

### 3.5.2 锁的释放和获取的内存语义
下面对锁释放和锁获取的内存语义做个总结：
1. ·线程A释放一个锁，实质上是线程A向接下来将要获取这个锁的某个线程发出了（线程A对共享变量所做修改的）消息。
2. ·线程B获取一个锁，实质上是线程B接收了之前某个线程发出的（在释放这个锁之前对共享变量所做修改的）消息。
3. ·线程A释放锁，随后线程B获取这个锁，这个过程实质上是线程A通过主内存向线程B发送消息。

### 3.5.3 锁内存语义的实现
现在对公平锁和非公平锁的内存语义做个总结。
1. ·公平锁和非公平锁释放时，最后都要写一个volatile变量state。
2. ·公平锁获取时，首先会去读volatile变量。
2. ·非公平锁获取时，首先会用CAS更新volatile变量，这个操作同时具有volatile读和volatile写的内存语义。
锁释放-获取的内存语义的实现至少有下面两种方式:
1. 利用volatile变量的写-读所具有的内存语义。
2. 利用CAS所附带的volatile读和volatile写的内存语义。


### 3.5.4 concurrent包的实现
Java的CAS同时具有volatile读和volatile写的内存语义，因此Java线程之间的通信现在有了下面4种方式：
1）A线程写volatile变量，随后B线程读这个volatile变量。
2）A线程写volatile变量，随后B线程用CAS更新这个volatile变量。
3）A线程用CAS更新一个volatile变量，随后B线程用CAS更新这个volatile变量。
4）A线程用CAS更新一个volatile变量，随后B线程读这个volatile变量。

仔细分析concurrent包的源代码实现，会发现一个通用化的实现模式。
首先，声明共享变量为volatile。
然后，使用CAS的原子条件更新来实现线程之间的同步。
同时，配合以volatile的读/写和CAS所具有的volatile读和写的内存语义来实现线程之间的通信。

![Concurrent Package Implement](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ConcurrentPackageImpl.jpg?raw=true)

## 3.6 final 域的内存语义
与前面介绍的锁和volatile相比，对final域的读和写更像是普通的变量访问。

### 3.6.1 final域的重排序规则

对于final域，编译器和处理器要遵守两个重排序规则。
1）在构造函数内对一个final域的写入，与随后把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序。
2）初次读一个包含final域的对象的引用，与随后初次读这个final域，这两个操作之间不能重排序。

### 3.6.2　写final域的重排序规则
写final域的重排序规则禁止把final域的写重排序到构造函数之外。这个规则的实现包含下面2个方面。
1）JMM禁止编译器把final域的写重排序到构造函数之外。
2）编译器会在final域的写之后，构造函数return之前，插入一个StoreStore屏障。这个屏障禁止处理器把final域的写重排序到构造函数之外。

### 3.6.3　读final域的重排序规则
读final域的重排序规则可以确保：在读一个对象的final域之前，一定会先读包含这个final域的对象的引用。在这个示例程序中，如果该引用不为null，那么引用对象的final域一定已经被A线程初始化过了。

### 3.6.4 final域为引用类型
对于引用类型，写final域的重排序规则对编译器和处理器增加了如下约束：在构造函数内对一个final引用的对象的成员域的写入，与随后在构造函数外把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序。


### 3.6.5 为什么final引用不能从构造函数内“溢出”
在构造函数返回前，被构造对象的引用不能为其他线程所见，因为此时的final域可能还没有被初始化。在构造函数返回后，任意线程都将保证能看到final域正确初始化之后的值。

### 3.6.6 final语义在处理器中的实现
写final域的重排序规则会要求编译器在final域的写之后，构造函数return之前插入一个StoreStore障屏。读final域的重排序规则要求编译器在读final域的操作前面插入一个LoadLoad屏障。

### 3.6.7 JSR-133为什么要增强final的语义
在旧的Java内存模型中，一个最严重的缺陷就是线程可能看到final域的值会改变。最常见的例子就是在旧的Java内存模型中，String的值可能会改变。

通过为final域增加写和读重排序规则，可以为Java程序员提供初始化安全保证：只要对象是正确构造的（被构造对象的引用在构造函数中没有“逸出”），那么不需要使用同步（指lock和volatile的使用）就可以保证任意线程都能看到这个final域在构造函数中被初始化之后的值。

## 3.7 happens-before


### 3.7.1 JMM的设计

从JMM设计者的角度，在设计JMM时，需要考虑两个关键因素：
1. ·程序员对内存模型的使用。程序员希望内存模型易于理解、易于编程。程序员希望基于一个强内存模型来编写代码。
2. ·编译器和处理器对内存模型的实现。编译器和处理器希望内存模型对它们的束缚越少越好，这样它们就可以做尽可能多的优化来提高性能。编译器和处理器希望实现一个弱内存模型。

JMM把happens-before要求禁止的重排序分为了下面两类：
1. ·会改变程序执行结果的重排序。
2. ·不会改变程序执行结果的重排序。

JMM对这两种不同性质的重排序，采取了不同的策略，如下：
1. ·对于会改变程序执行结果的重排序，JMM要求编译器和处理器必须禁止这种重排序。
2. ·对于不会改变程序执行结果的重排序，JMM对编译器和处理器不做要求（JMM允许这种重排序）。


### 3.7.2 happens-before的定义

JSR-133使用happens-before的概念来指定两个操作之间的执行顺序。由于这两个操作可以在一个线程之内，也可以是在不同线程之间。因此，JMM可以通过happens-before关系向程序员提供跨线程的内存可见性保证（如果A线程的写操作a与B线程的读操作b之间存在happensbefore关系，尽管a操作和b操作在不同的线程中执行，但JMM向程序员保证a操作将对b操作可见）

对happens-before关系的定义如下：
1）如果一个操作happens-before另一个操作，那么第一个操作的执行结果将对第二个操作可见，而且第一个操作的执行顺序排在第二个操作之前。
2）两个操作之间存在happens-before关系，并不意味着Java平台的具体实现必须要按照happens-before关系指定的顺序来执行。如果重排序之后的执行结果，与按happens-before关系来执行的结果一致，那么这种重排序并不非法（也就是说，JMM允许这种重排序）。


happens-before关系本质上和as-if-serial语义是一回事：
1. ·as-if-serial语义保证单线程内程序的执行结果不被改变，happens-before关系保证正确同
步的多线程程序的执行结果不被改变。
2. ·as-if-serial语义给编写单线程程序的程序员创造了一个幻境：单线程程序是按程序的顺序来执行的。happens-before关系给编写正确同步的多线程程序的程序员创造了一个幻境：正确同步的多线程程序是按happens-before指定的顺序来执行的。

as-if-serial语义和happens-before这么做的目的，都是为了在不改变程序执行结果的前提下，尽可能地提高程序执行的并行度。

### 3.7.3 happens-before规则

1）程序顺序规则：一个线程中的每个操作，happens-before于该线程中的任意后续操作。
2）监视器锁规则：对一个锁的解锁，happens-before于随后对这个锁的加锁。
3）volatile变量规则：对一个volatile域的写，happens-before于任意后续对这个volatile域的读。
4）传递性：如果A happens-before B，且B happens-before C，那么A happens-before C。
5）start()规则：如果线程A执行操作ThreadB.start()（启动线程B），那么A线程的ThreadB.start()操作happens-before于线程B中的任意操作。
6）join()规则：如果线程A执行操作ThreadB.join()并成功返回，那么线程B中的任意操作happens-before于线程A从ThreadB.join()操作成功返回。

## 3.8 双重检查锁定域延迟初始化
有时候需要采用延迟初始化来降低初始化类和创建对象的开销。双重检查锁定是常见的延迟初始化技术，但它是一个错误的用法。

### 3.8.1 双重检查锁定的由来
```
public class UnsafeLazyInitialization {
    private static Instance instance;
    public static Instance getInstance() {
        if (instance == null) // 1：A线程执行
            instance = new Instance(); // 2：B线程执行
        return instance;
    }
}

//性能开销大
public class SafeLazyInitialization {
    private static Instance instance;
    public synchronized static Instance getInstance() {
        if (instance == null)
            instance = new Instance();
        return instance;
    }
}

//性能还可以，但是有缺陷
public class DoubleCheckedLocking {                         // 1
    private static Instance instance;                       // 2
    public static Instance getInstance() {                  // 3
        if (instance == null) {                             // 4:第一次检查
            synchronized (DoubleCheckedLocking.class) {     // 5:加锁
                if (instance == null)                       // 6:第二次检查
                    instance = new Instance();              // 7:问题的根源出在这里
            }                                               // 8
        }                                                   // 9
        return instance;                                    // 10
    }                                                       // 11
}

//双重检查锁定看起来似乎很完美，但这是一个错误的优化！在线程执行到第4行，代码读取到instance不为null时，instance引用的对象有可能还没有完成初始化。
```

### 3.8.2 问题的根源
```
/**
* 前面的双重检查锁定示例代码的第7行（instance=new Singleton();）创建了一个对象。这一行代码可以分解为如下的3行伪代码。
**/
memory = allocate();　　// 1：分配对象的内存空间
ctorInstance(memory);　 // 2：初始化对象
instance = memory;　　 // 3：设置instance指向刚分配的内存地址
//2，3 可能会被重排序
```