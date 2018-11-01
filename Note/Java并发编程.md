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