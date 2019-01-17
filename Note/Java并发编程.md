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

### 1.3.4 在资源限制情况下进行并发编程
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

![Java Memory Model](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/JavaMemoryModel.JPG?raw=true)

Java线程之间的通信由Java内存模型（本文简称为JMM）控制，JMM决定一个线程对共享变量的写入何时对另一个线程可见。从抽象的角度来看，JMM定义了线程和主内存之间的抽象关系：线程之间的共享变量存储在主内存（Main Memory）中，每个线程都有一个私有的本地内存（Local Memory），本地内存中存储了该线程以读/写共享变量的副本

线程A与线程B通信：
    1. 线程A把本地内存A中更新过的共享变量刷新到主内存中去。
    2. 线程B到主内存中去读取线程A之前已更新过的共享变量。
    
![Java Memory Model](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ThreadCommunication.JPG?raw=true)

从整体来看，这两个步骤实质上是线程A在向线程B发送消息，而且这个通信过程必须要经过主内存。JMM通过控制主内存与每个线程的本地内存之间的交互，来为Java程序员提供内存可见性保证。

### 3.1.3 从源代码到指令序列的重排序

在执行程序时，为了提高性能，编译器和处理器常常会对指令做重排序。重排序分3种类型：
    1. 编译器优化的重排序
    2. 指令级并行重排序
    3. 内存系统的重排序

![Reorder Flow](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ReorderFlow.JPG?raw=true)

上述的1属于编译器重排序，2和3属于处理器重排序。这些重排序可能会导致多线程程序出现内存可见性问题。对于编译器，JMM的编译器重排序规则会禁止特定类型的编译器重排序（不是所有的编译器重排序都要禁止）。对于处理器重排序，JMM的处理器重排序规则会要求Java编译器在生成指令序列时，插入特定类型的内存屏障（Memory Barriers，Intel称之为Memory Fence）指令，通过内存屏障指令来禁止特定类型的处理器重排序。

### 3.1.4 并发编程模型的分类
为了保证内存可见性，Java编译器在生成指令序列的适当位置会插入内存屏障指令来禁止特定类型的处理器重排序。JMM把内存屏障指令分为4类：

![Memory Bariers](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/MemoryBarriers.JPG?raw=true)

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

![JMM And Happens Before](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/JMMAndHappensBefore.JPG?raw=true)

## 3.2 重排序
重排序是指编译器和处理器为了优化程序性能而对指令序列进行重新排序的一种手段。

### 3.2.1 数据依赖性

![Data Dependency](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/DataDependency.JPG?raw=true)

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

![Concurrent Package Implement](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ConcurrentPackageImpl.JPG?raw=true)

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

在知晓了问题发生的根源之后，我们可以想出两个办法来实现线程安全的延迟初始化。
1）不允许2和3重排序。
2）允许2和3重排序，但不允许其他线程“看到”这个重排序。

### 3.8.3　基于volatile的解决方案
```
public class SafeDoubleCheckedLocking {
    private volatile static Instance instance;
    public static Instance getInstance() {
        if (instance == null) {
            synchronized (SafeDoubleCheckedLocking.class) {
                if (instance == null)
                    instance = new Instance(); // instance为volatile，现在没问题了
            }
        }
        return instance;
    }
}
//当声明对象的引用为volatile后，3.8.2节中的3行伪代码中的2和3之间的重排序，在多线程环境中将会被禁止。
//这个方案本质上是通过禁止图3-39中的2和3之间的重排序，来保证线程安全的延迟初始化。
```

### 3.8.4 基于类初始化的解决方案
JVM在类的初始化阶段（即在Class被加载后，且被线程使用之前），会执行类的初始化。在执行类的初始化期间，JVM会去获取一个锁。这个锁可以同步多个线程对同一个类的初始化。
```
public class InstanceFactory {
    private static class InstanceHolder {
        public static Instance instance = new Instance();
    }
    public static Instance getInstance() {
        return InstanceHolder.instance ;　　// 这里将导致InstanceHolder类被初始化
    }
}
```

初始化一个类，包括执行这个类的静态初始化和初始化在这个类中声明的静态字段。根据Java语言规范，在首次发生下列任意一种情况时，一个类或接口类型T将被立即初始化。
1）T是一个类，而且一个T类型的实例被创建。
2）T是一个类，且T中声明的一个静态方法被调用。
3）T中声明的一个静态字段被赋值。
4）T中声明的一个静态字段被使用，而且这个字段不是一个常量字段。
5）T是一个顶级类（Top Level Class，见Java语言规范的§7.6），而且一个断言语句嵌套在T内部被执行。

Java语言规范规定，对于每一个类或接口C，都有一个唯一的初始化锁LC与之对应。从C到LC的映射，由JVM的具体实现去自由实现。JVM在类初始化期间会获取这个初始化锁，并且每个线程至少获取一次锁来确保这个类已经被初始化过了

## 3.9 Java内存模型

### 3.9.1 处理器的内存模型
顺序一致性内存模型是一个理论参考模型，JMM和处理器内存模型在设计时通常会以顺序一致性内存模型为参照。在设计时，JMM和处理器内存模型会对顺序一致性模型做一些放松，因为如果完全按照顺序一致性模型来实现处理器和JMM，那么很多的处理器和编译器优化都要被禁止，这对执行性能将会有很大的影响。

根据对不同类型的读/写操作组合的执行顺序的放松，可以把常见处理器的内存模型划分为如下几种类型：
1. ·放松程序中写-读操作的顺序，由此产生了Total Store Ordering内存模型（简称为TSO）。
2. ·在上面的基础上，继续放松程序中写-写操作的顺序，由此产生了Partial Store Order内存模型（简称为PSO）。
3. ·在前面两条的基础上，继续放松程序中读-写和读-读操作的顺序，由此产生了RelaxedMemory Order内存模型（简称为RMO）和PowerPC内存模型。

越是追求性能的处理器，内存模型设计得会越弱。因为这些处理器希望内存模型对它们的束缚越少越好，这样它们就可以做尽可能多的优化来提高性能。

### 3.9.2 各种内存模型之间的关系
常见的4种处理器内存模型比常用的3中语言内存模型要弱，处理器内存模型和语言内存模型都比顺序一致性内存模型要弱。同处理器内存模型一样，越是追求执行性能的语言，内存模型设计得会越弱。

### 3.9.3 JMM的内存可见性保证

按程序类型，Java程序的内存可见性保证可以分为下列3类:
1. ·单线程程序。单线程程序不会出现内存可见性问题。编译器、runtime和处理器会共同确保单线程程序的执行结果与该程序在顺序一致性模型中的执行结果相同。
2. ·正确同步的多线程程序。正确同步的多线程程序的执行将具有顺序一致性（程序的执行结果与该程序在顺序一致性内存模型中的执行结果相同）。这是JMM关注的重点，JMM通过限制编译器和处理器的重排序来为程序员提供内存可见性保证。
3. ·未同步/未正确同步的多线程程序。JMM为它们提供了最小安全性保障：线程执行时读取到的值，要么是之前某个线程写入的值，要么是默认值（0、null、false）。

### 3.9.4　JSR-133对旧内存模型的修补
JSR-133对JDK 5之前的旧内存模型的修补主要有两个:
1. ·增强volatile的内存语义。旧内存模型允许volatile变量与普通变量重排序。JSR-13严格
2. 限制volatile变量与普通变量的重排序，使volatile的写-读和锁的释放-获取具有相同的内存语义。
3. ·增强final的内存语义。在旧内存模型中，多次读取同一个final变量的值可能会不相同。为此，JSR-133为final增加了两个重排序规则。在保证final引用不会从构造函数内逸出的情况下，final具有了初始化安全性。

## 3.10 小结
    本章对Java内存模型做了比较全面的解读。希望读者阅读本章之后，对Java内存模型够有一个比较深入的了解；同时，也希望本章可帮助读者解决在Java并发编程中经常遇到的各种内存可见性问题。


# 4 Java并发编程基础
本章将着重介绍Java并发编程的基础知识，从启动一个线程到线程间不同的通信方式，最后通过简单的线程池示例以及应用（简单的Web服务器）来串联本章所介绍的内容。

## 4.1 线程简介

### 4.1.1 什么是线程

一个普通的Java程序包含哪些线程？
```
public class MultiThread{
    public static void main(String[] args) {
        // 获取Java线程管理MXBean
        ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
        // 不需要获取同步的monitor和synchronizer信息，仅获取线程和线程堆栈信息
        ThreadInfo[] threadInfos = threadMXBean.dumpAllThreads(false, false);
        // 遍历线程信息，仅打印线程ID和线程名称信息
        for (ThreadInfo threadInfo : threadInfos) {
            System.out.println("[" + threadInfo.getThreadId() + "] " + ThreadInfo.getThreadName());
        }
    }
}
```
Result:
```
[4] Signal Dispatcher　 // 分发处理发送给JVM信号的线程
[3] Finalizer　　　　 // 调用对象finalize方法的线程
[2] Reference Handler // 清除Reference的线程
[1] main　 　　　　 // main线程，用户程序入口
```

### 4.1.2 为什么使用多线程
    1. 更多的处理器核心
    2. 更快的响应时间
    3. 更好的编程模型

### 4.1.3 线程优先级
设置线程优先级时：
1. 针对频繁阻塞（休眠或者I/O操作）的线程需要设置较高优先级
2. 偏重计算（需要较多CPU时间或者偏运算）的线程则设置较低的优先级，确保处理器不会被独占。
3. 程序正确性不能依赖线程的优先级高低。

### 4.1.4 线程的状态
在给定的一个时刻，线程只能处于其中的一个状态:
|状态名称|说明|
|-------|----|
|NEW|初始状态，线程被构建，但是还没有调用start()方法|
|RUNNABLE|运行状态，Java线程将操作系统中的就绪和运行两种状态笼统地称作“运行中”|
|BLOCKED|阻塞状态，表示线程阻塞于锁|
|WAITING|等待状态，表示线程进入等待状态，进入该状态表示当前线程需要等待其他线程做出一些特定动作（通知或中断）|
|TIME_WAITING|超时等待状态，该状态不同于WAITING，它是可以在指定的时间自行返回的|
|TERMINATED|终止状态，表示当前线程已经执行完毕|

![Transformation of Java Thread State](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/JavaThreadStateTransform.JPG?raw=true)

### 4.1.5 Daemon 线程

Daemon线程是一种支持型线程，因为它主要被用作程序中后台调度以及支持性工作。这意味着，当一个Java虚拟机中不存在非Daemon线程的时候，Java虚拟机将会退出。可以通过调用Thread.setDaemon(true)将线程设置为Daemon线程。

\# Daemon属性需要在启动线程之前设置，不能在启动线程之后设置。
\# 在构建Daemon线程时，不能依靠finally块中的内容来确保执行关闭或清理资源的逻辑。

## 4.2 启动和终止线程

### 4.2.1 构造线程
继承自父进程：
1. 线程组
2. 线程优先级
3. 是否daemon线程
4. contextClassLoader
5. 可继承的ThreadLocal
构造时分配：
6. 线程ID 

### 4.2.2 启动线程
线程对象在初始化完成之后，调用start()方法就可以启动这个线程。线程start()方法的含义是：当前线程（即parent线程）同步告知Java虚拟机，只要线程规划器空闲，应立即启动调用start()方法的线程。
\# 启动一个线程前，最好为这个线程设置线程名称，因为这样在使用jstack分析程序或者进行问题排查时，就会给开发人员提供一些提示，自定义的线程最好能够起个名字。

### 4.2.3 理解中断
1. 中断可以理解为线程的一个标识位属性，它表示一个运行中的线程是否被其他线程进行了中断操作。
2. 线程通过检查自身是否被中断来进行响应，线程通过方法isInterrupted()来进行判断是否被中断，也可以调用静态方法Thread.interrupted()对当前线程的中断标识位进行复位。
3. 从Java的API中可以看到，许多声明抛出InterruptedException的方法（例如Thread.sleep(longmillis)方法）这些方法在抛出InterruptedException之前，Java虚拟机会先将该线程的中断标识位清除，然后抛出InterruptedException，此时调用isInterrupted()方法将会返回false。

### 4.2.4 过期的suspend()、resume()和stop()
这些API是过期的，也就是不建议使用的:
1. suspend() 在调用后，线程不会释放已经占有的资源（比如锁），而是占有着资源进入睡眠状态，这样容易引发死锁问题。
2. stop()方法在终结一个线程时不会保证线程的资源正常释放，通常是没有给予线程完成资源释放工作的机会，因此会导致程序可能工作在不确定状态下。

\# 正因为suspend()、resume()和stop()方法带来的副作用，这些方法才被标注为不建议使用的过期方法，而暂停和恢复操作可以用后面提到的等待/通知机制来替代。

### 4.2.5 安全地终止线程
1. 在4.2.3节中提到的中断状态是线程的一个标识位，而中断操作是一种简便的线程间交互方式，而这种交互方式最适合用来取消或停止任务。除了中断以外，还可以利用一个boolean变量来控制是否需要停止任务并终止该线程。
2. 这种通过标识位或者中断操作的方式能够使线程在终止时有机会去清理资源，而不是武断地将线程停止，因此这种终止线程的做法显得更加安全和优雅。

## 4.3 线程间通信

### 4.3.1 volatile和synchronized关键字

Java支持多个线程同时访问一个对象或者对象的成员变量，由于每个线程可以拥有这个变量的拷贝（虽然对象以及成员变量分配的内存是在共享内存中的，但是每个执行的线程还是可以拥有一份拷贝，这样做的目的是加速程序的执行，这是现代多核处理器的一个显著特性），所以程序在执行过程中，一个线程看到的变量并不一定是最新的。

>关键字volatile可以用来修饰字段（成员变量），就是告知程序任何对该变量的访问均需要从共享内存中获取，而对它的改变必须同步刷新回共享内存，它能保证所有线程对变量访问的可见性。

\# 过多地使用volatile是不必要的，因为它会降低程序执行的效率。

>关键字synchronized可以修饰方法或者以同步块的形式来进行使用，它主要确保多个线程在同一个时刻，只能有一个线程处于方法或者同步块中，它保证了线程对变量访问的可见性和排他性。


```
Eg:
public class Synchronized {
    public static void main(String[] args) {
        // 对Synchronized Class对象进行加锁
        synchronized (Synchronized.class) {
        }
        // 静态同步方法，对Synchronized Class对象进行加锁
        m();
    }
    public static synchronized void m() {
    }
}

//javap –v Synchronized.class
public static void main(java.lang.String[]);
    // 方法修饰符，表示：public staticflags: ACC_PUBLIC, ACC_STATIC
    Code:
        stack=2, locals=1, args_size=1
        0: ldc #1　　// class com/murdock/books/multithread/book/Synchronized
        2: dup
        3: monitorenter　　// monitorenter：监视器进入，获取锁
        4: monitorexit　　 // monitorexit：监视器退出，释放锁
        5: invokestatic　　#16 // Method m:()V
        8: return
    public static synchronized void m();
    // 方法修饰符，表示： public static synchronized
    flags: ACC_PUBLIC, ACC_STATIC, ACC_SYNCHRONIZED
        Code:
                stack=0, locals=0, args_size=0
                0: return

```

![Relation of Object , Monitor, SyncQueue and Thread](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ObjectMonitorSyncQueueThread.jpg?raw=true)

任意线程对Object（Object由synchronized保护）的访问，首先要获得Object的监视器。如果获取失败，线程进入同步队列，线程状态变为BLOCKED。当访问Object的前驱（获得了锁的线程）释放了锁，则该释放操作唤醒阻塞在同步队列中的线程，使其重新尝试对监视器的获取。

### 4.3.2 等待、通知机制

1）使用wait()、notify()和notifyAll()时需要先对调用对象加锁。
2）调用wait()方法后，线程状态由RUNNING变为WAITING，并将当前线程放置到对象的等待队列。
3）notify()或notifyAll()方法调用后，等待线程依旧不会从wait()返回，需要调用notify()或notifAll()的线程释放锁之后，等待线程才有机会从wait()返回。
4）notify()方法将等待队列中的一个等待线程从等待队列中移到同步队列中，而notifyAll()方法则是将等待队列中所有的线程全部移到同步队列，被移动的线程状态由WAITING变为BLOCKED。
5）从wait()方法返回的前提是获得了调用对象的锁。

### 4.3.3 等待/通知的经典范式

等待方遵循如下原则：
1）获取对象的锁。
2）如果条件不满足，那么调用对象的wait()方法，被通知后仍要检查条件。
3）条件满足则执行对应的逻辑。
```
synchronized(对象) {
    while(条件不满足) {
        对象.wait();
    }
    对应的处理逻辑
}
```

通知方遵循如下原则:
1）获得对象的锁。
2）改变条件。
3）通知所有等待在对象上的线程。

```
synchronized(对象) {
    改变条件
    对象.notifyAll();
}
```

### 4.3.4 管道输入/输出流
>管道输入/输出流和普通的文件输入/输出流或者网络输入/输出流不同之处在于，它主要用于线程之间的数据传输，而传输的媒介为内存。
>
>管道输入/输出流主要包括了如下4种具体实现：
>PipedOutputStream、PipedInputStream、
>PipedReader和PipedWriter，前两种面向字节，而后两种面向字符。


### 4.3.5 Thread.join()的使用
>如果一个线程A执行了thread.join()语句，其含义是：当前线程A等待thread线程终止之后才从thread.join()返回。线程Thread除了提供join()方法之外，还提供了join(long millis)和join(longmillis,int nanos)两个具备超时特性的方法。这两个超时方法表示，如果线程thread在给定的超时时间里没有终止，那么将会从该超时方法中返回。
>
>当线程终止时，会调用线程自身的notifyAll()方法，会通知所有等待在该线程对象上的线程。可以看到join()方法的逻辑结构与4.3.3节中描述的等待/通知经典范式一致，即加锁、循环和处理逻辑3个步骤。

### 4.3.6 ThreadLocal
1. ThreadLocal，即线程变量，是一个以ThreadLocal对象为键、任意对象为值的存储结构。这个结构被附带在线程上，也就是说一个线程可以根据一个ThreadLocal对象查询到绑定在这个线程上的一个值。
2. 可以通过set(T)方法来设置一个值，在当前线程下再通过get()方法获取到原先设置的值。


## 4.4 线程应用实例
### 4.4.1 等待超时模式

>等待超时模式就是在等待/通知范式基础上增加了超时控制，这使得该模式相比原有范式更具有灵活性，因为即使方法执行时间过长，也不会“永久”阻塞调用者，而是会按照调用者的要求“按时”返回。

### 4.4.2 一个简单的数据库连接池示例
>我们使用等待超时模式来构造一个简单的数据库连接池，在示例中模拟从连接池中获取、使用和释放连接的过程，而客户端获取连接的过程被设定为等待超时的模式，也就是在1000毫秒内如果无法获取到可用连接，将会返回给客户端一个null。
>
>数据库连接池的设计也可以复用到其他的资源获取的场景，针对昂贵资源（比如数据库连接）的获取都应该加以超时限制。

### 4.4.3 线程池技术及其示例

>对于服务端的程序，经常面对的是客户端传入的短小（执行时间短、工作内容较为单一）任务，需要服务端快速处理并返回结果。如果服务端每次接受到一个任务，创建一个线程，然后进行执行，这在原型阶段是个不错的选择，但是面对成千上万的任务递交进服务器时，如果还是采用一个任务一个线程的方式，那么将会创建数以万记的线程，这不是一个好的选择。因为这会使操作系统频繁的进行线程上下文切换，无故增加系统的负载，而线程的创建和消亡都是需要耗费系统资源的，也无疑浪费了系统资源。
>
>线程池技术能够很好地解决这个问题，它预先创建了若干数量的线程，并且不能由用户直接对线程的创建进行控制，在这个前提下重复使用固定或较为固定数目的线程来完成任务的执行。这样做的好处是，一方面，消除了频繁创建和消亡线程的系统资源开销，另一方面，面对过量任务的提交能够平缓的劣化。


```
// An Example
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.LinkedList;

public class ThreadPool<Job extends Runnable>{
    List<Worker> workers = Collections.synchronizedList(new ArrayList<Worker>());
    List<Job> jobs = new LinkedList<Job>();

    public void execute(Job job){
        if (job != null) {
            synchronized (jobs) {
                jobs.add(0,job);
                jobs.notify();
            }
        }
    }

    public void initializeWorker(int number){
        for(int i=0;i<number;i++){
            Worker worker =new Worker();
            workers.add(worker);
            Thread thread = new Thread(worker);
            thread.start();
        }
    }

    class Worker implements Runnable{
        private volatile boolean running = true; 
        @Override
        public void run(){
            while(running){
                Job job = null;
                synchronized(jobs){
                    while(jobs.isEmpty()){
                        try{
                            jobs.wait();
                        } catch(InterruptedException ie){
                            Thread.currentThread().interrupt();
                            return;
                        }
                    }
                    job = jobs.remove(jobs.size()-1);
                }
                if(job != null){
                    try{
                        job.run();
                    } catch(Exception ex){
    
                    }
                }
            }
        }
        public void shutdown(){
            running = false;
        }
    
    }


    public static void main(String args[]){
        ThreadPool tp = new ThreadPool<>();
        tp.initializeWorker(5);
        for(int i=0;i<10000;i++){
            tp.execute(new Runnable(){
                @Override
                public void run(){
                    try{
                        Thread.sleep(1000);
                        System.out.println(Thread.currentThread().getId() + ":" + Thread.currentThread().getName());
                    } catch(Exception e){

                    }
                }

            });
        }
    }
}
interface Job extends Runnable{

}

```

### 4.4.4 一个基于线程池技术的简单Web服务器
>原理基本同上节
>
>线程池中线程数量并不是越多越好，具体的数量需要评估每个任务的处理时间，以及当前计算机的处理器能力和数量。使用的线程过少，无法发挥处理器的性能；使用的线程过多，将会增加系统的无故开销，起到相反的作用。

## 4.5 本章小结
1. 多线程之间进行通信的基本方式和等待/通知经典范式
2. 等待超时、数据库连接池以及简单线程池

# 5 Java中的锁
>本章将介绍Java并发包中与锁相关的API和组件，以及这些API和组件的使用方式和实现细节。内容主要围绕两个方面：使用，通过示例演示这些组件的使用方法以及详细介绍与锁相关的API；实现，通过分析源码来剖析实现细节，因为理解实现的细节方能更加得心应手且正确地使用这些组件。

## 5.1 Lock 接口
>Java SE 5之后，并发包中新增了Lock接口（以及相关实现类）用来实现锁功能，它提供了与synchronized关键字类似的同步功能，只是在使用时需要显式地获取和释放锁。虽然它缺少了（通过synchronized块或者方法所提供的）隐式获取释放锁的便捷性，但是却拥有了锁获取与释放的可操作性、可中断的获取锁以及超时获取锁等多种synchronized关键字所不具备的同步特性。

```
//LockUseCase.java
Lock lock  = new ReentrantLock();
try{
} finally{
    lock.unlock();
}
```
\# 在finally块中释放锁，目的是保证在获取到锁之后，最终能够被释放
\# 不要将获取锁的过程写在try块中，因为如果在获取锁（自定义锁的实现）时发生了异常，异常抛出的同时，也会导致锁无故释放。

Lock接口提供的synchronized关键字所不具备的主要特性:
|特性|描述|
|---|----|
|尝试非阻塞地获取锁|当前线程尝试获取锁，如果这一时刻锁没有被其他线程获取到，则成功获取并持有锁|
|能被中断地获取锁|与synchronied不同，获取到锁的线程能够响应中断，当获取到锁的线程被中断时，中断异常会被抛出，同时释放锁|
|超时获取锁|在指定的截止时间之前获取锁，若果截止时间到了仍旧无法获取锁，则返回|

Lock是一个接口，它定义了锁获取和释放的基本操作，Lock的API如下：
|方法名称|描述|
|-------|----|
|void lock()|阻塞的获取锁|
|void lockInterruptibly() throws InterruptedException|可中断地获取锁，和lock()方法的不同之处在于该方法会响应中断，即在锁的获取中可以中断当前线程|
|boolean tryLock()|尝试非阻塞的获取锁，调用该方法后立刻返回，如果能够获取则返回true，否则返回false|
|boolean tryLock(long time,TimeUnit unit) throws InterruptedException|超时的获取锁，当前线程在一下3种情况下会返回：<br>1. 当前线程在超时时间内获得了锁<br>2. 当前线程在超时时间内被中断<br>3. 超时时间结束，返回false|
|void unlock()|释放锁|
|Condition newCondition()|获取等待通知组件，该组件和当前的锁绑定，当前线程只有获得了锁，才能调用该组件的wait()方法，而调用后，当前线程将释放|

>这里先简单介绍一下Lock接口的API，随后的章节会详细介绍同步器AbstractQueuedSynchronizer以及常用Lock接口的实现ReentrantLock。

## 5.2 队列同步器

>队列同步器AbstractQueuedSynchronizer（以下简称同步器），是用来构建锁或者其他同步组件的基础框架，它使用了一个int成员变量表示同步状态，通过内置的FIFO队列来完成资源获取线程的排队工作，并发包的作者（Doug Lea）期望它能够成为实现大部分同步需求的基础。
>
>同步器的主要使用方式是继承，子类通过继承同步器并实现它的抽象方法来管理同步状态，在抽象方法的实现过程中免不了要对同步状态进行更改，这时就需要使用同步器提供的3个方法（getState()、setState(int newState)和compareAndSetState(int expect,int update)）来进行操作，因为它们能够保证状态的改变是安全的。
>
>子类推荐被定义为自定义同步组件的静态内部类，同步器自身没有实现任何同步接口，它仅仅是定义了若干同步状态获取和释放的方法来供自定义同步组件使用，同步器既可以支持独占式地获取同步状态，也可以支持共享式地获取同步状态，这样就可以方便实现不同类型的同步组件（ReentrantLock、ReentrantReadWriteLock和CountDownLatch等）。
>
>同步器是实现锁（也可以是任意同步组件）的关键，在锁的实现中聚合同步器，利用同步器实现锁的语义。可以这样理解二者之间的关系：锁是面向使用者的，它定义了使用者与锁交互的接口（比如可以允许两个线程并行访问），隐藏了实现细节；同步器面向的是锁的实现者，它简化了锁的实现方式，屏蔽了同步状态管理、线程的排队、等待与唤醒等底层操作。锁和同步器很好地隔离了使用者和实现者所需关注的领域。


### 5.2.1 队列同步器的接口与示例
重写同步器指定的方法时，需要使用同步器提供的如下3个方法来访问或修改同步状态：
1. ·getState()：获取当前同步状态。
2. ·setState(int newState)：设置当前同步状态。
3. ·compareAndSetState(int expect,int update)：使用CAS设置当前状态，该方法能够保证状态设置的原子性。

同步器可重写的方法与描述：
|方法名称|描述|
|-------|----|
|protected boolean tryAcquire(int arg)|独占式获取同步状态，实现该方法需要查询当前状态并判断同步状态是否符合预期，然后再进行CAS设置同步状态|
|protected boolean tryRelease(int arg)|独占式释放同步状态，等待获取同步状态的线程将有机会获取同步状态|
|protected int tryAcquireShared(int arg)|共享式获取同步状态，返回大于等于0的值，表示获取成功，反之，获取失败|
|protected boolean tryReleaseShared(int arg)|共享式释放同步状态|
|protected boolean isHeldExclusively()|当前同步器是否在独占模式下被线程占用，一般该方法表示是否被单签线程所独占|

![Synchronizer Template Method](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/SynchronizerTemplateMethod.JPG?raw=true)

只有掌握了同步器的工作原理才能更加深入地理解并发包中其他的并发组件，所以下面通过一个独占锁的示例来深入了解一下同步器的工作原理:

```
同步器提供的模板方法基本上分为3类：
1. 独占式获取与释放同步状态
2. 共享式获取与释放同步状态
3. 查询同步队列中的等待线程情况。
\# 自定义同步组件将使用同步器提供的模板方法来实现自己的同步语义。

\# 只有掌握了同步器的工作原理才能更加深入地理解并发包中其他的并发组件，所以下面通过一个独占锁的示例来深入了解一下同步器的工作原理。

//Mutex.java
class Mutex implements Lock {
    // 静态内部类，自定义同步器
    private static class Sync extends AbstractQueuedSynchronizer {
        // 是否处于占用状态
        protected boolean isHeldExclusively() {
            return getState() == 1;
        }
        // 当状态为0的时候获取锁
        public boolean tryAcquire(int acquires) {
            if (compareAndSetState(0, 1)) {
                setExclusiveOwnerThread(Thread.currentThread());
                return true;
            }
            return false;
        }
        // 释放锁，将状态设置为0
        protected boolean tryRelease(int releases) {
            if (getState() == 0) throw new IllegalMonitorStateException();
            setExclusiveOwnerThread(null);
            setState(0);
            return true;
        }
        // 返回一个Condition，每个condition都包含了一个condition队列
        Condition newCondition() { 
            return new ConditionObject(); 
        }
    }
    // 仅需要将操作代理到Sync上即可
    private final Sync sync = new Sync();
    public void lock() { sync.acquire(1); }
    public boolean tryLock() { return sync.tryAcquire(1); }
    public void unlock() { sync.release(1); }
    public Condition newCondition() { return sync.newCondition(); }
    public boolean isLocked() { return sync.isHeldExclusively(); }
    public boolean hasQueuedThreads() { return sync.hasQueuedThreads(); }
    public void lockInterruptibly() throws InterruptedException {
        sync.acquireInterruptibly(1);
    }
    public boolean tryLock(long timeout, TimeUnit unit) throws InterruptedException {
        return sync.tryAcquireNanos(1, unit.toNanos(timeout));
    }
}
```

### 5.2.2 队列同步器的实现分析
>接下来将从实现角度分析同步器是如何完成线程同步的，主要包括同步器的核心数据结构与模板方法：
1. 同步队列
2. 独占式同步状态获取与释放
3. 共享式同步状态获取与释放
4. 超时获取同步状态

#### 5.2.2.1 同步队列
>同步器依赖内部的同步队列（一个FIFO双向队列）来完成同步状态的管理，当前线程获取同步状态失败时，同步器会将当前线程以及等待状态等信息构造成为一个节点（Node）并将其加入同步队列，同时会阻塞当前线程，当同步状态释放时，会把首节点中的线程唤醒，使其再次尝试获取同步状态。
同步队列节点的属性类型、名称以及描述：

|属性类型与名称|描述|
|------------|----|
|int waitStatus|等待状态。<br> 包含如下状态：<br> 1. CANCELLED，值为1，由于在队列中等待的先层等待超时或者被中断，需要从同步队列中取消等待，节点进入该状态将不会变化<br>2. SIGNAL,值为-1，后继节点的线程处于等待状态，而当前节点的线程如果释放了同步状态或者被取消，将会通知后继节点，使后继节点的线程得以运行<br>3. CONDITION,值为-2，节点在等待队列中，节点线程等待在Condition上，当其他线程对Condition调用了signal()方法后，该节点将会从等待队列中转移到同步队列中，加入到对同步状态的获取之中<br>4. PROPAGATE，值为-3，表示下一次共享式同步状态将会无条件地被传播下去<br>5. INITIAL，值为0，初始状态|
|Node prev|前驱节点，当节点加入同步队列时被设置（尾部添加）|
|Node next|后继结点|
|Node nextWaiter|等待队列中的后继结点。如果当前节点是共享的，那么这个字段将是一个SHARED常量，也就是说节点类型（独占和共享）和等待队列中的后继结点共用同一个字段|
|Thread thread|获取同步状态的线程|

![Node Propertity Type And Name & Description](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/NodePropertityTypeAndName&Description.JPG?raw=true)

![Basic Struct Of Sync Queue](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/BasicStructOfSyncQueue.JPG?raw=true)

#### 5.2.2.2 独占式同步状态获取与释放

```
public final void acquire(int arg) {
    if (!tryAcquire(arg) && acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}
```

![Get Sync Status Process](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/GetSyncStatusProcess.JPG?raw=true)

\# 在获取同步状态时，同步器维护一个同步队列，获取状态失败的线程都会被加入到队列中并在队列中进行自旋；移出队列（或停止自旋）的条件是前驱节点为头节点且成功获取了同步状态。在释放同步状态时，同步器调用tryRelease(int arg)方法释放同步状态，然后唤醒头节点的后继节点。

#### 5.2.2.3 共享式同步状态获取与释放
![Camparing Between Shared And Occupied](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/CamparingBetweenSharedAndOccupied.JPG?raw=true)

\# 它和独占式主要区别在于tryReleaseShared(int arg)方法必须确保同步状态（或者资源数）线程安全释放，一般是通过循环和CAS来保证的，因为释放同步状态的操作会同时来自多个线程。

#### 5.2.2.4 独占式超时获取同步状态
>通过调用同步器的doAcquireNanos(int arg,long nanosTimeout)方法可以超时获取同步状态，即在指定的时间段内获取同步状态，如果获取到同步状态则返回true，否则，返回false。该方法提供了传统Java同步操作（比如synchronized关键字）所不具备的特性。

\#如果nanosTimeout小于等于spinForTimeoutThreshold（1000纳秒）时，将不会使该线程进行超时等待，而是进入快速的自旋过程。原因在于，非常短的超时等待无法做到十分精确，如果这时再进行超时等待，相反会让nanosTimeout的超时从整体上表现得反而不精确。因此，在超时非常短的场景下，同步器会进入无条件的快速自旋。

![Timeout Acquire Sync Process](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/TimeoutAcquireSyncProcess.JPG?raw=true)

#### 5.2.2.5 自定义同步组件^^^^^^TwinsLock
本小节设计一个自定义同步组建来加深对同步器的理解

1. 首先，确定访问模式。TwinsLock能够在同一时刻支持多个线程的访问，这显然是共享式访问：
    需要使用同步器提供的acquireShared(int args)方法等和Shared相关的方法，这就要求TwinsLock必须重写tryAcquireShared(int args)方法和tryReleaseShared(int args)方法，这样才能保证同步器的共享式同步状态的获取与释放方法得以执行。
2. 其次，定义资源数。TwinsLock在同一时刻允许至多两个线程的同时访问，表明同步资源
数为2：
    这样可以设置初始状态status为2，当一个线程进行获取，status减1，该线程释放，则status加1，状态的合法范围为0、1和2，其中0表示当前已经有两个线程获取了同步资源，此时再有其他线程对同步状态进行获取，该线程只能被阻塞。在同步状态变更时，需要使用compareAndSet(int expect,int update)方法做原子性保障。
3. 最后，组合自定义同步器。前面的章节提到，自定义同步组件通过组合自定义同步器来完

```
//TwinsLock.java
public class TwinsLock implements Lock {
    private final Sync sync = new Sync(2);
    private static final class Sync extends AbstractQueuedSynchronizer {
        Sync(int count) {
            if (count <= 0) {
                throw new IllegalArgumentException("count must largethan zero.");
            }
            setState(count);
        }
        public int tryAcquireShared(int reduceCount) {
            for (;;) {
                int current = getState();
                int newCount = current - reduceCount;
                if (newCount < 0 || compareAndSetState(current,newCount)) {
                    return newCount;
                }
            }
        }
        public boolean tryReleaseShared(int returnCount) {
            for (;;) {
                int current = getState();
                int newCount = current + returnCount;
                if (compareAndSetState(current, newCount)) {
                    return true;
                }
            }
        }
    }
    public void lock() {
        sync.acquireShared(1);
    }
    public void unlock() {
        sync.releaseShared(1);
    }
    // 其他接口方法略
}

//TwinsLockTest.java
public class TwinsLockTest {
    @Test
    public void test() {
        final Lock lock = new TwinsLock();
        class Worker extends Thread {
            public void run() {
                while (true) {
                    lock.lock();
                    try {
                        SleepUtils.second(1);
                        System.out.println(Thread.currentThread().getName());
                        SleepUtils.second(1);
                    } finally {
                        lock.unlock();
                    }
                }
            }
        }
        // 启动10个线程
        for (int i = 0; i < 10; i++) {
            Worker w = new Worker();
            w.setDaemon(true);
            w.start();
        }
        // 每隔1秒换行
        for (int i = 0; i < 10; i++) {
            SleepUtils.second(1);
            System.out.println();
        }
    }
}
```

## 5.3 重入锁
>重入锁ReentrantLock，顾名思义，就是支持重进入的锁，它表示该锁能够支持一个线程对资源的重复加锁。除此之外，该锁的还支持获取锁时的公平和非公平性选择。
>
>如果在绝对时间上，先对锁进行获取的请求一定先被满足，那么这个锁是公平的，反之，是不公平的。
>
>ReentrantLock提供了一个构造函数，能够控制锁是否是公平的。
>
>下面将着重分析ReentrantLock是如何实现重进入和公平性获取锁的特性，并通过测试来验证公平性获取锁对性能的影响。

### 5.3.1 实现重进入
该特性的实现需要解决以下两个问题：
1. 线程再次获取锁。锁需要去识别获取锁的线程是否为当前占据锁的线程，如果是，则再次成功获取。
2. 锁的最终释放。线程重复n次获取了锁，随后在第n次释放该锁后，其他线程能够获取到该锁。
```
//
final boolean nonfairTryAcquire(int acquires) {
    final Thread current = Thread.currentThread();
    int c = getState();
    if (c == 0) {
        if (compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    } else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0)
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    return false;
}

//tryReleas
protected final boolean tryRelease(int releases) {
    int c = getState() - releases;
    if (Thread.currentThread() != getExclusiveOwnerThread())
        throw new IllegalMonitorStateException();
    boolean free = false;
    if (c == 0) {
        free = true;
        setExclusiveOwnerThread(null);
    }
    setState(c);
    return free;
}
```

### 5.3.2 公平与非公平获取的区别
>公平性与否是针对获取锁而言的，如果一个锁是公平的，那么锁的获取顺序就应该符合请求的绝对时间顺序，也就是FIFO。

```
protected final boolean tryAcquire(int acquires) {
    final Thread current = Thread.currentThread();
    int c = getState();
    if (c == 0) {
        if (!hasQueuedPredecessors() && compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    } else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0)
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    return false;
}
```

>公平锁与非公平锁的区别：
>>公平锁在获取锁的时候会判断队列中的节点是否有前驱节点，有前驱节点，则继续等待前驱节点获取并释放锁之后才能继续获取锁。
>
>公平性锁保证了锁的获取按照FIFO原则，而代价是进行大量的线程切换。非公平性锁虽然可能造成线程“饥饿”，但极少的线程切换，保证了其更大的吞吐量。

## 5.4 读写锁
>Mutex和ReentrantLock基本都是排他锁
>
>读写锁维护了一对锁，一个读锁和一个写锁，通过分离读锁和写锁，使得并发性相比一般的排他锁有了很大提升
>
>一般情况下，读写锁的性能都会比排它锁好，因为大多数场景读是多于写的。在读多于写的情况下，读写锁能够提供比排它锁更好的并发性和吞吐量。Java并发包提供读写锁的实现是ReentrantReadWriteLock，它提供的特性如下：
|特性|说明|
|----|---|
|公平性选择|支持非公平（默认）和公平的锁获取方式，吞吐量还是非公平优于公平|
|重进入|该锁支持重进入，以读写线程为例：读线程在获取了读锁之后，能再次获取读锁。而写线程在获取了写锁之后能再次获取写锁，同时也可以获取读锁|
|锁降级|遵循获取写锁，获取读锁再释放写锁的次序，写锁能够降级称为读锁|

### 5.4.1 读写锁的接口与示例

ReadWriteLock仅定义了获取读锁和写锁的两个方法，即readLock()方法和writeLock()方法，而其实现——ReentrantReadWriteLock，除了接口方法之外，还提供了一些便于外界监控其内部工作状态的方法：
|方法名称|描述|
|-------|----|
|int getReadLockCount()|返回当前读锁被获取的次数。该次数不等于获取锁的线程数，例如，仅一个线程，它连续获取（重进入）了n次读锁，那么占据读锁的线程数是1，但该方法返回n|
|int getReadHoldCount()|返回当前线程获取读锁的次数。该方法在Java 6中加入到ReentrantReadWriteLock中，使用ThreadLocal保存当前线程获取的次数，这也使得Java 6的实现变得更加复杂|
|boolean isWriteLocked()|判断写锁是否被获取|
|int get WriteHoldCount()|返回当前写锁被获取的次数|

一个缓存示例说明读写锁的使用方式：
```
public class Cache {
    static Map<String, Object> map = new HashMap<String, Object>();
    static ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();
    static Lock r = rwl.readLock();
    static Lock w = rwl.writeLock();

    // 获取一个key对应的value
    public static final Object get(String key) {
        r.lock();
        try {
            return map.get(key);
        } finally {
            r.unlock();
        }
    }

    // 设置key对应的value，并返回旧的value
    public static final Object put(String key, Object value) {
        w.lock();
        try {
            return map.put(key, value);
        } finally {
            w.unlock();
        }
    }

    // 清空所有的内容
    public static final void clear() {
        w.lock();
        try {
            map.clear();
        } finally {
            w.unlock();
        }
    }
}
```

### 5.4.2 读写锁的实现分析
>分析ReentrantReadWriteLock的实现（以下没有特别说明读写锁均可认为是ReentrantReadWriteLock），主要包括：
1. 读写状态的设计
2. 写锁的获取与释放
3. 读锁的获取与释放以及锁降级

#### 5.4.2.1 读写状态的设计
>如果在一个整型变量上维护多种状态，就一定需要“按位切割使用”这个变量，读写锁将变量切分成了两个部分，高16位表示读，低16位表示写
>
>通过位运算。假设当前同步状态值为S，写状态等于S&0x0000FFFF（将高16位全部抹去），读状态等于S>>>16（无符号补0右移16位）。当写状态增加1时，等于S+1，当读状态增加1时，等于S+(1<<16)，也就是S+0x00010000

#### 5.4.2.2 写锁的获取与释放
```
//ReentrantReadWriteLock的tryAcquire方法
protected final boolean tryAcquire(int acquires) {
    Thread current = Thread.currentThread();
    int c = getState();
    int w = exclusiveCount(c);
    if (c != 0) {
        // 存在读锁或者当前获取线程不是已经获取写锁的线程
        if (w == 0 || current != getExclusiveOwnerThread())
            return false;
        if (w + exclusiveCount(acquires) > MAX_COUNT)
            throw new Error("Maximum lock count exceeded");
        setState(c + acquires);
        return true;
    }
    if (writerShouldBlock() || !compareAndSetState(c, c + acquires)) {
        return false;
    }
    setExclusiveOwnerThread(current);
    return true;
}
```
>如果存在读锁，则写锁不能被获取，原因在于：读写锁要确保写锁的操作对读锁可见，如果允许读锁在已被获取的情况下对写锁的获取，那么正在运行的其他读线程就无法感知到当前写线程的操作。因此，只有等待其他读线程都释放了读锁，写锁才能被当前线程获取，而写锁一旦被获取，则其他读写线程的后续访问均被阻塞。

#### 5.4.2.3 读锁的获取与释放
```
protected final int tryAcquireShared(int unused) {
    for (;;) {
        int c = getState();
        int nextc = c + (1 << 16);
        if (nextc < c)
            throw new Error("Maximum lock count exceeded");
        if (exclusiveCount(c) != 0 && owner != Thread.currentThread())
            return -1;
        if (compareAndSetState(c, nextc))
            return 1;
    }
}
```


#### 5.4.2.4 锁降级
>锁降级指的是写锁降级成为读锁。如果当前线程拥有写锁，然后将其释放，最后再获取读锁，这种分段完成的过程不能称之为锁降级。锁降级是指把持住（当前拥有的）写锁，再获取到读锁，随后释放（先前拥有的）写锁的过程。

```
public void processData() {
    readLock.lock();
    if (!update) {
        readLock.unlock();
        writeLock.lock();
        try {
            if (!update) {
                update = true;
            }
            readLock.lock();
        } finally {
            writeLock.unlock();
        }
    }
    try {
    } finally {
        readLock.unlock();
    }
}
```
>锁降级中读锁的获取是否必要呢？答案是必要的。主要是为了保证数据的可见性
>RentrantReadWriteLock不支持锁升级（把持读锁、获取写锁，最后释放读锁的过程）。目的也是保证数据可见性，如果读锁已被多个线程获取，其中任意线程成功获取了写锁并更新了数据，则其更新对其他获取到读锁的线程是不可见的。

## 5.5 LockSupport工具
>LockSupport定义了一组的公共静态方法，这些方法提供了最基本的线程阻塞和唤醒功能，而LockSupport也成为构建同步组件的基础工具。

LockSupport提供的阻塞和唤醒方法
|方法名称|描述|
|-------|----|
|void park()|阻塞当前线程，如果调用unpark(Thread thread)方法或者当前线程被中断，才能从park()方法返回|
|void parkNanos(long nanos)|阻塞当前线程，最长不超过nanos纳秒，返回条件在park()的基础上增加了超时返回|
|void parkUntil(long deadkine)|阻塞当前线程，知道deadline时间（从1970年开始到deadline时间的毫秒数）|
|void unpark()|唤醒处于阻塞状态的线程|

>在Java 6中，LockSupport增加了park(Object blocker)、parkNanos(Object blocker,long nanos)和parkUntil(Object blocker,long deadline)3个方法，用于实现阻塞当前线程的功能，其中参数blocker是用来标识当前线程在等待的对象（以下称为阻塞对象），该对象主要用于问题排查和系统监控。

## 5.6 Condition 接口
>Condition接口也提供了类似Object的监视器方法，与Lock配合可以实现等待/通知模式，但是这两者在使用方式以及功能特性上还是有差别的。

Object 的监视器方法与Condition接口的对比
|对比项|Object Monitor Methods|Condition|
|-----|----------------------|---------|
|前置条件|获取对象的锁|调用Lock.lock()获取锁<br/>调用Lock.newCondition()获取Condition对象|
|调用条件|直接调用<br/>如：object.wait()|直接调用<br/>如：condition.await()|
|等待队列个数|一个|多个|
|当前线程释放锁并进入等待状态|支持|支持|
|当前线程释放锁并进入等待状态，在等待状态中不响应中断|不支持|支持|
|当前线程释放锁并进入超时等待状态|支持|支持|
|当前线程释放锁并进入等待状态到将来的某个时间|不支持|支持|
|唤醒等待队列中的一个线程|支持|支持|
|唤醒等待队列中的全部线程|支持|支持|

### 5.6.1 Condition接口与示例
>Condition定义了等待/通知两种类型的方法，当前线程调用这些方法时，需要提前获取到Condition对象关联的锁。Condition对象是由Lock对象（调用Lock对象的newCondition()方法）创建出来的，换句话说，Condition是依赖Lock对象的。

```
Lock lock = new ReentrantLock();
Condition condition = lock.newCondition();

public void conditionWait() throws InterruptedException {
    lock.lock();
    try {
        condition.await();
    } finally {
        lock.unlock();
    }
}

public void conditionSignal() throws InterruptedException {
    lock.lock();
    try {
        condition.signal();
    } finally {
        lock.unlock();
    }
}
```

### 5.6.2 Condition的实现分析
>ConditionObject是同步器AbstractQueuedSynchronizer的内部类，因为Condition的操作需要获取相关联的锁，所以作为同步器的内部类也较为合理。每个Condition对象都包含着一个队列（以下称为等待队列），该队列是Condition对象实现等待/通知功能的关键。
>
>下面将分析Condition的实现，主要包括：等待队列、等待和通知，下面提到的Condition如果不加说明均指的是ConditionObject。

#### 5.6.2.1 等待队列
>等待队列是一个FIFO的队列，在队列中的每个节点都包含了一个线程引用，该线程就是在Condition对象上等待的线程，如果一个线程调用了Condition.await()方法，那么该线程将会释放锁、构造成节点加入等待队列并进入等待状态。事实上，节点的定义复用了同步器中节点的定义，也就是说，同步队列和等待队列中节点类型都是同步器的静态内部类AbstractQueuedSynchronizer.Node。
>
>等待队列节点引用更新的过程并没有使用CAS保证，原因在于调用await()方法的线程必定是获取了锁的线程，也就是说该过程是由锁来保证线程安全的。

#### 5.6.2.2 等待
>同步队列的首节点并不会直接加入等待队列，而是通过addConditionWaiter()方法把当前线程构造成一个新的节点并将其加入等待队列中。
![Sync Queue And Wait Queue](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/SyncQueueAndWaitQueue.JPG?raw=true)

#### 5.6.2.3 通知
>调用Condition的signal()方法，将会唤醒在等待队列中等待时间最长的节点（首节点），在唤醒节点之前，会将节点移到同步队列中。
>
>通过调用同步器的enq(Node node)方法，等待队列中的头节点线程安全地移动到同步队列。当节点移动到同步队列后，当前线程再使用LockSupport唤醒该节点的线程。
>
>被唤醒后的线程，将从await()方法中的while循环中退出（isOnSyncQueue(Node node)方法返回true，节点已经在同步队列中），进而调用同步器的acquireQueued()方法加入到获取同步状态的竞争中。

## 5.7 本章小结
>本章介绍了Java并发包中与锁相关的API和组件，通过示例讲述了这些API和组件的使用方式以及需要注意的地方，并在此基础上详细地剖析了队列同步器、重入锁、读写锁以及Condition等API和组件的实现细节，

# 6 Java并发容器和框架
>并发编程大师Doug Lea 为Java开发者提供了非常多的并发容器和框架。

## 6.1 ConcurrentHashMap的实现原理与使用
>ConcurrentHashMap是线程安全且高效的HashMap,在保证线程安全的同时又能保证高效的操作。

### 6.1.1 为什么要使用用ConcurrentHashMap
1. 并发编程中使用HashMap可能导致程序死循环。
2. 使用线程安全的HashTable效率有非常低下
3. ConcurrenHashMap的锁分段技术可有效提升并发访问率

### 6.1.2 ConcurrentHashMap的结构
>ConcurrentHashMap是由Segment数组结构和HashEntry数组结构组成。
![ConcurrentHashMap Class Map](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ConcurrentHashMapClassMap.JPG?raw=true)

### 6.1.3 ConcurrentHashMap的初始化
>ConcurrentHashMap初始化方法是通过initialCapacity、loadFactor和concurrencyLevel等几个参数来初始化segment数组、段偏移量segmentShift、段掩码segmentMask和每个segment里的HashEntry数组来实现的。

#### 6.1.3.1 初始化segments数组
```
//MAX_SEGMENTS default 16
//concurrencyLevel的最大值是65535
if (concurrencyLevel > MAX_SEGMENTS)
    concurrencyLevel = MAX_SEGMENTS;
int sshift = 0;
int ssize = 1;
while (ssize < concurrencyLevel) {
    ++sshift;
    ssize <<= 1;
}
segmentShift = 32 - sshift;
segmentMask = ssize - 1;
this.segments = Segment.newArray(ssize);
```

#### 6.1.3.2 初始化segmentShift和segmentMask
>这两个全局变量需要在定位segment时的散列算法里使用:
>
>segmentShift等于32减sshift，所以等于28
>
>segmentMask是散列运算的掩码，等于ssize减1，即15

#### 6.1.3.3 初始化segment
>默认情况下initialCapacity等于16，loadfactor等于0.75，通过运算cap等于1，threshold等于零。
```
if (initialCapacity > MAXIMUM_CAPACITY)
    initialCapacity = MAXIMUM_CAPACITY;
int c = initialCapacity / ssize;
if (c * ssize < initialCapacity)
    ++c;
int cap = 1;
while (cap < c)
    cap <<= 1;
for (int i = 0; i < this.segments.length; ++i)
    this.segments[i] = new Segment<K,V>(cap, loadFactor);
```

### 6.1.4 定位Segment
```
//到ConcurrentHashMap会首先使用Wang/Jenkins hash的变种算法对元素的hashCode进行一次再散列：
private static int hash(int h) {
    h += (h << 15) ^ 0xffffcd7d;
    h ^= (h >>> 10);
    h += (h << 3);
    h ^= (h >>> 6);
    h += (h << 2) + (h << 14);
    return h ^ (h >>> 16);
}
//ConcurrentHashMap通过以下散列算法定位segment：
final Segment<K,V> segmentFor(int hash) {
    return segments[(hash >>> segmentShift) & segmentMask];
}
```

\# 默认情况下segmentShift为28，segmentMask为15，再散列后的数最大是32位二进制数据，向右无符号移动28位，意思是让高4位参与到散列运算中，（hash>>>segmentShift）&segmentMask的运算结果分别是4、15、7和8，可以看到散列值没有发生冲突。

### 6.1.5 ConcurrentHashMap的操作
1. get
2. put
3. size

#### 6.1.5.1 get操作
>Segment的get操作实现非常简单和高效。先经过一次再散列，然后使用这个散列值通过散列运算定位到Segment，再通过散列算法定位到元素，代码如下:
```
public V get(Object key){
    int hash = hash(key.hashCode());
    return segmentFor(hash).get(key,hash);
}
transient volatile int count;
volatile V value;
```
>get操作的高效之处在于整个get过程不需要加锁，除非读到的值是空才会加锁重读。
>
>共享变量全部被定义成volatile
>
>定位HashEntry和定位Segment的散列算法虽然一样，都与数组的长度减去1再相“与”，但是相“与”的值不一样，定位Segment使用的是元素的hashcode通过再散列后得到的值的高位，而定位HashEntry直接使用的是再散列后的值。其目的是避免两次散列后的值一样，虽然元素在Segment里散列开了，但是却没有在HashEntry里散列开。

#### 6.1.5.2 put操作
>由于put方法里需要对共享变量进行写入操作，所以为了线程安全，在操作共享变量时必须加锁。put方法首先定位到Segment，然后在Segment里进行插入操作。插入操作需要经历两个步骤，第一步判断是否需要对Segment里的HashEntry数组进行扩容，第二步定位添加元素的位置，然后将其放在HashEntry数组里。

##### 6.1.5.2.1 是否需要扩容
>在插入元素前会先判断Segment里的HashEntry数组是否超过容量（threshold），如果超过阈值，则对数组进行扩容。
>
>HashMap:先插入数据再进行扩容
>
>Segment:先判断HashEntry数组是否超过阈值，超过则进行扩容

##### 6.1.5.2.2 如何扩容
>ConcurrentHashMap不会对整个容器进行扩容，而只对某个segment进行扩容。

#### 6.1.5.3 size操作
>先尝试2次不锁住segment的方式来获取counnt，如果容器的count发生了变化，则再采用加锁的方式来统计所有的segment大小
>
>使用modCount变量，每次put、remove、clean 方法都会讲modCount加1，在size()前后比较modCount是否发生变化，

## 6.2 ConcurrentLinkedQueue
>如果要实现一个线程安全的队列有两种方式：
>
>一种是使用阻塞算法
>
>另一种是使用非阻塞算法。
>
>使用阻塞算法的队列可以用一个锁（入队和出队用同一把锁）或两个锁（入队和出队用不同的锁）。

### 6.2.1 ConcurrentLinkedQueue的结构
![ConcurrentLinkedQueue](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ConcurrentLinkedQueue.jpg?raw=true)

1. head节点存储的值为空
2. 默认tail=head
3. 单链表结构（非数组实现）

### 6.2.2 入队列
#### 6.2.2.1 入队列的过程
>入队列就是将入队节点添加到队列的尾部。

区别于非线程安全的LinkedQueue
1. tail节点并非一定指向尾节点
2. 添加尾节点使用CAS算法，确保节点正确添加
3. 使用int HOPS=1（默认值为 1），tail与尾节点的距离大于等于2时才将tail设置为尾节点，好处是避免频繁修改tail，提高性能

#### 6.2.2.2 定位尾节点

#### 6.2.2.3 设置入队节点为尾节点

#### 6.2.2.4 HOPS的设计意图
```
//Simple Sample
/**
  * 可行，但是入队效率低，原因是频繁写tail
  * 使用辅助变量int HOPS=1, 使得对volatile变量的写次数减少，提高了入队效率
  */
public boolean offer(E e) {
    if (e == null)
        throw new NullPointerException();
    Node<E> n = new Node<E>(e);
    for (;;) {
        Node<E> t = tail;
        if (t.casNext(null, n) && casTail(t, n)) {
            return true;
        }
    }
}
```

\# 入队方法永远返回true，所以不要通过返回值判断入队是否成功。

### 6.2.3 出队列
1. 当head节点里有元素时，直接弹出head节点里的元素，而不会更新head节点。
2. 当head节点里没有元素时，出队操作才会更新head节点
3. 这种做法也是通过hops变量来减少使用CAS更新head节点的消耗，从而提高出队效率。

```
public E poll() {
    Node<E> h = head;
    // p表示头节点，需要出队的节点
    Node<E> p = h;
    for (int hops = 0;; hops++) {
        // 获取p节点的元素
        E item = p.getItem();
        // 如果p节点的元素不为空，使用CAS设置p节点引用的元素为null,
        // 如果成功则返回p节点的元素。
        if (item != null && p.casItem(item, null)) {
            if (hops >= HOPS) {
                // 将p节点下一个节点设置成head节点
                Node<E> q = p.getNext();
                updateHead(h, (q != null) q : p);
            }
            return item;
        }
        // 如果头节点的元素为空或头节点发生了变化，这说明头节点已经被另外
        // 一个线程修改了。那么获取p节点的下一个节点
        Node<E> next = succ(p);
        // 如果p的下一个节点也为空，说明这个队列已经空了
        if (next == null) {
            // 更新头节点。
            updateHead(h, p);
            break;
        }
        // 如果下一个元素不为空，则将头节点的下一个节点设置成头节点
        p = next;
    }
    return null;
}
```

## 6.3 Java中的阻塞队列
### 6.3.1 什么是阻塞队列
>阻塞队列（BlockingQueue）是一个支持两个附加操作的队列。这两个附加的操作支持阻塞的插入和移除方法。
1. 支持阻塞的插入方法：意思是当队列满时，队列会阻塞插入元素的线程，直到队列不满。
2. 支持阻塞的移除方法：意思是在队列为空时，获取元素的线程会等待队列变为非空。

插入和移除操作的4中处理方式:
|方法/处理方式|抛出异常|返回特殊值|一直阻塞|超时退出|
|------------|-------|----------|---------------|
|插入方法|add(e)|offer(e)|put(e)|offer(e,time,unit)|
|移除方法|remove()|poll()|take()|poll(time,unit)|
|检查方法|element()|peek()|不可用|不可用|

### 6.3.2 Java 里的阻塞队列
1. ArrayBlockingQueuee：一个由数组结构组成的有界阻塞队列。
2. LinkedBlockingQueue：一个由链表结构组成的有界阻塞队列。
3. PriorityBlockingQueue：一个支持优先级排序的无界阻塞队列。
4. DelayQueue：一个使用优先级队列实现的无界阻塞队列。
5. SynchronousQueue：一个不存储元素的阻塞队列。
6. LinkedTransferQueue：一个由链表结构组成的无界阻塞队列。
7. LinkedBlockingDeque：一个由链表结构组成的双向阻塞队列。


### 6.3.3 阻塞队列的实现原理
>使用通知模式实现： 典型的例子是生产者与消费者
```
public final void await() throws InterruptedException {
    if (Thread.interrupted())
        throw new InterruptedException();
    Node node = addConditionWaiter();
    int savedState = fullyRelease(node);
    int interruptMode = 0;
    while (!isOnSyncQueue(node)) {
        LockSupport.park(this);
        if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
            break;
    }
    if (acquireQueued(node, savedState) && interruptMode != THROW_IE)
        interruptMode = REINTERRUPT;
    if (node.nextWaiter != null) // clean up if cancelled
        unlinkCancelledWaiters();
    if (interruptMode != 0)
        reportInterruptAfterWait(interruptMode);
}
//调用setBlocker先保存一下将要阻塞的线程，然后调用unsafe.park阻塞当前线程。
public static void park(Object blocker) {
    Thread t = Thread.currentThread();
    setBlocker(t, blocker);
    unsafe.park(false, 0L);
    setBlocker(t, null);
}
//unsafe.park是个native方法
```
park这个方法会阻塞当前线程，只有以下4种情况中的一种发生时，该方法才会返回:
1. ·与park对应的unpark执行或已经执行时。“已经执行”是指unpark先执行，然后再执行park的情况。
2. ·线程被中断时。
3. ·等待完time参数指定的毫秒数时。
4. ·异常现象发生时，这个异常现象没有任何原因。

### 6.4 Fork/Join框架
#### 6.4.1 什么是Fork/Join框架
>Fork/Join框架是Java 7提供的一个用于并行执行任务的框架，是一个把大任务分割成若干个小任务，最终汇总每个小任务结果后得到大任务结果的框架。
![ForkJoin Running Process](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/ForkJoinRunningProcess.jpg?raw=true)

### 6.4.2 工作窃取算法
>工作窃取（work-stealing）算法是指某个线程从其他队列里窃取任务来执行。

![Job Steal Algorithm](https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/JobStealAlgorithm.jpg?raw=true)

>工作窃取算法的优点：充分利用线程进行并行计算，减少了线程间的竞争。
>
>工作窃取算法的缺点：在某些情况下还是存在竞争，比如双端队列里只有一个任务时。并且该算法会消耗了更多的系统资源，比如创建多个线程和多个双端队列。

### 6.4.3 Fork/Join框架的设计
Steps:
1. 分割任务
2. 执行任务并合并结果

Fork/Join使用两个类来完成以上两件事情。
1. ForkJoinTask：我们要使用ForkJoin框架，必须首先创建一个ForkJoin任务。Fork/Join矿机提供以下两个子类，继承它的子类即可：
    A. RecursiveAction：用于没有返回结果的任务。
    B. RecursiveTask：用于有返回结果的任务。
2. ForkJoinPool：ForkJoinTask需要通过ForkJoinPool来执行。
\# 任务分割出的子任务会添加到当前工作线程所维护的双端队列中，进入队列的头部。当一个工作线程的队列里暂时没有任务时，它会随机从其他工作线程的队列的尾部获取一个任务。

### 6.4.4 使用Fork/Join框架
```
//Example
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.Future;
import java.util.concurrent.RecursiveTask;

public class CountTask extends RecursiveTask<Integer> {
    private static final int THRESHOLD = 2; // 阈值
    private int start;
    private int end;

    public CountTask(int start, int end) {
        this.start = start;
        this.end = end;
    }

    @Override
    protected Integer compute() {
        int sum = 0;
        // 如果任务足够小就计算任务
        boolean canCompute = (end - start) <= THRESHOLD;
        if (canCompute) {
            for (int i = start; i <= end; i++) {
                sum += i;
            }
        } else {
            // 如果任务大于阈值，就分裂成两个子任务计算
            int middle = (start + end) / 2;
            CountTask leftTask = new CountTask(start, middle);
            CountTask rightTask = new CountTask(middle + 1, end);
            // 执行子任务
            leftTask.fork();
            rightTask.fork();
            // 等待子任务执行完，并得到其结果
            int leftResult = leftTask.join();
            int rightResult = rightTask.join();
            // 合并子任务
            sum = leftResult + rightResult;
        }
        return sum;
    }

    public static void main(String[] args) {
        ForkJoinPool forkJoinPool = new ForkJoinPool();
        // 生成一个计算任务，负责计算1+2+3+4
        CountTask task = new CountTask(1, 4);
        // 执行一个任务
        Future<Integer> result = forkJoinPool.submit(task);
        try {
            System.out.println(result.get());
        } catch (InterruptedException e) {
        } catch (ExecutionException e) {
        }
    }
}
```

### 6.4.5 Fork/Join框架的异常处理
```
if(task.isCompletedAbnormally()){
    System.out.println(task.getException());
}
```
\# getException方法返回Throwable对象，如果任务被取消了则返回CancellationException。如果任务没有完成或者没有抛出异常则返回null。

### 6.4.6 Fork/Join框架的实现原理
ForkJoinPool由ForkJoinTask数组和ForkJoinWorkerThread数组组成，ForkJoinTask数组负责将存放程序提交给ForkJoinPool的任务，而ForkJoinWorkerThread数组负责执行这些任务。
#### 6.4.6.1 ForkJoinTask的fork方法实现原理
>当我们调用ForkJoinTask的fork方法时，程序会调用ForkJoinWorkerThread的pushTask方法异步地执行这个任务，然后立即返回结果
```
public final ForkJoinTask<V> fork() {
    ((ForkJoinWorkerThread) Thread.currentThread())
    .pushTask(this);
    return this;
}
```
>pushTask方法把当前任务存放在ForkJoinTask数组队列里。然后再调用ForkJoinPool的signalWork()方法唤醒或创建一个工作线程来执行任务
```
final void pushTask(ForkJoinTask<> t) {
    ForkJoinTask<>[] q; int s, m;
    if ((q = queue) != null) { // ignore if queue removed
        long u = (((s = queueTop) & (m = q.length - 1)) << ASHIFT) + ABASE;
        UNSAFE.putOrderedObject(q, u, t);
        queueTop = s + 1; // or use putOrderedInt
        if ((s -= queueBase) <= 2)
            pool.signalWork();
        else if (s == m)
            growQueue();
    }
}
```

#### 6.4.6.2 ForkJoinTask的join方法实现原理
>Join方法的主要作用是阻塞当前线程并等待获取结果。让我们一起看看ForkJoinTask的join方法的实现
```
public final V join() {
    if (doJoin() != NORMAL)
        return reportResult();
    else
        return getRawResult();
}
private V reportResult() {
        int s; Throwable ex;
        if ((s = status) == CANCELLED)
            throw new CancellationException();
        if (s == EXCEPTIONAL && (ex = getThrowableException()) != null)
            UNSAFE.throwException(ex);
    return getRawResult();
}
```
>首先，它调用了doJoin()方法，通过doJoin()方法得到当前任务的状态来判断返回什么结果，任务状态有4种：已完成（NORMAL）、被取消（CANCELLED）、信号（SIGNAL）和出现异常（EXCEPTIONAL）。
1. ·如果任务状态是已完成，则直接返回任务结果。
2. ·如果任务状态是被取消，则直接抛出CancellationException。
3. ·如果任务状态是抛出异常，则直接抛出对应的异常。
```
private int doJoin() {
    Thread t; ForkJoinWorkerThread w; int s; boolean completed;
    if ((t = Thread.currentThread()) instanceof ForkJoinWorkerThread) {
        if ((s = status) < 0)
            return s;
        if ((w = (ForkJoinWorkerThread)t).unpushTask(this)) {
            try {
                completed = exec();
            } catch (Throwable rex) {
                return setExceptionalCompletion(rex);
            }
            if (completed)
                return setCompletion(NORMAL);
        }
        return w.joinTask(this);
    }
    else
        return externalAwaitDone();
}
```

>在doJoin()方法里，首先通过查看任务的状态，看任务是否已经执行完成，如果执行完成，则直接返回任务状态；如果没有执行完，则从任务数组里取出任务并执行。如果任务顺利执行完成，则设置任务状态为NORMAL，如果出现异常，则记录异常，并将任务状态设置为EXCEPTIONAL。

# 7 Java中的13个原子操作类
>1.5开始提供了java.util.concurrent.atomic包（以下简称Atomic包），这个包中的原子操作类提供了一种用法简单、性能高效、线程安全地更新一个变量的方式。
>
>因为变量的类型有很多种，所以在Atomic包里一共提供了13个类，属于4种类型的原子更新方式，分别是原子更新基本类型、原子更新数组、原子更新引用和原子更新属性（字段）。

## 7.1 原子更新基本类型类
> 使用原子的方式更新基本类型，Atomic包提供了以下3个类。
1. ·AtomicBoolean：原子更新布尔类型。
2. ·AtomicInteger：原子更新整型。
3. ·AtomicLong：原子更新长整型
>以上3个类提供的方法几乎一模一样，所以本节仅以AtomicInteger为例进行讲解，AtomicInteger的常用方法如下:
1. ·int addAndGet（int delta）：以原子方式将输入的数值与实例中的值（AtomicInteger里的value）相加，并返回结果。
2. ·boolean compareAndSet（int expect，int update）：如果输入的数值等于预期值，则以原子方式将该值设置为输入的值。
3. ·int getAndIncrement()：以原子方式将当前值加1，注意，这里返回的是自增前的值。
4. ·void lazySet（int newValue）：最终会设置成newValue，使用lazySet设置值后，可能导致其他线程在之后的一小段时间内还是可以读到旧的值。
5. ·int getAndSet（int newValue）：以原子方式设置为newValue的值，并返回旧值。

```
//Example：
import java.util.concurrent.atomic.AtomicInteger;
public class AtomicIntegerTest {
    static AtomicInteger ai = new AtomicInteger(1);
    public static void main(String[] args) {
        System.out.println(ai.getAndIncrement());
        System.out.println(ai.get());
    }
}
```

## 7.2 原子更新数组
>通过原子的方式更新数组里的某个元素，Atomic包提供了以下4个类:
```
1. AtomicIntegerArray：原子更新整型数组里的元素。
2. AtomicLongArray：原子更新长整型数组里的元素。
3. AtomicReferenceArray：原子更新引用类型数组里的元素。
4. tomicIntegerArray类主要是提供原子的方式更新数组里的整型，其常用方法如下。
    A. ·int addAndGet（int i，int delta）：以原子方式将输入值与数组中索引i的元素相加。
    B. ·boolean compareAndSet（int i，int expect，int update）：如果当前值等于预期值，则以原子方式将数组位置i的元素设置成update值。
```
>以上几个类提供的方法几乎一样，所以本节仅以AtomicIntegerArray为例进行讲解，AtomicIntegerArray的使用实例代码如代码清单如下:
```
public class AtomicIntegerArrayTest {
    static int[] value = new int[] { 1， 2 };
    static AtomicIntegerArray ai = new AtomicIntegerArray(value);
    public static void main(String[] args) {
        ai.getAndSet(0， 3);
        System.out.println(ai.get(0));
        System.out.println(value[0]);
    }
}
//output:
//3
//1
```
\# 需要注意的是，数组value通过构造方法传递进去，然后AtomicIntegerArray会将当前数组复制一份，所以当AtomicIntegerArray对内部的数组元素进行修改时，不会影响传入的数组。

##7.3 原子更新引用类型
>原子更新基本类型的AtomicInteger，只能更新一个变量，如果要原子更新多个变量，就需要使用这个原子更新引用类型提供的类。Atomic包提供了以下3个类。
1. ·AtomicReference：原子更新引用类型。
2. ·AtomicReferenceFieldUpdater：原子更新引用类型里的字段。
3. ·AtomicMarkableReference：原子更新带有标记位的引用类型。可以原子更新一个布尔类型的标记位和引用类型。构造方法是AtomicMarkableReference（V initialRef，booleaninitialMark）。
>以上几个类提供的方法几乎一样，所以本节仅以AtomicReference为例进行讲解，AtomicReference的使用示例代码如代码清单
```
public class AtomicReferenceTest {
    public static AtomicReference<User> atomicUserRef = new AtomicReference<User>();
    public static void main(String[] args) {
        User user = new User("conan"， 15);
        atomicUserRef.set(user);
        User updateUser = new User("Shinichi"， 17);
        atomicUserRef.compareAndSet(user， updateUser);
        System.out.println(atomicUserRef.get().getName());
        System.out.println(atomicUserRef.get().getOld());
    }
    static class User {
        private String name;
        private int old;
        public User(String name， int old) {
            this.name = name;
            this.old = old;
        }
        public String getName() {
            return name;
        }
        public int getOld() {
            return old;
        }
    }
}
//output:
//Shinichi
//17
```
\# 代码中首先构建一个user对象，然后把user对象设置进AtomicReferenc中，最后调用compareAndSet方法进行原子更新操作，实现原理同AtomicInteger里的compareAndSet方法。

## 7.4 原子更新字段
>如果需原子地更新某个类里的某个字段时，就需要使用原子更新字段类，Atomic包提供了以下3个类进行原子字段更新
1. ·AtomicIntegerFieldUpdater：原子更新整型的字段的更新器。
2. ·AtomicLongFieldUpdater：原子更新长整型字段的更新器。
3. ·AtomicStampedReference：原子更新带有版本号的引用类型。该类将整数值与引用关联起来，可用于原子的更新数据和数据的版本号，可以解决使用CAS进行原子更新时可能出现的ABA问题。
>要想原子地更新字段类需要两步。第一步，因为原子更新字段类都是抽象类，每次使用的时候必须使用静态方法newUpdater()创建一个更新器，并且需要设置想要更新的类和属性。第二步，更新类的字段（属性）必须使用public volatile修饰符。

```
public class AtomicIntegerFieldUpdaterTest {
    // 创建原子更新器，并设置需要更新的对象类和对象的属性
    private static AtomicIntegerFieldUpdater<User> a = AtomicIntegerFieldUpdater.newUpdater(User.class， "old");
    public static void main(String[] args) {
        // 设置柯南的年龄是10岁
        User conan = new User("conan"， 10);
        // 柯南长了一岁，但是仍然会输出旧的年龄
        System.out.println(a.getAndIncrement(conan));
        // 输出柯南现在的年龄
        System.out.println(a.get(conan));
    }
    public static class User {
        private String name;
        public volatile int old;
        public User(String name， int old) {
            this.name = name;
            this.old = old;
        }
        public String getName() {
            return name;
        }
        public int getOld() {
            return old;
        }
    }
}
//output:
//10
//11
```

# 8 Java中的并发工具类
>在JDK的并发包里提供了几个非常有用的并发工具类。
>
>CountDownLatch、CyclicBarrier和Semaphore工具类提供了一种并发流程控制的手段
>
>Exchanger工具类则提供了在线程间交换数据的一种手段

## 8.1 等待多线程完成的CountDownLatch
> 与join有相似的功能，但CountDownLatch功能更丰富
```
public class CountDownLatchTest {
    staticCountDownLatch c = new CountDownLatch(2);
    public static void main(String[] args) throws InterruptedException {
        new Thread(new Runnable() {
            @Override
            public void run() {
                System.out.println(1);
                c.countDown();
                System.out.println(2);
                c.countDown();
            }
        }).start();
        c.await();
        System.out.println("3");
    }
}
```
>以可以使用另外一个带指定时间的await方法——await（long time，TimeUnit unit），这个方法等待特定时间后，就会不再阻塞当前线程。join也有类似的方法。
\# 计数器必须大于等于0，只是等于0时候，计数器就是零，调用await方法时不会阻塞当前线程。CountDownLatch不可能重新初始化或者修改CountDownLatch对象的内部计数器的值。一个线程调用countDown方法happen-before，另外一个线程调用await方法。

## 8.2 同步屏障CyclicBarrie
>它要做的事情是，让一组线程到达一个屏障（也可以叫同步点）时被阻塞，直到最后一个线程到达屏障时，屏障才会开门，所有被屏障拦截的线程才会继续运行。
```
public class CyclicBarrierTest {
    staticCyclicBarrier c = new CyclicBarrier(2);

    public static void main(String[] args) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    c.await();
                } catch (Exception e) {
                }
                System.out.println(1);
            }
        }).start();
        try {
            c.await();
        } catch (Exception e) {
        }
        System.out.println(2);
    }
}
//An Advance Example
import java.util.concurrent.CyclicBarrier;

public class CyclicBarrierTest2 {
    //A.run() will run before main thread and sub thread
    //在指定数量的线程到达屏障时，优先执行A.run()
    static CyclicBarrier c = new CyclicBarrier(2, new A());

    public static void main(String[] args) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    c.await();
                } catch (Exception e) {
                }
                System.out.println(1);
            }
        }).start();
        try {
            c.await();
        } catch (Exception e) {
        }
        System.out.println(2);
    }

    static class A implements Runnable {
        @Override
        public void run() {
            System.out.println(3);
        }
    }
}
```

### 8.2.2 CyclicBarrier的应用场景
```
import java.util.Map.Entry;
import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

/**
* 银行流水处理服务类
*
* @authorftf
*
*/
publicclass BankWaterService implements Runnable{
    /**
     * 创建4个屏障，处理完之后执行当前类的run方法
     */
    private CyclicBarrier c = new CyclicBarrier(4, this);
    /**
     * 假设只有4个sheet，所以只启动4个线程
     */
    private Executor executor = Executors.newFixedThreadPool(4);
    /**
     * 保存每个sheet计算出的银流结果
     */
    private ConcurrentHashMap<String, Integer> sheetBankWaterCount = new ConcurrentHashMap<String, Integer>();

    private void count() {
        for (inti = 0; i < 4; i++) {
            executor.execute(new Runnable() {
                @Override
                public void run() {
                    // 计算当前sheet的银流数据，计算代码省略
                    sheetBankWaterCount.put(Thread.currentThread().getName(), 1);
                    // 银流计算完成，插入一个屏障
                    try {
                        c.await();
                    } catch (InterruptedException | BrokenBarrierException e) {
                        e.printStackTrace();
                    }
                }
            });
        }
    }

    @Override
    public void run() {
        intresult = 0;
        // 汇总每个sheet计算出的结果
        for (Entry<String, Integer> sheet : sheetBankWaterCount.entrySet()) {
            result += sheet.getValue();
        }
        // 将结果输出
        sheetBankWaterCount.put("result", result);
        System.out.println(result);
    }

    public static void main(String[] args) {
        BankWaterService bankWaterCount = new BankWaterService();
        bankWaterCount.count();
    }
}

```

### 8.2.3 CyclicBarrier和CountDownLatch的区别
>CountDownLatch的计数器只能使用一次，而CyclicBarrier的计数器可以使用reset()方法重置。所以CyclicBarrier能处理更为复杂的业务场景。例如，如果计算发生错误，可以重置计数器，并让线程重新执行一次。
>
>CyclicBarrier还提供其他有用的方法，比如getNumberWaiting方法可以获得Cyclic-Barrier阻塞的线程数量。isBroken()方法用来了解阻塞的线程是否被中断

## 8.3 控制并发线程数的Semaphore
>Semaphore（信号量）是用来控制同时访问特定资源的线程数量，它通过协调各个线程，以保证合理的使用公共资源。

### 8.3.1 应用场景 --- 限制线程并发数
```
class SemaphoreTest {
    private static final int THREAD_COUNT = 30;
    private static ExecutorService threadPool = Executors.newFixedThreadPool(THREAD_COUNT);
    private static Semaphore s = new Semaphore(10);

    public static void main(String[] args) {
        for (inti = 0; i < THREAD_COUNT; i++) {
            threadPool.execute(new Runnable() {
                @Override
                public void run() {
                    try {
                        s.acquire();
                        System.out.println("save data");
                        s.release();
                    } catch (InterruptedException e) {
                    }
                }
            });
        }
        threadPool.shutdown();
    }
}
```

### 8.3.2 其他方法
1. ·intavailablePermits()：返回此信号量中当前可用的许可证数。
2. ·intgetQueueLength()：返回正在等待获取许可证的线程数。
3. ·booleanhasQueuedThreads()：是否有线程正在等待获取许可证。
4. ·void reducePermits（int reduction）：减少reduction个许可证，是个protected方法。
5. ·Collection getQueuedThreads()：返回所有等待获取许可证的线程集合，是个protected方法。

## 8.4 线程间交换数据的Exchanger
>Exchanger用于进行线程间的数据交换。它提供一个同步点，在这个同步点，两个线程可以交换彼此的数据。这两个线程通过exchange方法交换数据，如果第一个线程先执行exchange()方法，它会一直等待第二个线程也执行exchange方法，当两个线程都到达同步点时，这两个线程就可以交换数据，将本线程生产出来的数据传递给对方。
```
public class ExchangerTest {
    private static final Exchanger<String> exgr = new Exchanger<String>();
    private static ExecutorService threadPool = Executors.newFixedThreadPool(2);

    public static void main(String[] args) {
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    String A = "银行流水A"; // A录入银行流水数据
                    exgr.exchange(A);
                } catch (InterruptedException e) {
                }
            }
        });
        threadPool.execute(new Runnable() {
            @Override
            public void run() {
                try {
                    String B = "银行流水B"; // B录入银行流水数据
                    String A = exgr.exchange("B");
                    System.out.println("A和B数据是否一致：" + A.equals(B) + "，A录入的是：" + A + "，B录入是：" + B);
                } catch (InterruptedException e) {
                }
            }
        });
        threadPool.shutdown();
    }
}
```
>如果两个线程有一个没有执行exchange()方法，则会一直等待，如果担心有特殊情况发生，避免一直等待，可以使用exchange（V x，longtimeout，TimeUnit unit）设置最大等待时长。

# 9 Java中的线程池
合理地使用线程池能够带来3个好处:
1. 降低资源消耗。通过重复利用已创建的线程降低线程创建和销毁造成的消耗。
2. 提高响应速度。当任务到达时，任务可以不需要等到线程创建就能立即执行。
3. 提高线程的可管理性。线程是稀缺资源，如果无限制地创建，不仅会消耗系统资源，还会降低系统的稳定性，使用线程池可以进行统一分配、调优和监控。但是，要做到合理利用线程池，必须对其实现原理了如指掌。

## 9.1 线程池的实现原理
