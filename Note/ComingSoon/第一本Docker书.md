# 1 简介
## 1.1 Docker简介

### 1.1.1 提供一个简单、轻量的建模方式
>大多数Docker容器只需不到1秒钟即可启动。（主要是除去了管理程序的开销）

### 1.1.2 职责的逻辑分离
>开发人员只需要关心容器中运行的应用程序
>
>运维人员只需要关心如何管理容器

### 1.1.3 快速、高效的开发生命周期
> 缩短代码从开发、测试到部署上线运行的周期，让你的应用程序具备可移植性，抑郁构建，并易于协作。

### 1.1.4 鼓励使用面向服务的架构

## 1.2 Docker组件
>Docker 核心组件
>>
>>Docker 客户端和服务器，也称为Docker引擎
>>
>>Docker 镜像
>>
>>Registry
>>
>>Docker 容器

### 1.2.1 Docker客户端和服务器
>Docker是一个C/S架构的程序
>
>Docker提供了一个命令行工具docker以及一整套RESTful API来与守护进程交互
>
>本地Docker客户端可以连接到另一台主机上的远程Docker守护进程

### 1.2.2 Docker 镜像
>构建Docker镜像:
>>
>>添加一个文件 （ ADD . /opt/soft/）
>>
>>执行一个命令 （CMD）
>>
>> 打开一个端口（EXPOSRE）

### 1.2.3 Registry

### 1.2.4 容器
>镜像是Docker生命周期中的构建或打包阶段，而容器是启动或执行阶段。总结起来就是：
>>
>>一个镜像格式
>>
>>一系列标准操作
>>
>>一个执行环境

## 1.3 能用Docker做什么
>提供了标准的隔离环境，可以用来L：
>>
>>加速本地开发和构建流程，使其更加搞笑、更加轻量化
>>
>>能让独立的服务或应用程序在不同的环境中，得到相同的运行结果
>>
>>用Docker创建隔离的环境来进行测试
>>
>>Docker可以让开发者先在本机上构建一个复杂的程序或架构来进行测试，而不是一开始就在生产环境部署、测试。
>>
>>构建一个PaaS基础设施
>>
>>为开发、测试提供一个轻量级的独立沙盒环境
>>
>>提供SaaS应用程序
>>
>>高性能、超大规模的宿主机部署

## 1.4 Docker与配置管理
>轻量：镜像分层

## 1.5 Docker 的技术组件
>Docker 运行与任何安装了现代Linux内核的X64主机上。推荐的内核版本是3.8以上
>>
>>原生linux容器格式：libcontainer
>>
>>Linux内核的命名空间，用于隔离文件系统、进程、和网络
>>
>>文件系统隔离：每个容器都有自己的root文件系统
>>
>>进程隔离：每个容器都运行在自己的进程环境中
>>
>>网络隔离：容器间的虚拟网络接口和IP地址都是分开的
>>
>>资源隔离和分组：使用cgroup将CPU和内存之类的资源独立分配给每个容器
>>
>>```写时复制```:文件系统都是通过写时复制创建的，所以文件系统是分层的、快速的，而且占用的磁盘空间更小
>>
>>日志：容器产生的STDOUT、STDERR和STDIN都会被记入日志
>>
>>交互式shell：用户可以创建一个伪tty终端

## 1.6 本书的内容
1. 安装Docker
2. 尝试使用Docker
3. 构建Docker镜像
4. 管理并共享Docker镜像
5. 运行、管理更复杂的Docker容器和Docker容器栈
6. 将Docker容器的部署纳入测试流程
7. 构建多容器的应用程序和环境
8. 介绍使用Docker Compose、Consul和Swarm进行Docker编配的基础
9. 探索Docker的API
10. 获取帮助文档并扩展Docker

## 1.7 Docker 资源
1. Docker官方主页

# 2 安装Docker
```
CE or EE

brew cask install docker

or Download from download.docker.com
```


# 3 Docker 入门

## 3.1 确保Docker已经就绪
```
docker info
```

## 3.2 运行我们的第一个容器
```
docker run -i -t ubuntu /bin/bash
```

## 3.3 使用第一个容器
```
exit 退出会使容器停止运行
```

## 3.4 容器的命名
```
sudo docker run --name miui_sec -it ubuntu /bin/bash

# 执行带参数的命令
sudo docker run --name miui_sec -i -t ubuntu -- ps -ef
```

## 3.5 重新启动已经停止的容器
```
docker start miui_sec
```
## 3.6 附着到容器
```
docker attach miui_sec
```

## 3.7 创建守护式容器
```
docker run --name miui_sec -itd ubuntu /bin/bash
```

## 3.8 容器内部都在干什么
```
docker logs miui_sec
```

## 3.9 Docker 日志驱动
```
docker run --name miui_sec -itd  --log-driver="syslog" ubuntu /bin/bash
```

## 3.10 查看容器内的进程
```
docker top miui_sec
```

## 3.11 Docker 统计信息
```
docker stats miui_sec
```

## 3.12 在容器内部运行进程
```
docker exec -ti miui_sec bash
```

## 3.13 停止守护式容器
```
docker stop miui_sec
```

## 3.14 自动重启容器
```
docker run -ti --name miui_sec ubuntu bash --restart=always|on-failure:5
```

## 3.15 深入容器
```
docker inspect miui_sec
```

## 3.16 删除容器
```
docker rm miui_sec
```

# 3.17 小结
Docker容器的基本工作原理

# 4 使用Docker 镜像 和仓库
## 什么是Docker镜像

|可写容器||
|---|---|
|镜像|加入Apache|
|镜像|加入emacs|
|基础镜像|ubuntu|

![Docker 文件系统分层](https://github.com/rayshaw001/common-pictures/blob/master/docker/DockerFileSystem.jpg?raw=true)



# 5 在测试中使用Docker



# 6 使用Docker 构建服务

# 7 Docker 编配和服务发现


# 8 使用Docker API

# 9 获得帮助和对Docker进行改进
