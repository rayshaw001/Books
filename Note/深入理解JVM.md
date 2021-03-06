\# 深入理解JVM Based on JDK1.7

# Part 1 走进Java
## 1 走进Java

# Part 2 自动内存管理机制
## 2 Java内存区域与内存溢出异常
### 2.1 概述
>内存自动回收

### 2.2 运行时数据区域
![Java Running Data Area](https://github.com/rayshaw001/common-pictures/blob/master/deep%20in%20JVM/JavaRunningDataArea.jpg?raw=true)

#### 2.2.1 程序计数器

1. 为了线程切换后能恢复到正确的执行位置，每条线程都需要有一个独立的程序计数器
2. Native方法的计数器值为空（undifined）

#### 2.2.2 Java 虚拟机栈
1. Java 虚拟机栈是线程私有的，它的生命周期与线程相同
2. 虚拟机栈描述的是Java方法执行的内存模型：每个方法执行的时候都会创建一个栈帧，里面存储着如下数据
    ```
        1.  局部变量表：boolean、int、long、float、double、char、byte、Reference
        2. 操作栈
        3. 动态链接
        4. 方法出口
    ```

#### 2.2.3 本地方法栈
1. 与Java 虚拟机栈功能相似
2. 虚拟机栈为执行Java方法服务
3. 本地方法栈为Native方法服务
4. Sun HotSpot虚拟机直接把本地方法栈和虚拟机栈合二为一

#### 2.2.4 Java 堆
1. 所有线程共享的一块内存区域
2. 在虚拟机启动是创建
3. 此内存区域的唯一目的就是存放对象实例

#### 2.2.5 方法区
1. 各个线程共享的内存区域
2. 存储的信息：
    ```
        1. 以被虚拟机加载的信息
        2. 常量
        3. 静态变量
        4. 即时编译器编译后的代码等数据
    ```
3. 方法区与永久代并不等价
4. 垃圾收集行为在方法区很少见，这个区域的内存回收目标主要是针对常量池的回收和对类型的卸载
5. 方法区无法满足内存分配需求时，将抛出OutOfMemoryError异常

#### 2.2.6 运行常量池
1. Runtime Constant Pool是方法区的一部分
2. 运行期间也可能将新的常量放入常量池，例如String类的intern()方法

#### 2.2.7 直接内存
1. 直接内存不是虚拟机运行时数据区的一部分
2. jdk1.4 新加入的NIO类，引入了一种基于通道与缓冲区的I/O方式
3. 使用Native函数库直接分配堆外内存，在通过一个存储在Java堆里面的DirectByteBuffer对象作为这块内存的应用进行操作
4. 因为避免了Java堆个Native堆中来回复制数据，所以能在一些场景中显著提高性能
5. 直接内存不会受到Java堆大小的限制，但是会受到本机总内存大小的限制

### 2.3 访问对象
>Object obj = new Object();
>
>>Object obj 这部分的语义将会反映到Java栈的本地变量表中
>>
>>new Object() 这部分的语义将会反映到Java堆中
>
>不同的虚拟机实现的对象访问方式会有所不同，主流的访问方式有两种：句柄和直接指针

1. 如果使用句柄方式访问，Java堆中将会划分出一块内存来作为句柄池，reference中存储的就是对象的句柄地址，句柄中包含了对象实例数据和各类型数据各自的具体地址信息
2. 如果使用直接指针访问方式，Java堆对象的布局中就必须考虑如何放置访问类型数据的相关信息，rederence中直接存储的就是对象地址
3. 句柄访问方式的最大好处就是reference存储的是稳定的句柄地址，在对象被移动（垃圾收集时移动对象是非常普遍的行为）时只会改变句柄中的实例数据指针，而reference本身不需要被修改。
4. 直接访问方式的好处就是速度更快，它节省了一次指针定位的时间开销，Sun HotSpot使用第二种方式进行对象访问


### 2.4 实战： OutOfMemoryError 异常

##### 2.4.1 Java堆溢出
1. 保证GC Roots 到对象之间有可达路径来避免垃圾回收机制清除这些对象
2. 内存堆转储快照以便事后分析

#### 2.4.2 虚拟机栈和本地方法栈溢出

#### 2.4.3 运行时常量池溢出

#### 2.4.4 方法区溢出

#### 2.4.5 本机直接内存溢出

### 2.5 本章小结

## 3 垃圾收集器与内存分配策略
### 3.1 概述
>GC需要完成的三件事情：

1. 那些内存需要回收
2. 什么时候回收
3. 如何回收

\# 了解GC和内存分配对排查各种内存溢出、内存泄漏问题是，当垃圾收集成为系统达到更高并发量的瓶颈时，我们就需要对这些“自动化”的技术实施必要的监控和调节

### 3.2 对象已死？
>垃圾回收之前，第一件事情就是要确定这些对象有哪些还“活着”，哪些已经“死去”

#### 3.2.1 引用计数法
1. 给对象添加一个引用计数器，每当有一个地方引用它时，计数器值就加1，当引用失效时，计数器值就减1；任何时刻计数器都为0的对象就是不可能再被使用的。
2. 它很难解决对象之间的相互循环引用的问题

#### 3.2.2 根搜索算法
0. 可达性：通过一系列的名为"GC Roots"的对象爱你个座位起始点，从这些节点开始向下搜索，搜索所有走过的路径成为引用链，当一个对象到GC Roots没有任何引用链相连时（GC Roots到这个对象不可达），则证明此对象是不可用的

>可作为GC Roots的对象包括下面几种：

1. 虚拟机栈（栈帧中的本地变量表）中的引用的对象
2. 方法区中的类静态属性引用的对象
3. 方法区中的常量引用的对象
4. 本地方法栈中JNI（Native方法）的引用的对象

#### 3.2.3 再谈引用

1. 强引用   类似Object obj = new Object()只要强引用还存在，垃圾收集器永远不会回收掉被引用的内存
2. 软引用（SoftReference）   用来描述一些还有用，但并非必须的对象。在系统将要发生内存溢出异常之前，将会把这些对象列进回收范围之中并进行第二次回收
3. 弱引用（WeakReference）   用来描述非必需对象的，被弱引用关联的对象只能生存到下一次垃圾收集发生之前
4. 虚引用（PhantomReference）无法通过虚引用来取得一个对象，为一个对象设置虚引用关联的唯一目的就是希望能在这个对象被收集器回收时受到一个系统通知   

#### 3.2.4 生存还是死亡？

1. finalize()方法只会被系统调用一次
2. finalize()能做的工作，使用try-finally或其他方式都可以做得更好、更及时

#### 3.2.5 回收方法区
>永久代的垃圾手机主要回收量部分内容：废弃常量和无用的类

1. 废弃常量：没有任何地方引用的常量
2. 无用的类：
    ```
        1. 该类的所有实例都已经被回收
        2. 加载该类的ClassLoader已经被回收
        3. 该类对应的Java.lang.Class对象没有在任何地方被引用
    ```
3. 并不是所有的虚拟机都会对无用的类进行回收，这取决于具体的虚拟机实现
4. 大量使用反射、动态代理、CGLib等bytecode框架的场景，以及动态生成JSP和OSGi这类频繁自定义ClassLoader的场景都需要虚拟机具备类卸载的功能，以保证永久代不会溢出。

### 3.3 垃圾收集算法
#### 3.3.1 标记-清除算法
1. “标记”和“清除”两个阶段：首先标记出所有需要回收的对象，在标记完成后统一回收掉所有被标记的对象
2. 主要缺点有两个：
```
    1. 效率问题：标记和清除过程效率都不高
    2. 空间问题，标记清除之后会产生大量不连续的内存碎片，可能导致程序在以后的运行过程中需要分配较大对象是无法找到足够的连续内存而不得不提前出发一次垃圾收集动作
```

#### 3.3.2 复制算法
>为了解决效率问题--复制收集算法

1. 将内存按容量分为大小相等的两块，每次只使用其中一块，当这一块内存用完了，就将还存活着的对象复制到另外一块上面，然后在吧已使用过的内存空间一次清理掉
2. 代价是将内存缩小为原来的一半
3. 现代虚拟机都采用这种收集算法来回收新生代
4. 并不是，也不需要按照1：1的比例来划分内存空间
5. 将内存划分为一块较大的Eden空间和两块较小的Survivor空间（默认值Eden：Survivor=8：1）
6. 当回收时，将Eden和Survivor中还存活着的对象一次性地拷贝到另外一块Survivor空间上，最后清理掉Eden和刚才用过的Survivor空间

#### 3.3.3 标记-整理算法
1. 标记过程和“标记-清除”算法一致
2. 清理过程是让所有存活的对象都想一端移动，然后直接清理掉端边界以外的内存

#### 3.3.4 分代收集算法
1. 根据对象的存活周期哦的不同将内存划分为几块
2. 一般把Java堆分为新生代和老年代，然后根据各个年代的特点采用最适当的收集算法
3. 通常新生代采用复制算法，老年代采用“标记-清理”或“标记-整理”算法来进行回收

### 3.4 垃圾收集器

1. 收集算法是内存回收的方法论，垃圾收集器是内存回收的具体实现。

![JVMCollectors](https://github.com/rayshaw001/common-pictures/blob/master/deep%20in%20JVM/JVMCollectors.jpg?raw=true)

#### 3.4.1 Serial收集器
1. 单线程
2. Stop The World
3. 简单高效
4. 常用于client

#### 3.4.2 ParNew 收集器
1. ParNew 收集器其实就是Serial收集器的多线程版本

#### 3.4.3 Parallel Scavenge 收集器
1. 目标是达到一个可控的吞吐量，吞吐量= 运行用户代码时间/（运行用户代码时间+垃圾收集时间）
2. 停顿时间短 适合需要与用户交互的程序
3. 高吞吐量   适合在后台运算而不需要太多交互的任务

#### 3.4.4 Serial Old 收集器
1. Serial收集器的老年代版本
2. 单线程，使用"标记-整理"算法
3. 主要是Client模式下使用

#### 3.4.5 Parallel Old 收集器
1. Parallel Scavenge 收集器的老年代版本
2. 使用多线程和"标记-整理"算法

#### 3.4.6 CMS （Concurrent Mark Sweep）收集器
1. CMS收集器是以一种获取最短回收停顿时间为目标的收集器
2. 重视服务响应速度
3. 使用"标记-清除"算法
4. 分四个步骤：
    ```
    1. **初始标记（CMS initial mark）**     标记一下GC Roots能直接关联到的对象，速度很快
    2. 并发标记（CMS concurrent mark）      GC Roots Tracing
    3. **重新标记（CMS  remark）**          修正并发标记期间，因用户程序继续运行而导致标记产生变动的那一部分对象的标记记录
    4. 并发清除（CMS concurrent sweep）     
    ```
5. 初始标记和重新标记需要stop the world

>优点：

1. 并发收集
2. 低停顿

>缺点：

1. CMS收集器对CPU资源非常敏感，默认启动的回收线程数是（CPU数量+3）/ 4
2. CMS收集器无法处理浮动垃圾
    ```
    1. 可能出现“Concurrent Mode Failure”失败而导致另一次Full GC，
    2. 默认老年代使用了68%的空间后就会被激活
    3. CMS运行期间预留的内存无法满足程序需要就会出现一次“Concurrent Mode Failure”，这时就会临时启用Serial Old收集器来重新进行老年代的垃圾收集，这样停顿时间就很长了
    ```
3. 使用的“标记-清除”算法实现的收集器，收集结束时会产生大量空间碎片
    ```
    1. 无法找到足够大的连续空间来分配当前对象，会触发一次Full GC
    2. CMS收集器提佛那个 -XX:UseCMSCompactAtFullCollection开关参数，用于在Full GC之后会进行一次碎片整理过程
    3. 内存整理过程无法并发，所以整理空间碎片会导致GC时间变长
    4. -XX:CNSFullGCsBeforeCompaction,这个参数用于设置在执行多少次不压缩的Full GC后，跟着来一次带压缩的
    ```

#### 3.4.7 G1收集器
>它比CMS收集器有两个显著的该进：

1. 基于“标记-整理”算法实现
2. 可以非常精准地控制停顿，可以明确地指定在一个时间长度为M毫秒的时间片内，消耗在垃圾收集上的时间不得超过N毫秒

>原理：

1. 将整个Java堆（包括新生代，老生代）划分为多个大小固定的独立区域
2. 跟踪这些区域里面的垃圾堆积程度，在后台维护一个有限列表，
3. 每次根据允许的收集时间，有限回收垃圾最多的区域（Garbage First名称的由来）

#### 3.4.8 垃圾收集器参数总结
![Params For Garbage Collect](https://github.com/rayshaw001/common-pictures/blob/master/deep%20in%20JVM/ParamsForGarbageCollect.png?raw=true)

### 3.5 内存分配与回收策略

#### 3.5.1 对象优先在Eden分配
1. 大多数情况下，对象在新生代Eden区中分配。当Eden去没有足够的空间进行分配时，虚拟机将发起一次Minor GC

#### 3.5.2 大对象直接进入老年代
1. 所谓大对象：需要大量连续内存空间的Java对象
2. -XX:PretenureSizeThreshold参数，令大于这个设置值的对象直接在老年代中分配。这样做的目的是避免在Eden区及两个Survivor区之间发生大量的内存拷贝（新生代采用复制算法收集内存）

#### 3.5.3 长期存活的对象将进入老年代
1. 给每个对象定义一个对象年龄（Age）计数器
2. 在Survivor空间中，对象每熬过一次Minor GC，年龄就增加1岁
3. 当它的年龄增加到一定程度（默认15岁），就会被晋升到老年代中

#### 3.5.4 动态对象年龄判定
>在survivor空间中相同年龄所有对象大小的总和大于Survivor空间的一半，年龄大于或等于该年龄的对象就可以直接进入老年代

#### 3.5.5 空间分配担保
1. 发生Minor GC时，虚拟机会检测之前每次晋升到老年代的平均大小是否大于老年代的剩余空间大小
2. 大于，则进行一次Full GC
3. 小于，则查看HandlePromotionFailure设置是否允许担保失败，如果允许，则只进行Minor GC，如果不允许，则进行一次Full GC

### 3.6 本章小结


## 4 虚拟机性能监控与故障处理工具

## 5 调优案例分析与实战

# Part 3 虚拟机执行子系统
## 6 类文件结构

## 7 虚拟机类加载机制

## 8 虚拟机字节码执行引擎

## 9 类加载及执行子系统的案例与实战

# Part 4 程序编译与代码优化
## 10 早期（编译期）优化

## 11 晚期（运行期）优化

# Part5 高效并发
## 12 Java内存模型与线程

## 13 线程安全与锁优化
