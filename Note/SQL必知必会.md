# 1 了解SQL
## 1.1 数据库基础
### 1.1.1 数据库
### 1.1.2 表
### 1.1.3 列和数据类型
### 1.1.4 行
### 1.1.5 主键  
>一列或者一组列，能够唯一标识表中每一行
>
>表中每一列都可以作为主键，只要他们满足一下条件:
>>任意两行都不具有相同的主键值
>>
>>每一行都必须具有一个主键值（主键列不允许NULL值）
>>
>>主键列中的值不允许修改或更新
>>
>>主键值不能重用（如果某行从表中删除，他的主键不能赋给以后的新行）

\# 多个列作为主键的时候，单个列是可以重复的

### 1.1.6 外键

## 1.2 什么是SQL
SQL 有如下优点：
>SQL不是某个特定数据库供应商专有的语言。几乎所有重要的DBMS都支持SQL，所以学习此语言使你几乎能与所有数据库打交道。
>
>SQL简单易学。它的语句全都是由有很强描述性的英语单词组成，而且这些单词的数目不多。
>
>SQL虽然看上去很简单，但实际上是一种强有力的语言，灵活使用其语言元素，可以进行非常复杂和高级的数据库操作。

\# 标准SQL由ANSI标准委员会管理，从而称为ANSI SQL。所有主要的DBMS，即使有自己的扩展，也都支持ANSI SQL。各个实现有自己的名称，如PL/SQL、Transact-SQL 等。

## 1.3 动手实践
## 1.4 小结

# 2 检索数据
## 2.1 Select 语句
>keyword 
>
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

# 3 排序检索数据
> 本章讲述如何使用SELECT语句的ORDER BY子句，根据需要排序检索出的数据

## 3.1
```
SELECT prod_name
FROM Products
ORDER BY prod_name; 
```
\# 要保证ORDER BY 子句是SELECT语句中的最后一句

\# 通常ORDER BY子句中使用的列是为显示而选择的列。但实际上使用非检索的列也是合法的。

## 3.2 按多个列排序
```
SELECT prod_id, prod_price, prod_name
FROM Products
ORDER BY prod_price, prod_name; 
```
\# 当且仅当prod_price的值重复的时候，才会按照prod_name排序。如果prod_price是不重复的，则不会按prod_name排序

## 3.3 按列位置排序
```
SELECT prod_id, prod_price, prod_name
FROM Products
ORDER BY 2, 3;
```
>表示按照选择列的相对位置排序，上面的示例是首先按照prod_price，其次按照prod_name排序。

\#  按列位置排序的时候，不能选定没有出现在SELECT清单中的列进行排序时。但是，如果有必要，可以混合匹配使用实际列名和相对列位置。

## 3.4 指定排序方向
```
SELECT prod_id, prod_price, prod_name
FROM Products
ORDER BY prod_price DESC; 
```
> ORDER BY 默认是升序的，如果需要降序排列，需要指定DESC（或DESCENDING）

> 需要说明的是，DESC/ASC只作用于单个列，如果多个列需要降序排列，则每个列都需要显式指定DESC

> 排序时是否区分大小写取决于数据库的设置，大多数数据库默认不区分大小写，如果确实需要区分大小写，简单的ORDER BY是做不到的

# 4 过滤数据
> SELECT、WHERE

## 4.1 使用WHERE子句
```
SELECT prod_name, prod_price
FROM Products
WHERE prod_price = 3.49;
```
\# Note 尽量在数据库过滤数据，客户端处理数据消耗性能，且浪费带宽
\# 同时使用ORDER BY和WHERE子句的时候，应该将ORDER BY置于WHERE子句之后

## 4.2 WHERE子句操作符
|操作符|说明|
|-----|----|
|=|等于|
|<>|不等于|
|!=|不等于|
|<|小于|
|<=|小于等于|
|!|不小于|
|>|大于|
|>=|大于等于|
|!>|不大于|
|BETWEEN|在指定的两个值之间|
|IS NULL|为NULL值|

\# Warning 并非所有DBMS都支持这些操作符。某些操作符是冗余的，比如<>与!=，!<与>=

### 4.2.1 检查单个值
```
SELECT prod_name, prod_price
FROM Products
WHERE prod_price < 10;
```

### 4.2.2 不匹配检查
```
SELECT vend_id, prod_name
FROM Products
WHERE vend_id <> 'DLL01';
```
\# 何时使用引号：字符串需要使用引号，数值则不需要引号

### 4.2.3 范围值检查
```
SELECT prod_name, prod_price
FROM Products
WHERE prod_price BETWEEN 5 AND 10;
```

### 4.2.4 空值检查
```
SELECT cust_name
FROM CUSTOMERS
WHERE cust_email IS NULL;
```
>NULL与字段包含0、空字符串或仅仅包含空格不同。

\# Warning: NULL和不匹配，通过过滤选择不包含某个值的时候，你可能希望返回包含NULL的行，但是这做不到，因为数据库不知道它们是否匹配

# 5 高级数据过滤

## 5.1 组合WHERE子句
> 操作符，用来连接或改变WHERE子句中的子句关键字，也叫逻辑操作符

### 5.1.1 AND操作符
通过不止一个列来过滤，使用AND 操作符
```
SELECT prod_id, prod_price, prod_name
FROM Products
WHERE vend_id = 'DLL01' AND prod_price <= 4;
```

### 5.1.2 OR操作符
```
SELECT prod_name, prod_price
FROM Products
WHERE vend_id = 'DLL01' OR vend_id = ‘BRS01’;
```

### 5.1.3 求值顺序
```
SELECT prod_name, prod_price
FROM Products
WHERE vend_id = 'DLL01' OR vend_id = ‘BRS01’
AND prod_price >= 10;
```
>应当使用圆括号消除歧义
```
SELECT prod_name, prod_price
FROM Products
WHERE (vend_id = 'DLL01' OR vend_id = ‘BRS01’)
AND prod_price >= 10;
```
\# Tips:任何时候使用具有AND和OR操作符的WHERE子句，都应该使用圆括号明确地分组操作符。不要过分依赖默认求值顺序，即使它确实如你希望的那样。使用圆括号没有什么坏处，它能消除歧义。

## 5.2 IN 操作符
>WHERE子句中用来指定要匹配值的清单的关键字，功能与OR相当。
```
SELECT prod_name, prod_price
FROM Products
WHERE vend_id IN ( 'DLL01', 'BRS01' )
ORDER BY prod_name;
```

\# 优点：
>在有很多合法选项时，IN操作符的语法更清楚，更直观。

>在与其他AND和OR操作符组合使用IN时，求值顺序更容易管理。

>IN操作符一般比一组OR操作符执行得更快（在上面这个合法选项很少的例子中，你看不出性能差异）。

>IN的最大优点是可以包含其他SELECT语句，能够更动态地建立WHERE子句。第11课会对此进行详细介绍。

5.3 NOT 操作符
>说明：MariaDB中的NOT
>MariaDB支持使用NOT否定IN、BETWEEN和EXISTS子句。大多数DBMS允许使用NOT否定任何条件。
```
SELECT prod_name
FROM Products
WHERE vend_id <> 'DLL01'
ORDER BY prod_name;
```

# 6 使用通配符进行过滤

## 6.1 LIKE操作符

>通配符（wildcard）
>>用来匹配值的一部分的特殊字符。

>搜索模式（search pattern）
>>由字面值、通配符或两者组合构成的搜索条件。

\# Note 通配符本身实际上是SQL的WHERE子句中有特殊含义的字符，SQL支持几种通配符。为在搜索子句中使用通配符，必须使用*LIKE*操作符。LIKE指
示DBMS，后跟的搜索模式利用通配符匹配而不是简单的相等匹配进行比较。

>谓词（predicate）
>>操作符何时不是操作符？答案是，它作为谓词时。从技术上说，LIKE是谓词而不是操作符。

### 6.1.1 百分号 （%） 通配符
>百分号表示任何字符出现任意次数（包括0次出现）
```
SELECT prod_id, prod_name
FROM Products
WHERE prod_name LIKE 'Fish%';
```

\# Access使用的等价通配符是\*而不是%
\# Warning: 通配符% 不会匹配NULL

### 6.1.2 下划线（_）通配符
\_只匹配一个任意字符

>DB2不支持通配符_

>Access使用?而不是_
```
SELECT prod_id, prod_name
FROM Products
WHERE prod_name LIKE '__ inch teddy bear';
```
### 6.1.3 方括号([])通配符
>方括号用来指定一个字符集，必须匹配指定位置的一个字符
\# 目前只有SQL Server和Access支持
```
SELECT cust_contact
FROM Customers
WHERE cust_contact LIKE '[^JM]%'
ORDER BY cust_contact;
```
\# 采用^来否定，Access中采用!来否定，而不是^

## 6.2 使用通配符的技巧

>不要过度使用通配符。如果其他操作符能达到相同的目的，应该使用其他操作符。

>在确实需要使用通配符时，也尽量不要把它们用在搜索模式的开始处。把通配符置于开始处，搜索起来是最慢的。

>仔细注意通配符的位置。如果放错地方，可能不会返回想要的数据。

# 7 创建计算字段

## 7.1 计算字段










