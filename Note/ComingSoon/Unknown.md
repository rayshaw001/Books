\# target 
```
腾讯、百度、阿里的蚂蚁金服和国际支付宝部门、饿了么、爱奇艺、360、携程网、京东、华为、bilibili 与 UCLOUD
```

raft  paxos ZAB协议 ISR 拜占庭
3 种单例

public class Singleton{
    private static final Singleton instance = new Singleton();
    private Singleton(){

    }
    public static Singleton getInstance(){
        return instance;
    }
}

public class Singleton{
    private static Singleton instance = null;
    private Singleton(){

    }

    public static synchornized getInstance(){
        if(instance==null){
            instance=new Singleton();
        }
        return instance;
    }
}


public class Singleton{
    private Singleton(){

    }

    static class InstanceHolder{
        public Singleton instance = new SIngleton();
    }

    public static Singleton getInstance(){
        return InstanceHolder.instance;
    }
}


是什么痛点是什么、怎么解决

使用

具体

diagnostics
监控

QPS,TPS
几台机器、


SOAP,REST过时

Session

查看activiti源码，减少了重复开发、流程管理、

传统
使用guva

归纳性

项目架构、系统容量QPS、TPS最大并发

解耦、监听订单状态、
削峰、限流、
mysql：5000

bin log mysql日志5～6种日志redo、undo

命中索引

MySQL：
数据容量：2000/s,单表支持多少数据
分布式锁、加锁、解锁、可重入

单例、工厂、代理、模板

整体架构
必问：
单例、项目架构、
SQL 优化、性能分析工具
mysql