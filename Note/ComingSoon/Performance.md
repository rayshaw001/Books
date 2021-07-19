# Examples for performance optimization

## Cache
适用读多，写少的场景 autopass

读settings，settings一次性全部load进内存

ConcurrentHashMap.putIfAbsent(key, new Object()); 

```
public Object getCachedCon()

```

```
public synchronized T obtainObject(T obj){
    if(!cacheEnabled){
        return obj;
    }
    cached.add(obj);
}


```

## Objects resuse

## Lazy evalution

## Concurrency optimization

# Module level performance improvement

## REST API concurrency improvement

## URM concurrency improvement

# New features for performance

## High performance ad-hoc query API

## View pagination API

