\# 1 核心实现
# 1 Spring整体架构和环境搭建
## 1.1 Spring 的整体架构
![Spring Framework Runtime](https://github.com/rayshaw001/common-pictures/blob/master/Spring/SpringFrameworkRuntime.jpg?raw=true)

### 1.1.1 Core Container
```
Core和beans模块是框架的基础部分，提供IoC和DI
```
|Module|Description|
|---|---|
|Core|基本核心工具类|
|Beans|访问配置文件，创建和管理bean以及进行IoC和DI操作相关的所有类|
|Context|Context模块构建于Core和 Beans模块基础之上,提供了一种类似于JND注册器的框架式的对象访问方法。 Context模块继承了 Beans的特性,为 Spring核心提供了大量扩展,添加了对国际化(例如资源绑定)、事件传播、资源加载和对 Context的透明创建的支持。 Context模块同时也支持2EE的一些特性,例如EJB、JMX和基础的远程处理。 ApplicationContext接口是 Context模块的关键|
|Expression Language|Expression Language模块提供了一个强大的表达式语言用于在运行时查询和操纵对象。它是JSP2.1规范中定义的 unifed expression language的一个扩展,该语言支持设置/获取属性的值,属性的分配,方法的调用,访问数组上下文( accession the contextof arrays)、容器和索引器、逻辑和算术运算符、命名变量以及从 Spring的IoC容器中|
### 1.1.2 Data Access/Integration
```
Data Access/Integration层包含有IDBC、ORM、OXM、JMS和 Transaction模块
```
|Module|Description|
|------|-----------|
|JDBC|JDBC模块提供了一个JDBC抽象层,它可以消除冗长的JDBC编码和解析数据库厂商特有的错误代码。这个模块包含了 Spring对JDBC数据访问进行封装的所有类|
|ORM|ORM模块为流行的对象-关系映射API,如JPA、JDO、 Hibernate、 iBatis等,提供了个交互层。利用ORM封装包,可以混合使用所有 Spring提供的特性进行O/R映射。如前边提到的简单声明性事物管理|
|OXM|OXM模块提供了一个对 Object/XML映射实现的抽象层, Object/XML映射实现包括JAXB、 Castor., XMLBeans、JiBX和XStream|
|JMS|Java Messageing Service模块主要包含了一些制造和消费信息的特性|
|Transaction|Transaction模块支持编程和声明性的事物管理,这些事物类必须实现特定的接口,并且对所有的POJO都适用|
### 1.1.3 Web
```
Web上下文模块建立在应用程序上下文模块之上,为基于Web的应用程序提供了上下文。所以,Spring框架支持与 Jakarta Struts的集成。Web模块还简化了处理多部分请求以及将请求参数绑定到域对象的工作。Web层包含了Web、 Web-Servlet、 Web-Struts和 Web-Porlet模块,具体说明如下。
```
|Module|Description|
|------|-----------|
|Web|Web模块:提供了基础的面向Web的集成特性。例如,多文件上传、使用 servlet listeners初始化IoC容器以及一个面向Web的应用上下文,它还包含 Spring远程支持中Web的相关部分|
|Web-Servlet|Web-Servlet模块web.servlet.jar:该模块包含 Spring的 model-view-controller(MVC)实现, Spring的MvC框架使得模型范围内的代码和 web forms之间能够清楚地分离开来,并与 Spring框架的其他特性集成在一起|
|Web-Struts|web- Struts模块:该模块提供了对Srus的支持,使得类在 Spring应用中能够与一个典型的 Struts Web层集成在一起,注意,该支持在 Spring3.0中是 deprecated的|
|Web-Porlet|提供了用于Portlet环境和Web-Servlet模块的MVC的实现|

### 1.1.4 AOP
```
AOP模块提供了一个符合AOP联盟标准的面向切面编程的实现,它让你可以定义例如方法拦截器和切点,从而将逻辑代码分开,降低它们之间的耦合性。利用 source-level的元数据功能,还可以将各种行为信息合并到你的代码中,这有点像.Net技术中的 attribute概念。通过配置管理特性, Spring AOP模块直接将面向切面的编程功能集成到了 Spring框架中所以可以很容易地使 Spring框架管理的任何对象支持AOP。 Spring AOP模块为基于 Spring的应用程序中的对象提供了事务管理服务。通过使用 Spring AOP,不用依赖EJB组件,就可以将声明性事务管理集成到应用程序中。
```
|Module|Description|
|------|-----------|
|Aspects|Aspects模块提供了对AspectJ的集成支持|
|Instrumentation|Instrumentation模块提供了 class instrumentation支持和 classloader实现,使得可以在特定的应用服务器上使用|

### 1.1.5 Test
```
Test模块支持适用Junit和TestNG对Spring组件进行测试
```

## 1.2 环境搭建
### 1.2.1 安装github
### 1.2.2 安装Gradle
```
1. 创建GRADLE_HOME系统变量
2. 将GRADLE_HOME加到Pat环境变量
3. 测试：在cmd窗口输入 gradle -version
```
### 1.2.3 下载Spring
https://github.com/SpringSource/Spring-framework

# 2 容器的基本实现
## 2.1 容器的基本用法
Bean
```
public class MyTestBean{
    private String testStr = "testStr";
    public String getTestStr(){
        return testStr;
    }
    public void setTestStr(String testStr){
        this.setStr = testStr;
    }
}
```
配置文件
```
<?xml version=1.0" encoding="UTF-8"?>
<beans xmlns="http://www.Springframeworkorg/schema/beans" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.Springframework.org/schema/beans http://www.Springframework.org/schema/beans/Spring-beans.xsd">
    <bean id="myTestBean" class="bean.MyTestBean"/>
</beans>
```
测试代码
```
@SuppressWarnings("deprecation")
public class BeanFactoryTest{
    @Test
    public void testSimpleLoad(){
        BeanFactorybf = new XmlBeanFactory(new ClassPathResource("beanFactoryTest.xml"));
        MyTestBean bean = (MyTestBean)bf.getBean("myTestBean");
        assertEquals("testStr",bean.getTestStr());
    }
}
```

## 2.2 功能分析
![Simple Spring Function Architecture](https://github.com/rayshaw001/common-pictures/blob/master/Spring/SimpleSpringFunctionArchitecture.jpg?raw=true)

## 2.3 工程搭建
主要引入org.Springframework.beans.jar

## 2.4 Spring 结构组成
### 2.4.1 beans 包的层级结构
```
src/main/java
src/main/resource
src/test/java
src/test/resource
```
### 2.4.2 核心类介绍
```
XmlBeanFactory继承自 DefaultListableBeanFactory,而 DefaultListableBeanFactory是整个bean加载的核心部分,是Spring注册及加载bean的默认实现,而对于XmlBeanFactory与DefaultListableBeanFactory不同的地方其实是在 XmlBeanFactory中使用了自定义的XML读取器XmlBeanDefinitionReader,实现了个性化的 BeanDefinitionReader读取, DefaultListableBeanFactory继承了AbstractAutowireCapableBeanFactory并实现了ConfigurableListableBeanFactory以及BeanDefinitionRegistry接口。
以下是 ConfigurableListableBeanFactory的层次结构图以及相关类图
```
![Container Load Related Class Map](https://github.com/rayshaw001/common-pictures/blob/master/Spring/ContainerLoadRelatedClassMap.jpg?raw=true)

## 2.5 容器的基础
>XmlBeanFactory

### 2.5.1 配置文件封装

### 2.52 加载Bean

## 2.6 获取XML的验证模式

### 2.6.1 DTD与XSD区别

### 2.6.2 验证模式的读取

## 2.7 获取Document

### 2.7.1 EntityResovler 用法

## 2.8 解析及注册
>BeanDefinitions

### 2.8.1 profile 属性的使用

### 2.8.2 解析并注册
>BeanDefinition

# 3 默认标签的解析

## 3.1 bean 标签的解析及注册

### 3.1.1 解析BeanDefinition

### 3.1.2 AbstractBeanDefinition属性

### 3.1.3 属性默认标签中的自定义标签元素

### 3.1.4 注册解析的BeanDefinition

### 3.1.5 通知监听器解析及注册完成

## 3.2 alias标签的解析

## 3.3 import 标签的解析

## 3.4 嵌入式bean标签的解析

# 4 自定义标签的解析

## 4.1 自定义标签使用

## 4.2 自定义标签解析

### 4.2.1 获取标签的命名空间

### 4.2.2 提取自定义标签处理器

### 4.2.3 标签解析

# 5 bean的加载

## 5.1 FactoryBean的使用

## 5.2 缓存中获取单利bean

## 5.3 从bean的实例中获取对象

## 5.4 获取单例

## 5.5 准备创建bean

### 5.5.1 处理override属性

### 5.5.2 实例化的前置处理

## 5.6 循环依赖

### 5.6.1 什么是循环依赖

### 5.6.2 Spring如何解决循环依赖

## 5.7 创建bean

### 5.7.1 创建bean的实例

### 5.7.2 记录创建bean的ObjectFactory

### 5.7.3 属性注入

### 5.7.4 初始化bean

### 5.7.5 注册DisposableBean

# 6 容器的功能扩展

## 6.1 设置配置路径

## 6.2 扩展功能

## 6.3 准备环境

## 6.4 加载BeanFactory

### 6.4.1 定制BeanFactory

### 6.4.2 加载BeanDefinition

## 6.5 功能扩展

### 6.5.1 增加SPEL语言的支持

### 6.5.2 增加属性注册编辑器

### 6.5.3 添加ApplicationContext AwareProcessor处理器

### 6.5.4 设置忽略依赖

### 6.5.5 注册依赖

## 6.6 BeanFactory的后处理

### 6.6.1 激活注册的BeanFactory PostProcessor

### 6.6.2 注册BeanPostProcessor

### 6.6.3 初始化消息资源

### 6.6.4 初始化ApplicationEvent Multicaster

### 6.6.5 注册监听器

## 6.7 初始化非延迟加载单例

## 6.8 finishRefresh

# 7 AOP

## 7.1 动态AOP使用示例

## 7.2 动态AOP自定义标签

### 7.2.1 注册AnnotationAwareAspectJ AutoProxyCreator

## 7.3 创建AOP代理

### 7.3.1 获取增强器

### 7.3.2 寻找批评日的增强器

### 7.3.3 创建代理

## 7.4 静态AOP使用示例

## 7.5 创建AOP静态代理

### 7.5.1 Instrumentation 使用

### 7.5.2 自定义标签

### 7.5.3 织入


\# 2 企业应用
# 8 数据库连接JDBC

## 8.1 Spring 链接数据库程序实现（JDBC）

## 8.2 save/update 功能的实现

### 8.2.1 基础方法execute

### 8.2.2 Update中的回调函数

## 8.3 query功能的实现

## 8.4 queryForObject

# 9 整合MyBatis

## 9.1 Mybatis独立使用

## 9.2 Spring 整合MyBatis

## 9.3 源码分析

### 9.3.1 sqlSessionFactory创建

### 9.3.2 MapperFactoryBean的创建

### 9.3.3 MapperScannerConfigurer

# 10 事务

## 10.1 JDBC方式下的食物使用示例

## 10.2 事务自定义标签

### 10.2.1 注册InfrastructureAdvisor

### 10.2.2 获取对应class/method的增强器

## 10.3 事务增强器

### 10.3.1 创建事务

### 10.3.2 回滚处理

### 10.3.3 事务提交

# 11 Spring MVC

## 11.1 SpringMVC快速体验

## 11.2 ContextLoaderListener

### 11.2.1 ServletContextListener

### 11.2.2 Spring 中的ContextLoader Listener

## 11.3 DispatcherServlet

### 11.3.1 servlet的使用

### 11.3.2 DispatcherServlet 的初始化

### 11.3.3 web ApplicationContext的初始化

## 11.4 DispatcherServlet的逻辑处理

### 11.4.1 MultipartContent类型的request处理

### 11.4.2 根据request信息寻找对应的Handler

### 11.4.3 没找到对应的Handler的错误处理

### 11.4.4 根据当前Handler寻找对应的HandlerAdapter

### 11.4.5 缓存处理

### 11.4.6 HandlerInterceptor的处理

### 11.4.7 逻辑处理

### 11.4.8 异常视图的处理

### 11.4.9 根据试图跳转页面

# 12 远程服务

## 12.1 RMI

### 12.1.1 使用示例

### 12.1.2 服务端实现

### 12.1.3 客户端实现

# 13 Spring消息

## 13.1 JMS的独立使用

## 13.2 Spring整合ActiveMQ

## 13.3 源码分析

### 13.3.1 JmsTemplate

### 13.3.2 监听器容器



