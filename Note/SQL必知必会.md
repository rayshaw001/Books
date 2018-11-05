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
\# 一般来说从数据库检索出来的数据并不是应用程序所需要的。

>字段（Field）意思基本与列（Column）相同

\# 提示：客户端与服务器的格式
\#在SQL语句内可完成的许多转换和格式化工作都可以直接在客户端应用程序内完成。但一般来说，在数据库服务器上完成这些操作比在客户
端中完成要快得多。

## 7.2 拼接字段
>拼接 将值联结到一起构成单个值
>>+或||，在MySQL和MariaDB中，必须使用特殊函数
```
#使用+
SELECT vend_name + ' (' + vend_country + ')'
FROM Vendors
ORDER BY vend_name;
#使用||
SELECT vend_name || ' (' || vend_country || ')'
FROM Vendors
ORDER BY vend_name;
```

\# Note 使用RTRIM()函数删除空格，RTRIM()只保证删除右侧空格
>TRIM函数
>>RTRIM()删除右侧空格

>>LTRIM()删除左侧空格

>>TRIM()删除左右两侧空格

```
# 使用别名
SELECT RTRIM(vend_name) + ' (' + RTRIM(vend_country) + ')'
AS vend_title
FROM Vendors
ORDER BY vend_name;
```

\# AS 通常可选，不过最好使用它，这被视为一条最佳实践
\# 别名还可以用来扩充原来的名字
\# 别名也称导出列

## 7.3 执行算术运算
```
SELECT prod_id,
quantity,
item_price,
quantity*item_price AS expanded_price
FROM OrderItems
WHERE order_num = 20008;
```
|操作符|说明|
|-----|----|
|+|加|
|-|减|
|\*|乘|
|/|除|

\# Tips SELECT 语句为测试、检验函数和计算提供了很好的方法，例如：SELECT 3\*2; SELECT Trim(' abc'); SELECT Now(); 

# 8 使用数据处理函数
## 8.1 函数
> 不同的DBMS对各个函数的名称和语法可能极其不同

|函数|语法|
|---|----|
|提取字符串的组成部分|Access使用MD();DB2、Oracle、PostgreSQL和SQLite使用SUBSTR()；MySQL和SQL Server使用SUBSTRING()|
|数据类型转换|Access和Oracle使用多个函数，每种类型的转换有一个函数；DB2和PostgreSQL使用CAST()；MariaDB、MySQL和SQL Server使用CONVERT()|
|取当前日期|Access使用NOW()；DB2和PostgreSQL使用CURRENT_DATE；MariaDB和MySQL使用CURDATE()；Oracle使用SYSDATE；SQL Server使用GETDATE()；SQLite使用DATE()|

## 8.2使用函数
> 大多数SQL实现支持一下类型的函数

>>用于处理文本字符串（如删除或填充值，转换值为大写或小写）的文本函数。

>>用于在数值数据上进行算术操作（如返回绝对值，进行代数运算）的数值函数。

>>用于处理日期和时间值并从这些值中提取特定成分（如返回两个日期之差，检查日期有效性）的日期和时间函数。

>>返回DBMS正使用的特殊信息（如返回用户登录信息）的系统函数。

### 8.2.1 文本处理函数
```
SELECT vend_name, UPPER(vend_name) AS vend_name_upcase
FROM Vendors
ORDER BY vend_name;
```

\# 常用的文本处理函数

|函　　数|说　　明|
|-------|-------|
|LEFT()（或使用子字符串函数） |返回字符串左边的字符|
|LENGTH()（也使用DATALENGTH()或LEN()）| 返回字符串的长度|
|LOWER()（Access使用LCASE()）| 将字符串转换为小写|
|LTRIM() |去掉字符串左边的空格|
|RIGHT()（或使用子字符串函数）| 返回字符串右边的字符|
|RTRIM() |去掉字符串右边的空格|
|SOUNDEX() |返回字符串的SOUNDEX值|
|UPPER()（Access使用UCASE()）| 将字符串转换为大写|

\# SOUNDEX() 考虑的是类似发音字符和音节，使得能对字符串进行发音比较而不是字母比较

\# Note: Access 和PostgreSQL不支持SOUNDEX，SQLite需要启用SQLITE_SOUNDEX编译选项

```
#Michael Green 和 Michelle Green 发音类似，所以能检索出 Michelle Green
SELECT cust_name, cust_contact
FROM Customers
WHERE SOUNDEX(cust_contact) = SOUNDEX('Michael Green');
```

### 8.2.2 日期和时间处理函数
```
# SQL Server
SELECT order_num
FROM Orders
WHERE DATEPART(yy, order_date) = 2012;

# Access
SELECT order_num
FROM Orders
WHERE DATEPART('yyyy', order_date) = 2012;

# PostgreSQL
SELECT order_num
FROM Orders
WHERE DATEPART('yyyy', order_date) = 2012;

# Oracle
SELECT order_num
FROM Orders
WHERE to_number(to_char(order_date, 'YYYY')) = 2012;

# 相对通用的方法，不支持SQL Serer，因为它不支持to_date()函数
SELECT order_num
FROM Orders
WHERE order_date BETWEEN to_date('01-01-2012')
AND to_date('12-31-2012');

# MySQL和MariaDB
SELECT order_num
FROM Orders
WHERE YEAR(order_date) = 2012;

# SQLite
SELECT order_num
FROM Orders
WHERE strftime('%Y', order_date) = 2012;
```

### 8.2.3 数值处理函数

> 在主要数据库中，数值处理函数是最为统一、一致的

|函  数|  说 明 |
|-----|--------|
|ABS()|绝对值|
|COS()|余弦|
|EXP()|指数|
|PI()|圆周率|
|SIN()|正弦|
|SQRT()|平方根|
|TAN|正切|

# 9 汇总数据

## 9.1 聚集函数

>用途

>>确定表中行数（或者满足某个条件或包含某个特定值的行数）；

>>获得表中某些行的和；

>>找出表列（或所有行或某些特定的行）的最大值、最小值、平均值。

\# 聚集函数：对某些行运行的函数，计算一个返回值

|函数|说明|其他|
|----|---|----|
|AVG()|平均值|AVG()函数忽略列值为NULL的行|
|COUNT()|行数|指定列名的时候会忽略NULL，而COUNT(\*)不会忽略NULL|
|MAX()|最大值|MAX()函数忽略列值为NULL的行。参数为文本数据时，返回该排列的最后一行|
|MIN()|最小值|MIN()函数忽略列值为NULL的行。参数为文本数据时，返回该排列的最前面一行|
|SUM()|列值之和|SUM()函数忽略列值为NULL的行|

## 9.2 聚集不同的值
>对所有行执行计算，指定ALL参数或不指定参数（因为ALL是默认行为）。

> 只包含不同的值，指定DISTINCT

\# Access在聚集函数中不支持DISTINCT。要在Access得到类似的结果，需要使用子查询把DISTINCT数据返回到外部SELECT COUNT(\*)语句。

\# DISTINCT 只能用于COUNT(),不能用于COUNT(\*)
```
SELECT AVG(DISTINCT prod_price) AS avg_price    # 不要在Access中这样使用
FROM Products
WHERE vend_id = 'DLL01';
```

## 9.3 组合聚集函数
```
SELECT COUNT(*) AS num_items,
MIN(prod_price) AS price_min,
MAX(prod_price) AS price_max,
AVG(prod_price) AS price_avg
FROM Products;
```
\# 别名最好不要取表中的列名

# 10 分组数据
> GROUP、HAVING子句

## 10.1 分组数据
```
SELECT COUNT(*) AS num_prods
FROM Products
WHERE vend_id = 'DLL01';
```
>如果要对多个vend_id统计总数，考虑一下方案

## 10.2 创建分组
```
SELECT vend_id, COUNT(*) AS num_prods
FROM Products
GROUP BY vend_id;
```

>在使用GROUP BY子句前，需要知道一些重要的规定。

>>GROUP BY子句可以包含任意数目的列，因而可以对分组进行嵌套，更细致地进行数据分组。

>>如果在GROUP BY子句中嵌套了分组，数据将在最后指定的分组上进行汇总。换句话说，在建立分组时，指定的所有列都一起计算（所以不能从个别的列取回数据）。

>>GROUP BY子句中列出的每一列都必须是检索列或有效的表达式（但不能是聚集函数）。如果在SELECT中使用表达式，则必须在GROUP BY子句中指定相同的表达式。不能使用别名。

>>大多数SQL实现不允许GROUP BY列带有长度可变的数据类型（如文本或备注型字段）。

>>除聚集计算语句外，SELECT语句中的每一列都必须在GROUP BY子句中给出。

>>如果分组列中包含具有NULL值的行，则NULL将作为一个分组返回。如果列中有多行NULL值，它们将分为一组。

>>GROUP BY子句必须出现在WHERE子句之后，ORDER BY子句之前。


## 10.3 分组过滤
\# WHERE没有分组概念

\# TIPS: HAVING 支持所有的WHERE操作符

```
SELECT cust_id, COUNT(*) AS orders
FROM Orders
GROUP BY cust_id
HAVING COUNT(*) >= 2;
```

>HAVING 和 WHERE的差别：
>>WHERE在数据分组前进行过滤，HAVING在数据分组后进行过滤。被WHERE过滤的数据不会出现在分组之中

>>使用HAVING时应该结合GROUP BY子句，而WHERE子句用于标准的行级过滤。

## 10.4 分组和排序
| ORDER BY  |   GROUP BY    |
|   ---     |       ---     |
|对产生的输出排序|对行分组，但输出可能不是分组的顺序|
|任意列都可以使用(非选择列也可以)|只可能使用选择列或表达式列，而且必须使用每个选择列表达式|
|不一定需要|如果与聚集函数一起使用列（或表达式），则必须使用|

\# 分组之后不要依赖GROUP BY排序数据，一般在使用GROUP BY之后也应该使用ORDER BY 排序

```
SELECT order_num, COUNT(*) AS items
FROM OrderItems
GROUP BY order_num
HAVING COUNT(*) >= 3
ORDER BY items, order_num;
```

## 10.5 SELECT 子句顺序

|子　　句|说　　明|是否必须使用|
|-------|--------|----------|
|SELECT| 要返回的列或表达式|是|
|FROM|从中检索数据的表|仅在从表选择数据时使用|
|WHERE|行级过滤|否|
|GROUP BY|分组说明|仅在按组计算聚集时使用|
|HAVING|组级过滤|否|
|ORDER BY|输出排序顺序|否|

# 11 使用子查询

## 11.1 子查询
\# MySQL 从v4.1起引入子查询

## 11.2 利用子查询进行过滤

```
SELECT cust_name, cust_contact
FROM Customers
WHERE cust_id IN (SELECT cust_id
                  FROM Order
                  WHERE order_num IN (SELECT order_num
                                      FROM OrderItems
                                      WHERE prod_id = 'RGAN01'));
```

\# Warning:
1. 对嵌套子查询的数目没有限制，但出于性能考虑，不能嵌套太多子查询
2. 子查询的SELECT语句只能是单个列，SELECT多个列将返回错误
3. 子查询并不是检索这类数据的最佳方法，参见chapter 12

## 11.3 作为计算字段使用子查询
```
#统计每个顾客的order数量
SELECT cust_name,
cust_state,
(SELECT COUNT(*)
FROM Orders
WHERE Orders.cust_id = Customers.cust_id) AS orders
FROM Customers
ORDER BY cust_name;
```

\# Warning:
1. 建议完全限定列名
2. 不止子查询这一种解决方案，后面的JOIN也很有用

## 12 联结表














