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