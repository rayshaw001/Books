# 1 并发编程的挑战
```
并发编程的目的是为了让程序运行得更快,但是,并不是动更多的线程就能让程序最大限度地并发执行。在进行并发编程时,如果希望通过多线程执行任务让程序运行得更快,面临非常多的挑战,比如上下文切换的问题、死锁的问题,以及受限于硬件和软件的资源限制问题,本章会介绍几种并发编程的挑战以及解决方案。
```
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
无锁并发、CAS算法、使用最小线程、使用协程
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

避免死锁的几个常见方法：
1. 避免一个线程同时获取多个锁
2. 避免一个线程在所内同时占用多个资源，尽量保证每个锁只占用一个资源
3. 尝试使用定时锁，使用lock.tryLock(timeout)来替代使用内部锁机制
4. 对于数据库锁，加锁和解锁必须在一个数据库连接里，否则会出现解锁失败的情况

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
```
Java代码在编译后会变成Java字节码，字节码被类加载器加载到JVM里，JVM执行字节码，最终需要转化为汇编指令在CPU上执行，Java中所使用的并发机制依赖于JVM的实现和CPU的指令。本章我们将深入底层一起探索下Java并发机制的底层实现原理。
```

## 2.1 volatile的应用
```
它比synchronized的使用和执行成本更低，因为它不会引起线程上下文的切换和调度。
```

### 2.1.1 volatile的定义与实现原理
Java语言规范第3版中对volatile的定义如下：
```
Java编程语言允许线程访问共享变量，为了确保共享变量能被准确和一致地更新，线程应该确保通过排他锁单独获得这个变量。Java语言提供了volatile，在某些情况下比锁要更加方便。如果一个字段被声明成volatile，Java线程内存模型确保所有线程看到这个变量的值是一致的。
```
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
```
本文详细介绍Java SE 1.6中为了减少获得锁和释放锁带来的性能消耗而引入的偏向锁和轻量级锁，以及锁的存储结构和升级过程。
```
利用synchronized实现同步的基础：Java中的每一个对象都可以作为锁。具体表现
为以下三种形式:
1. 对于普通同步方法，锁是当前实例对象
2. 对于静态同步方法，锁是当前类的Class对象
3. 对于同步方法块，锁是synchonized括号里配置的对象。

### 2.2.0 当一个线程试图访问同步代码块时，它首先必须得到锁，退出或抛出异常时必须释放锁。那么锁到底存在哪里呢？锁里面会存储什么信息呢？
```
monitorenter monitorexit
代码块同步是使用monitorenter
和monitorexit指令实现的，而方法同步是使用另外一种方式实现的。但是，方法的同步同样可以使用这两个指令来实现。
```

### 2.2.1 Java对象头
```
synchronized用的锁是存在Java对象头里的。如果对象是数组类型，则虚拟机用3个字宽（Word）存储对象头，如果对象是非数组类型，则用2字宽存储对象头。在32位虚拟机中，1字宽等于4字节，即32bit
```
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
```
大多数情况下，锁不仅不存在多线程竞争，而且总是由同一线程多次获得，为了让线程获得锁的代价更低而引入了偏向锁。
偏向锁会记录锁对象当前的线程id，以及标记当前对象使用的是偏向锁
```

##### 2.2.2.1.1 偏向锁的撤销
```
偏向锁使用了一种等到竞争出现才释放锁的机制，所以当其他线程尝试竞争偏向锁时，持有偏向锁的线程才会释放锁。偏向锁的撤销，需要等待全局安全点（在这个时间点上没有正在执行的字节码）。它会首先暂停拥有偏向锁的线程，然后检查持有偏向锁的线程是否活着，如果线程不处于活动状态，则将对象头设置成无锁状态；如果线程仍然活着，拥有偏向锁的栈会被执行，遍历偏向对象的锁记录，栈中的锁记录和对象头的Mark Word要么重新偏向于其他线程，要么恢复到无锁或者标记对象不适合作为偏向锁，最后唤醒暂停的线程
```

![Prefer Lock]((https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/PreferLock.jpg?raw=true))

##### 2.2.2.1.2 关闭偏向锁
```
偏向锁在Java 6和Java 7里是默认启用的，但是它在应用程序启动几秒钟之后才激活，如有必要可以使用JVM参数来关闭延迟：-XX:BiasedLockingStartupDelay=0。
如果你确定应用程序里所有的锁通常情况下处于竞争状态，可以通过JVM参数关闭偏向锁：-XX:-UseBiasedLocking=false，那么程序默认会进入轻量级锁状态。
```

#### 2.2.2.2 轻量级锁

##### 2.2.2.2.1 轻量锁加锁
```
线程在执行同步块之前，JVM会先在当前线程的栈桢中创建用于存储锁记录的空间，并将对象头中的Mark Word复制到锁记录中，官方称为Displaced Mark Word。然后线程尝试使用CAS将对象头中的Mark Word替换为指向锁记录的指针。如果成功，当前线程获得锁，如果失败，表示其他线程竞争锁，当前线程便尝试使用自旋来获取锁。
```

##### 2.2.2.2.2 轻量锁的解锁
```
轻量级解锁时，会使用原子的CAS操作将Displaced Mark Word替换回到对象头，如果成功，则表示没有竞争发生。如果失败，表示当前锁存在竞争，锁就会膨胀成重量级锁。
```

![Lite Lock Processes]((https://github.com/rayshaw001/common-pictures/blob/master/concurrentJava/LiteLock.jpg?raw=true))