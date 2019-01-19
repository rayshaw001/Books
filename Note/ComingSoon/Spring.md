# Spring整体架构和环境搭建
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

# 容器的基本实现
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

