# 1 了解SQL
## 1.1 数据库基础
### 1.1.1 数据库
### 1.1.2 表
### 1.1.3 列和数据类型
### 1.1.4 行
### 1.1.5 主键  
>一列或者一组列，能够唯一标识表中每一行
>表中每一列都可以作为主键，只要他们满足一下条件:
>>任意两行都不具有相同的主键值
>>每一行都必须具有一个主键值（主键列不允许NULL值）
>>主键列中的值不允许修改或更新
>>主键值不能重用（如果某行从表中删除，他的主键不能赋给以后的新行）
\# 多个列作为主键的时候，单个列是可以重复的
### 1.1.6 外键

## 1.2 什么是SQL
SQL 有如下优点：
>SQL不是某个特定数据库供应商专有的语言。几乎所有重要的DBMS都支持SQL，所以学习此语言使你几乎能与所有数据库打交道。
>SQL简单易学。它的语句全都是由有很强描述性的英语单词组成，而且这些单词的数目不多。
>SQL虽然看上去很简单，但实际上是一种强有力的语言，灵活使用其语言元素，可以进行非常复杂和高级的数据库操作。

\# 标准SQL由ANSI标准委员会管理，从而称为ANSI SQL。所有主要的DBMS，即使有自己的扩展，也都支持ANSI SQL。各个实现有自己的名称，如PL/SQL、Transact-SQL 等。

## 1.3 动手实践
## 1.4 小结

# 2 检索数据
## 2.1 Select 语句
>keyword 
>作为SQL组成部分的保留字。关键字不能用作表或列的名字

## 2.2 检索单个列
```
select column_name form table;
```
\#语句结尾分号可加可不加，但是加了一定没有坏处
\#关于大小写： SQL语句是不区分大小写的，通常对SQL语句采用大写，对列名和表名采用小写。不过列名和表名可能区分大小写，这取决于DBMS的具体配置。
\#关于空格:所有的空格都会被忽略。SQL语句可以写成一行或者多行。多数开发者认为将SQL语句分成多行更容易阅读和调试。

## 2.3 检索多个列
```
SELECT prod_id,prod_name,prod_price
FROM Products;
```

## 2.4 检索所有列
```
SELECT *
FROM Products;
```
>Warning:不建议使用通配符\*,应为这会降低程序的性能

## 2.5 检索不同的值
返回所有的值（包含相同的值）：
```
SELECT vend_id
FROM Products;
```
返回所有的值（不包含相同的值）
```
SELECT DISTINCT vend_id
FROM Products;
```
\# Warning: 不能部分使用DISTINCT，除非指定的列完全相同，否则所有的行都会被检索出来

## 2.6 限制结果
> SQL Server Access
```
SELECT TOP 5 prod_name
FROM Products;
```

>DB2
```
SELECT　prod_name
FROM Products
FETCH FIRST 5 ROWS ONLY;
```

>MySQL\MariaDB\PostgreSQL\SQLite
```
SELECT prod_name
FROM Products
LIMIT 5;
```
```
SELECT prod_name
FROM Products
LIMIT 5 OFFSET 5;
```
\# Warning: 第一个被检索的是第0行，而不是第1行
\# Tips: MySQL和MariaDB支持简化版的LIMIT，LIMIT 4 OFFSET 等价于 LIMIT 3,4
\# Description: 并非所有的SQL实现都一样，所以基本语句是最容易移植的

## 2.7 使用注释
```
SELECT prod_name -- 这是一条注释
FROM Products;
```
```
# 这是一条注释
SELECT prod_name
FROM Products;
```
```
/* SELECT prod_name, vend_id
FROM Products; */
SELECT prod_name
FROM Products;
```
