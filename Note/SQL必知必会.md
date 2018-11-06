# 0 Basic
>**Atomicity（原子性）：**一个事务（transaction）中的所有操作，要么全部完成，要么全部不完成，不会结束在中间某个环节。事务在执行过程中发生错误，会被恢复（Rollback）到事务开始前的状态，就像这个事务从来没有执行过一样。
>
>**Consistency（一致性）：**在事务开始之前和事务结束以后，数据库的完整性没有被破坏。这表示写入的资料必须完全符合所有的预设规则，这包含资料的精确度、串联性以及后续数据库可以自发性地完成预定的工作。
>
>**Isolation（隔离性）：**数据库允许多个并发事务同时对其数据进行读写和修改的能力，隔离性可以防止多个事务并发执行时由于交叉执行而导致数据的不一致。事务隔离分为不同级别，包括读未提交（Read uncommitted）、读提交（read committed）、可重复读（repeatable read）和串行化（Serializable）。
>
>**Durability（持久性）：**事务处理结束后，对数据的修改就是永久的，即便系统故障也不会丢失。

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
>
> 需要说明的是，DESC/ASC只作用于单个列，如果多个列需要降序排列，则每个列都需要显式指定DESC
>
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

>优点：
>>在有很多合法选项时，IN操作符的语法更清楚，更直观。
>>
>>在与其他AND和OR操作符组合使用IN时，求值顺序更容易管理。
>>
>>IN操作符一般比一组OR操作符执行得更快（在上面这个合法选项很少的例子中，你看不出性能差异）。
>>
>>IN的最大优点是可以包含其他SELECT语句，能够更动态地建立WHERE子句。第11课会对此进行详细介绍。

5.3 NOT 操作符
>说明：MariaDB中的NOT
>
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
>
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
>\_只匹配一个任意字符
>
>DB2不支持通配符_
>
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
>
>在确实需要使用通配符时，也尽量不要把它们用在搜索模式的开始处。把通配符置于开始处，搜索起来是最慢的。
>
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
>>
>>LTRIM()删除左侧空格
>>
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
>>
>>用于在数值数据上进行算术操作（如返回绝对值，进行代数运算）的数值函数。
>>
>>用于处理日期和时间值并从这些值中提取特定成分（如返回两个日期之差，检查日期有效性）的日期和时间函数。
>>
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
>>
>>获得表中某些行的和；
>>
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
>
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
>>
>>如果在GROUP BY子句中嵌套了分组，数据将在最后指定的分组上进行汇总。换句话说，在建立分组时，指定的所有列都一起计算（所以不能从个别的列取回数据）。
>>
>>GROUP BY子句中列出的每一列都必须是检索列或有效的表达式（但不能是聚集函数）。如果在SELECT中使用表达式，则必须在GROUP BY子句中指定相同的表达式。不能使用别名。
>>
>>大多数SQL实现不允许GROUP BY列带有长度可变的数据类型（如文本或备注型字段）。
>>
>>除聚集计算语句外，SELECT语句中的每一列都必须在GROUP BY子句中给出。
>>
>>如果分组列中包含具有NULL值的行，则NULL将作为一个分组返回。如果列中有多行NULL值，它们将分为一组。
>>
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
>>
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

# 12 联结表

## 12.1 联结
>联结是利用SQL的SELECT能执行的最重要的操作，很好地理解联结及其语法是学习SQL的极为重要的部分。

### 12.1.1 关系表
>可伸缩（scale）: 能够适应不断增加的工作量而不失败。设计良好的数据库或应用程序称为可伸缩性好（scale well）

### 12.1.2 为什么使用联结
>联结是一种机制，用来在一条SELECT语句中关联表，因此称为联结。

## 12.2 创建联结
```
SELECT vend_name, prod_name, prod_price
FROM Vendors, Products
WHERE Vendors.vend_id = Products.vend_id;
```
\# 记得完全限定表名

### 12.2.1 WHERE子句的重要性
>**笛卡尔积**
>
>由没有联结条件的表关系返回的结果为笛卡儿积。检索出的行的数目将是第一个表中的行数乘以第二个表中的行数。

```
SELECT vend_name, prod_name, prod_price
FROM Vendors, Products;
# 返回笛卡尔积
```

### 12.2.2 内联结
```
SELECT vend_name, prod_name, prod_price
FROM Vendors INNER JOIN Products
ON Vendors.vend_id = Products.vend_id;
```
\# ANSI SQL规范首选INNER JOIN语法

### 12.2.3 联结多个表
```
SELECT prod_name, vend_name, prod_price, quantity
FROM OrderItems, Products, Vendors
WHERE Products.vend_id = Vendors.vend_id
AND OrderItems.prod_id = Products.prod_id
AND order_num = 20007;
```

> **Warning：**
>>不要联结不必要的表，联结的表越多，性能下降的越厉害
>>
>>实际上许多DBMS都有限制每个联结约束中表的数目

```
#使用子查询
SELECT cust_name, cust_contact
FROM Customers
WHERE cust_id IN (SELECT cust_id
FROM Orders
WHERE order_num IN (SELECT order_num
FROM OrderItems
WHERE prod_id = 'RGAN01'));

#使用联结查询
SELECT cust_name, cust_contact
FROM Customers, Orders, OrderItems
WHERE Customers.cust_id = Orders.cust_id
AND OrderItems.order_num = Orders.order_num
AND prod_id = 'RGAN01';
```

\# Note:  ，执行任一给定的SQL操作一般不止一种方法。很少有绝对正确或绝对错误的方法。性能可能会受操作类型、所使用的DBMS、表中数据量、是否存在索引或键等条件的影响。因此，有必要试验不同的选择机制，找出最适合具体情况的方法。

# 13 创建高级联结
## 13.1 使用表别名
```
#使用别名
SELECT cust_name, cust_contact
FROM Customers AS C, Orders AS O, OrderItems AS OI
WHERE C.cust_id = O.cust_id
AND OI.order_num = O.order_num
AND prod_id = 'RGAN01';
```

\# **Warning:** Oracle 不支持AS关键字，简单指定列名即可（应该使用Customers C，而不是Customers AS C）

## 13.2 使用不同类型的联结
>不同类型的**联结**
>> **内联结**  条件可以是不等
>> **等值联结** 条件必须是相等，可以看做内联结的子集
>> **自连接** 
>> **自然联结** 每个内联结都是自然联结
>> **外联结**

### 13.2.1 自联结
```
# 子查询
SELECT cust_id, cust_name, cust_contact
FROM Customers
WHERE cust_name = (SELECT cust_name
                  FROM Customers
                  WHERE cust_contact = 'Jim Jones');
# 自联结
SELECT c1.cust_id, c1.cust_name, c1.cust_contact
FROM Customers AS c1, Customers AS c2
WHERE c1.cust_name = c2.cust_name
AND c2.cust_contact = 'Jim Jones';
```

### 13.2.2 自然联结
>无论何时对表进行联结，应该至少有一列不止出现在一个表中（被联结的列）。标准的联结（前一课中介绍的内联结）返回所有数据，相同的列甚至多次出现。自然联结排除多次出现，使每一列只返回一次。
>
>系统不会完成这项工作，一般由自己手动完成（对一个表使用通配符SELECT \*，而对其他表的列使用明确的子集来完成）

```
# Example
SELECT C.*, O.order_num, O.order_date,
OI.prod_id, OI.quantity, OI.item_price
FROM Customers AS C, Orders AS O, OrderItems AS OI
WHERE C.cust_id = O.cust_id
AND OI.order_num = O.order_num
AND prod_id = 'RGAN01';
```

\# Note : Oracle中没有AS

### 13.2.3 外联结
#### 13.2.3.1 左外联结
```
SELECT Customers.cust_id, Orders.order_num
FROM Customers LEFT OUTER JOIN Orders
ON Customers.cust_id = Orders.cust_id;

#以左表为准，右侧不存的值的时候用NULL补足，右外联结、全外联结同理
```

#### 13.2.3.2 右外联结
```
SELECT Customers.cust_id, Orders.order_num
FROM Customers RIGHT OUTER JOIN Orders
ON Orders.cust_id = Customers.cust_id;
```
\# 可以转化成左外联结

\# SQLite 不支持RIGHT OUTER JOIN ,因为左、右外联结可以相互转换
#### 13.2.3.3 全外联结
```
SELECT Customers.cust_id, Orders.order_num
FROM Orders FULL OUTER JOIN Customers
ON Orders.cust_id = Customers.cust_id;
```

\# **Warning:** Access、MariaDB、MySQL、Open Office Base 或SQLite不支持FULL OUTER JOIN语法

## 13.3 使用带聚集函数的联结
```
SELECT Customers.cust_id,
COUNT(Orders.order_num) AS num_ord
FROM Customers INNER JOIN Orders
ON Customers.cust_id = Orders.cust_id
GROUP BY Customers.cust_id;
```



## 13.4 使用联结和联结条件
>注意所使用的联结类型。一般我们使用内联结，但使用外联结也有效。
>
>关于确切的联结语法，应该查看具体的文档，看相应的DBMS支持何种语法（大多数DBMS使用这两课中描述的某种语法）。
>
>保证使用正确的联结条件（不管采用哪种语法），否则会返回不正确的数据。
>
>应该总是提供联结条件，否则会得出笛卡儿积。
>
>在一个联结中可以包含多个表，甚至可以对每个联结采用不同的联结类型。虽然这样做是合法的，一般也很有用，但应该在一起测试它们前分别测试每个联结。这会使故障排除更为简单。

# 14 组合查询
>如何利用UNION操作符将多条SELECT语句组合成一个结果集?

## 14.1 组合查询
>主要有两种情况需要使用组合查询：
>>在一个查询中从不同的表返回结构数据；
>>
>>对一个表执行多个查询，按一个查询返回数据。

## 14.2 创建组合查询

### 14.2.1 使用UNION
```
# 使用UNION
SELECT cust_name, cust_contact, cust_email
FROM Customers
WHERE cust_state IN ('IL','IN','MI')
UNION
SELECT cust_name, cust_contact, cust_email
FROM Customers
WHERE cust_name = 'Fun4All';

#使用OR
SELECT cust_name, cust_contact, cust_email
FROM Customers
WHERE cust_state IN ('IL','IN','MI')
OR cust_name = 'Fun4All';
```
\# Tips:使用UNION组合SELECT语句的数目，SQL没有标准限制。但是，最好是参考一下具体的DBMS文档，了解它是否对UNION能组合的最大语句数目有限制。

\# **Warning:** 多数好的DBMS使用内部查询优化程序，在处理各条SELECT语句前组合它们。理论上讲，这意味着从性能上看使用多条WHERE子句条件还
是UNION应该没有实际的差别。不过我说的是理论上，实践中多数查询优化程序并不能达到理想状态，所以最好测试一下这两种方法，看哪
种工作得更好。

### 14.2.2 UNION规则
>在进行组合时需要注意几条规则。
>>UNION必须由两条或两条以上的SELECT语句组成，语句之间用关键字UNION分隔（因此，如果组合四条SELECT语句，将要使用三个UNION关键字）。
>>
>>UNION中的每个查询必须包含相同的列、表达式或聚集函数（不过，各个列不需要以相同的次序列出）。
>>
>>列数据类型必须兼容：类型不必完全相同，但必须是DBMS可以隐含转换的类型（例如，不同的数值类型或不同的日期类型）。

### 14.2.3 包含或取消重复的行
>使用UNION时，重复的行会被自动取消，这是默认行为，如果想返回所有行，可以使用UNION ALL.
```
#Example
SELECT cust_name, cust_contact, cust_email
FROM Customers
WHERE cust_state IN ('IL','IN','MI')
UNION ALL
SELECT cust_name, cust_contact, cust_email
FROM Customers
WHERE cust_name = 'Fun4All';
```
> Tips: UNION 与 WHERE
>>UNION几乎与WHERE完成相同的工作
>>
>>但是UNION ALL能匹配全部出现的行（包括重复的行，而WHERE不能）

### 14.2.4 对组合查询结果排序
>SELECT语句的输出用ORDER BY子句排序。在用UNION组合查询时，只能使用一条ORDER BY子句，它必须位于最后一条SELECT语句之后。对于结果集，不存在用一种方式排序一部分，而又用另一种方式排序另一部分的情况，因此不允许使用多条ORDER BY子句。
```
SELECT cust_name, cust_contact, cust_email
FROM Customers
WHERE cust_state IN ('IL','IN','MI')
UNION
SELECT cust_name, cust_contact, cust_email
FROM Customers
WHERE cust_name = 'Fun4All'
ORDER BY cust_name, cust_contact;
```

> 说明：其他类型的UNION
>>EXCEPT(MINUS)检索只存在第一个表中的行
>>
>>INTERSECT 检索两个表中都存在的行
>>
>>以上两种UNION很少用到，因为这些结果可以利用联结得到
>操作多个表
>>将UNION与别名组合，保证UNION的规则即可

# 15 插入数据

## 15.1 插入数据
>INSERT用来将行插入（或添加）到数据库表。插入有几种方式：
>>
>>插入完整的行；
>>
>>插入行的一部分；
>>
>>插入某些查询的结果。

### 15.1.1 插入完整的行
```
#普通写法，默认对应表的默认列名顺序
INSERT INTO Customers
VALUES('1000000006',
'Toy Land',
'123 Any Street',
'New York',
'NY',
'11111',
'USA',
NULL,
NULL);

# 更加安全的写法，这样写即使表的结构改变，这条SQL也能很好的执行
INSERT INTO Customers(cust_id,
cust_name,
cust_address,
cust_city,
cust_state,
cust_zip,
cust_country,
cust_contact,
cust_email)
VALUES('1000000006',
'Toy Land',
'123 Any Street',
'New York',
'NY',
'11111',
'USA',
NULL,
NULL);
```
\# Tips: INTO关键字是可选的，最好还是提供这个关键字，这样保证SQL代码在DBMS之间的可移植性


### 15.1.2 插入部分行
```
INSERT INTO Customers(cust_id,
cust_name,
cust_address,
cust_city,
cust_state,
cust_zip,
cust_country)
VALUES('1000000006',
'Toy Land',
'123 Any Street',
'New York',
'NY',
'11111',
'USA');
```
>警告：省略列
>>如果表的定义允许，则可以在INSERT操作中省略某些列。省略的列必须满足以下某个条件。
>>>该列定义为允许NULL值（无值或空值）。
>>>
>>>在表定义中给出默认值。这表示如果不给出值，将使用默认值。

### 15.1.3 插入检索出的数据
```
INSERT INTO Customers(cust_id,
                      cust_contact,
                      cust_email,
                      cust_name,
                      cust_address,
                      cust_city,
                      cust_state,
                      cust_zip,
                      cust_country)
SELECT cust_id,
      cust_contact,
      cust_email,
      cust_name,
      cust_address,
      cust_city,
      cust_state,
      cust_zip,
      cust_country
FROM CustNew;
```
>Tips：INSERT SELECT中的列名
>>为简单起见，这个例子在INSERT和SELECT语句中使用了相同的列名。但是，不一定要求列名匹配。事实上，DBMS一点儿也不关心SELECT返回的列名。它使用的是列的位置，因此SELECT中的第一列（不管其列名）将用来填充表列中指定的第一列，第二列将用来填充表列中指定的第二列，如此等等。
>Tips：插入多行
>>INSERT通常只插入一行。要插入多行，必须执行多个INSERT语句。INSERT SELECT是个例外，它可以用一条INSERT插入多行，不管SELECT语句返回多少行，都将被INSERT插入。

## 15.2 从一个表复制到另一个表
> Description: DB2不支持
>> DB2不支持SELECT INTO
> Description: INSERT SELECT 与SELECT INTO
>> 它们之间的区别是：前者是导出数据，而后者是导入数据

```
SELECT *
INTO CustCopy
FROM Customers;
```
>Something needs to know
>>任何SELECT选项和子句都可以使用，包括WHERE和GROUP BY；
>>
>>可利用联结从多个表插入数据；
>>
>>不管从多少个表中检索数据，数据都只能插入到一个表中。
>Tips:进行表的复制
>>SELECT INTO是试验新SQL语句前进行表复制的很好工具。先进行复制，可在复制的数据上测试SQL代码，而不会影响实际的数据。

# 16 更新和删除数据
> UPDATE and DELETE

# 16.1 更新数据
>2种方式
>>更新表中的特定行
>>
>>更新表中的所有行
>**Warning:** 不要省略WHERE子句
>>因为稍不注意就会更新所有行
>**Tips:** UPDATE与安全
>>使用UPDATE可能需要特定的权限
```
UPDATE Customers
SET cust_contact = 'Sam Roberts',
cust_email = 'sam@toyland.com'
WHERE cust_id = '1000000006';
```
>Tips：在UPDATE语句中使用子查询
>>UPDATE语句中可以使用子查询，使得能用SELECT语句检索出的数据更新列数据。
>Tips：FROM关键字
>>有的SQL实现支持在UPDATE语句中使用FROM子句，用一个表的数据更新另一个表的行。

# 16.2 删除数据
>2种方式
>>删除表中的特定行
>>
>>删除表中的所有行
>**Warning:** 不要省略WHERE子句
>>因为稍不注意就会更新所有行
>**Tips:** DELETE与安全
>>使用DELETE可能需要特定的权限

```
DELETE FROM Customers
WHERE cust_id = '1000000006';
```

>Tips:友好的外键
>>存在外键时，DBMS使用它们实施引用完整性。，DBMS通常可以防止删除某个关系需要用到的行
>Tips:FROM 关键字
>>在某些SQL实现中，DELETE后的关键字FROM是可选的，但是最好提供这个关键字，以保证可移植性
>Desription:删除表的内容而不是表
>>DELETE删除的是表中的行而不是表本身
>Tips:更快的删除
>> 删除所有的行，可以使用TRUNCATE TABLE，它的速度更快（因为不会记录数据变动）

## 16.3 更新和删除的指导原则
>用UPDATE或DELETE时所遵循的重要原则:
>>除非确实打算更新和删除每一行，否则绝对不要使用不带WHERE子句的UPDATE或DELETE语句。
>>
>>保证每个表都有主键（如果忘记这个内容，请参阅第12课），尽可能像WHERE子句那样使用它（可以指定各主键、多个值或值的范围）。
>>
>>在UPDATE或DELETE语句使用WHERE子句前，应该先用SELECT进行测试，保证它过滤的是正确的记录，以防编写的WHERE子句不正确。
>>
>>使用强制实施引用完整性的数据库（关于这个内容，请参阅第12课），这样DBMS将不允许删除其数据与其他表相关联的行。
>>
>>有的DBMS允许数据库管理员施加约束，防止执行不带WHERE子句的UPDATE或DELETE语句。如果所采用的DBMS支持这个特性，应该使用
它。


# 17 创建和操纵表
## 17.1 创建表
>必要的信息
>>新表的名字，在关键字CREATE TABLE之后给出；
>>
>>表列的名字和定义，用逗号分隔；
>>
>>有的DBMS还要求指定表的位置。
```
CREATE TABLE Products
(
  prod_id CHAR(10) NOT NULL,
  vend_id CHAR(10) NOT NULL,
  prod_name CHAR(254) NOT NULL,
  prod_price DECIMAL(8,2) NOT NULL,
  prod_desc VARCHAR(1000) NULL
);
```
>Tips:语句格式化，建议缩进，因为空格会被SQL忽略，而且缩进使得SQL易读
>
>替换现有的表
>
>创建新的表的时候，指定的表名必须不存在

### 17.1.2 使用NULL值
>每个列要么是NULL，要么是NOT NULL,如果没有指定NOT NULL 那么NULL就是默认值
>
>**Warning:** 多数DBMS默认是NULL，但少数DBMS不是这样的，比如DB2要求指定关键字NULL，否则会出错
>
>Tips: 主键不能为NULL
>
>**Warning：** NULL值不同于空字符串

### 17.1.3 指定默认值
>SQL允许指定默认值，默认值在CREATE TABLE语句真的列定义中用关键字DEFAULT指定

```
CREATE TABLE OrderItems
(
  order_num INTEGER NOT NULL,
  order_item INTEGER NOT NULL,
  prod_id CHAR(10) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  item_price DECIMAL(8,2) NOT NULL
);
```

>时间戳经常使用默认值
|DBMS|函数/变量|
|----|--------|
|Access|NOW()|
|DB2|CURRENT_DATE|
|MySQL|CURRENT_DATE()|
|Oracle|SYSDATE|
|PostgreSQL|CURRENT_DATE|
|SQL Server|GETDATE()|
|SQLite|date('now')|

## 17.2 更新表
> ALTER TABLE注意事项：
>> 理想情况下，不要在表中包含数据时对其进行更新。应该在表的设计过程中充分考虑未来可能的需求，避免今后对表的结构做大改动。
>>
>> 所有的DBMS都允许给现有的表增加列，不过对所增加列的数据类型（以及NULL和DEFAULT的使用）有所限制。
>>
>> 许多DBMS不允许删除或更改表中的列。
>>
>> 多数DBMS允许重新命名表中的列。
>>
>> 许多DBMS限制对已经填有数据的列进行更改，对未填有数据的列几乎没有限制。

```
#增加列
ALTER TABLE Vendors
ADD vend_phone CHAR(20);

#删除列
ALTER TABLE Vendors
DROP COLUMN vend_phone;
```

>复杂的表结构更改一般需要手动删除过程，它涉及以下步骤：
>> 1. 用新的列布局创建一个新表；
>>
>> 2. 使用INSERT SELECT语句（关于这条语句的详细介绍，请参阅第15课）从旧表复制数据到新表。有必要的话，可以使用转换函数和计算字段；
>>
>> 3. 检验包含所需数据的新表；
>>
>> 4. 重命名旧表（如果确定，可以删除它）；
>>
>> 5. 用旧表原来的名字重命名新表；
>>
>> 6. 根据需要，重新创建触发器、存储过程、索引和外键。

> Description:
>> SQLite 不支持ALTER TABLE定义主键和外键，这些必须在最初创建表时指定
>
> WARNING: 小心使用ALTER TABLE
>>数据库表的更改不能撤销，如果增加了不需要的列，也许无法删除它们。类似地，如果删除了不应该删除的列，可能会丢失该列中的所有数据。

## 17.3 删除表
```
DROP TABLE CustCopy;
```
> Tips: 使用关系规则防止意外删除
>> 许多DBMS允许强制实施有关规则，防止删除与其他表相关联的表。在实施这些规则时，如果对某个表发布一条DROP TABLE语句，且该表是某个关系的组成部分，则DBMS将阻止这条语句执行，直到该关系被删除为止。如果允许，应该启用这些选项，它能防止意外删除有用的表。

## 17.4 重命名表
>每个DBMS对表重命名的支持有所不同。对于这个操作，不存在严格的标准。
>>DB2、MariaDB、MySQL、Oracle和PostgreSQL用户使用RENAME语句
>>
>>SQL Server用户使用sp_rename存储过程
>>
>>SQLite用户使用ALTER TABLE语句

## 18.1 使用视图
>视图是虚拟的表。与包含数据的表不一样，视图只包含使用时动态检索数据的查询。
>
>**Description:** DBMS支持
>>Microsoft Access不支持视图，没有与SQL视图一致的工作方式。因此，这一课的内容不适用Microsoft Access。
>>
>>MySQL从版本5起开始支持视图，因此，这一节的内容不适用较早版本的MySQL。
>>
>>SQLite仅支持只读视图，所以视图可以创建，可以读，但其内容不能更改。
>
>Tips: 所有DBMS都支持视图的创建

### 18.1.1 为什么使用视图
>视图的一些常见应用:
>>重用SQL语句。
>>
>>简化复杂的SQL操作。在编写查询后，可以方便地重用它而不必知道其基本查询细节。
>>
>>使用表的一部分而不是整个表。
>>
>>保护数据。可以授予用户访问表的特定部分的权限，而不是整个表的访问权限。
>>
>>更改数据格式和表示。视图可返回与底层表的表示和格式不同的数据。
>
>**Warning:** 性能问题
>> 每次使用视图会执行大量检索。如果使用了复杂的联结和过滤或者嵌套了视图，性能可能会下降的很厉害

### 18.1.2 视图的规则和限制
>视图创建和使用的一些最常见的规则和限制
>>与表一样，视图必须唯一命名（不能给视图取与别的视图或表相同的名字）。
>>
>>对于可以创建的视图数目没有限制。
>>
>>创建视图，必须具有足够的访问权限。这些权限通常由数据库管理人员授予。
>>
>>视图可以嵌套，即可以利用从其他视图中检索数据的查询来构造视图。所允许的嵌套层数在不同的DBMS中有所不同（嵌套视图可能会严重降低查询的性能，因此在产品环境中使用之前，应该对其进行全面测试）。
>>
>>许多DBMS禁止在视图查询中使用ORDER BY子句。
>>
>>有些DBMS要求对返回的所有列进行命名，如果列是计算字段，则需要使用别名（关于列别名的更多信息，请参阅第7课）。
>>
>>视图不能索引，也不能有关联的触发器或默认值。
>>
>>有些DBMS把视图作为只读的查询，这表示可以从视图检索数据，但不能将数据写回底层表。详情请参阅具体的DBMS文档。
>>
>>有些DBMS允许创建这样的视图，它不能进行导致行不再属于视图的插入或更新。例如有一个视图，只检索带有电子邮件地址的顾客。如果更新某个顾客，删除他的电子邮件地址，将使该顾客不再属于视图。这是默认行为，而且是允许的，但有的DBMS可能会防止这种情况发生。
>
>Tips: 具体限制和约束应当参阅具体的DBMS文档

## 18.2 创建视图
```
CREATE VIEW ProductCustomers AS
SELECT cust_name, cust_contact, prod_id
FROM Customers, Orders, OrderItems
WHERE Customers.cust_id = Orders.cust_id
AND OrderItems.order_num = Orders.order_num;
```
> Tips: 创建可重用的视图
>> 创建不绑定特定数据的视图是个比较好的选择
>>
>>覆盖或者更新视图应当先删除旧的视图

### 18.2.1 利用视图简化复杂的联结
```
# 创建视图
CREATE VIEW ProductCustomers AS
SELECT cust_name, cust_contact, prod_id
FROM Customers, Orders, OrderItems
WHERE Customers.cust_id = Orders.cust_id
AND OrderItems.order_num = Orders.order_num;
# 检索视图
SELECT cust_name, cust_contact
FROM ProductCustomers
WHERE prod_id = 'RGAN01';
```

### 18.2.2 用视图重新格式化检索出的数据
```
CREATE VIEW VendorLocations AS
SELECT RTRIM(vend_name) + ' (' + RTRIM(vend_country) + ')'
      AS vend_title
FROM Vendors;
```
### 18.2.3 用视图过滤不想要的数据
```
CREATE VIEW CustomerEMailList AS
SELECT cust_id, cust_name, cust_email
FROM Customers
WHERE cust_email IS NOT NULL;
```
> 视图WHERE子句和SELECT WHERE子句
>> 检索视图时使用了WHERE子句，则两组子句将自动组合

### 18.2.4 使用视图与计算字段
```
CREATE VIEW OrderItemsExpanded AS
SELECT order_num,
      prod_id,
      quantity,
      item_price,
      quantity*item_price AS expanded_price
FROM OrderItems;
```

# 19 存储过程

## 19.1 存储过程
>简单来说，存储过程就是为以后使用而保存的一条或多条SQL语句。可将其视为批文件，虽然它们的作用不仅限于批处理。
>
>Description: 具体DBMS的支持
>>
>> Microsoft Access和SQLite不支持存储过程。因此，本课的内容不适用它们。
>>
>> MySQL 5已经支持存储过程。因此，本课的内容不适用MySQL较早的版本。
>
>More Content: 需要很大的篇幅，暂不赘述

## 19.2 为什么使用存储过程
>一些主要的理由：
>>通过把处理封装在一个易用的单元中，可以简化复杂的操作（如前面例子所述）。
>>
>>由于不要求反复建立一系列处理步骤，因而保证了数据的一致性。如果所有开发人员和应用程序都使用同一存储过程，则所使用的代码都是相同的。
>>这一点的延伸就是防止错误。需要执行的步骤越多，出错的可能性就越大。防止错误保证了数据的一致性。
>>
>>简化对变动的管理。如果表名、列名或业务逻辑（或别的内容）有变化，那么只需要更改存储过程的代码。使用它的人员甚至不需要知道这些变化。
>>这一点的延伸就是安全性。通过存储过程限制对基础数据的访问，减少了数据讹误（无意识的或别的原因所导致的数据讹误）的机会。
>>
>>因为存储过程通常以编译过的形式存储，所以DBMS处理命令的工作较少，提高了性能。
>>
>>存在一些只能用在单个请求中的SQL元素和特性，存储过程可以使用它们来编写功能更强更灵活的代码。
>>
>>In Conclusion: 简单、安全、高效
>
>在将SQL代码转换为存储过程前，也必须知道它的一些缺陷:
>>
>>不同的DBMS中的存储过程语法有所不同
>>
>>编写存储过程比编写基本SQL语句复杂，需要更高的技能，更丰富的经验。
>
>Description: 大多数DBMS将编写存储过程所需的安全和访问权限与执行存储过程所需的安全和访问权限区分开来。这是好事情，即使你不能（或不想）编写自己的存储过程，也仍然可以在适当的时候执行别的存储过程。

## 19.3 执行存储过程
```
EXECUTE AddNewProduct( 'JTS01',
                      'Stuffed Eiffel Tower',
                      6.49,
                      'Plush stuffed toy with the text La
Tour Eiffel in red white and blue' )
```

>存储过程所完成的工作：
>>验证传递的数据，保证所有4个参数都有值；
>>
>>生成用作主键的唯一ID；
>>
>>将新产品插入Products表，在合适的列中存储生成的主键和传递的数据。
>
>对于具体的DBMS，可能包括以下的执行选择：
>>
>>参数可选，具有不提供参数时的默认值；
>>
>>不按次序给出参数，以“参数=值”的方式给出参数值。
>>
>>输出参数，允许存储过程在正执行的应用程序中更新所用的参数。
>>
>>用SELECT语句检索数据。
>>
>>返回代码，允许存储过程返回一个值到正在执行的应用程序

## 19.4 创建存储过程
```
# Oracle 定义
CREATE PROCEDURE MailingListCount (
  ListCount OUT INTEGER
)
IS
v_rows INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_rows
    FROM Customers
    WHERE NOT cust_email IS NULL;
    ListCount := v_rows;
END;

# 参数
#OUT   表示   返回值
#IN    表示   参数
#INOUT 表示   既是参数也会返回

#调用
var ReturnValue NUMBER
EXEC MailingListCount(:ReturnValue);
SELECT ReturnValue;


#SQL Server
CREATE PROCEDURE MailingListCount
AS
DECLARE @cnt INTEGER
SELECT @cnt = COUNT(*)
FROM Customers
WHERE NOT cust_email IS NULL;
RETURN @cnt;

# 调用
DECLARE @ReturnValue INT
EXECUTE @ReturnValue=MailingListCount;
SELECT @ReturnValue;

# 插入新的订单
CREATE PROCEDURE NewOrder @cust_id CHAR(10)
AS
-- Declare variable for order number
DECLARE @order_num INTEGER
-- Get current highest order number
SELECT @order_num=MAX(order_num)
FROM Orders
-- Determine next order number
SELECT @order_num=@order_num+1
-- Insert new order
INSERT INTO Orders(order_num, order_date, cust_id)
VALUES(@order_num, GETDATE(), @cust_id)
-- Return order number
```

>Description：注释代码
>>所有的DBMS都支持--
>
>Tips:
>>大多数DBMS都支持由DBMS生成订单号这种功能
>>
>>SQL Server中称这些自动增量的列为标识字段（identity field）
>>
>>其他DBMS称之为自动编号（auto number）或序列（sequence）。传递给此过程的参数也是一个，即下订单的顾客ID。
>>
>>DBMS对日期使用默认值（GETDATE()函数），订单号自动生成。
>>
>>怎样才能得到这个自动生成的ID？在SQL Server上可在全局变量@@IDENTITY中得到，它返回到调用程序（这里使用SELECT语句）

# 20 管理事务处理
>如何利用COMMIT和ROLLBACK语句管理事务处理。

# 20.1 事务处理
>关于事务处理需要知道的几个术语：
>>事务（transaction）指一组SQL语句；
>>
>>回退（rollback）指撤销指定SQL语句的过程；
>>
>>提交（commit）指将未存储的SQL语句结果写入数据库表；
>>
>>保留点（savepoint）指事务处理中设置的临时占位符（placeholder），可以对它发布回退（与回退整个事务处理不同）。
>
>Tips:可以回退的语句
>>INSERT\UPDATE\DELETE
>
>不能回退的语句
>>CREATE/DROP/SELECT,事务处理的过程中可以使用这些语句，但是这些操作不会撤销

## 20.2 控制事务处理
>**Warning：** 不同DBMS用来实现事务处理的语法有所不同。在使用事务处理时请参阅相应的DBMS文档。

有的DBMS要求有明确标识事务处理块的开始与结束
```
#SQL Server
BEGIN TRANSACTION
...
COMMIT TRANSACTION

#MariaDB和MySQL
START TRANSACTION
...

#Oracle
SET TRANSACTION
...

#PostgreSQL
BEGIN
...

#其他DBMS采用上述语法的变体。你会发现，多数实现没有明确标识事务处理在何处结束。事务一直存在，直到被中断。通常，COMMITT用于保存更改，ROLLBACK用于撤销
```

### 20.2.1 使用ROLLBACK
```
DELETE FROM Orders;
ROLLBACK;
```

### 20.2.2 使用COMMIT
>一般的SQL语句都是针对数据库表直接执行和编写的。这就是所谓的隐式提交（implicit commit），即提交（写或保存）操作是自动进行的。
>在事务处理块中，提交不会隐式进行。不过，不同DBMS的做法有所不同。有的DBMS按隐式提交处理事务端，有的则不这样。

```
#SQL Server
BEGIN TRANSACTION
DELETE OrderItems WHERE order_num = 12345
DELETE Orders WHERE order_num = 12345
COMMIT TRANSACTION

# ORACLE
SET TRANSACTION
DELETE OrderItems WHERE order_num = 12345;
DELETE Orders WHERE order_num = 12345;
COMMIT;
```

### 20.2.3 使用保留点
>简单的事务使用ROLLBACK和COMMIT
>
>复杂的事务需要部分提交或回退
>
>在SQL中，这些占位符称为保留点。

```
# MariaDB\MySQL\Oracle
SAVEPOINT delete1;
#ROLLBACK
ROLLBACK TO delete1;

# SQL Server
SAVE TRANSACTION delete1;
# ROLLBACK
ROLLBACK TRANSACTION delete1;

#完整的SQL Server例子
BEGIN TRANSACTION
INSERT INTO Customers(cust_id, cust_name)
VALUES('1000000010', 'Toys Emporium');
SAVE TRANSACTION StartOrder;
INSERT INTO Orders(order_num, order_date, cust_id)
VALUES(20100,'2001/12/1','1000000010');
IF @@ERROR <> 0 ROLLBACK TRANSACTION StartOrder;
INSERT INTO OrderItems(order_num, order_item, prod_id, quantity, item_price)
VALUES(20100, 1, 'BR01', 100, 5.49);
IF @@ERROR <> 0 ROLLBACK TRANSACTION StartOrder;
INSERT INTO OrderItems(order_num, order_item, prod_id, quantity, item_price)
VALUES(20100, 2, 'BR03', 100, 10.99);
IF @@ERROR <> 0 ROLLBACK TRANSACTION StartOrder;
COMMIT TRANSACTION
```
>Tips:保留点越多越好
>>保留点越多，你就越能灵活地进行回退

# 21 使用游标

## 21.1 游标
>结果集
>> SQL 查询所检索出的结果
>
>Description:具体DBMS的支持
>>
>>Microsoft Access不支持游标，所以本课的内容不适用于Microsoft Access。
>>
>>MySQL 5已经支持存储过程。因此，本课的内容不适用MySQL较早的版本。
>>
>>SQLite支持的游标称为步骤（step），本课讲述的基本概念适用于SQLite的步骤，但语法可能完全不同。
>
>不同的DBMS支持不同的游标选项和特性。常见的一些选项和特性如下。
>>
>>能够标记游标为只读，使数据能读取，但不能更新和删除。
>>
>>能控制可以执行的定向操作（向前、向后、第一、最后、绝对位置、相对位置等）。
>>
>>能标记某些列为可编辑的，某些列为不可编辑的。
>>
>>规定范围，使游标对创建它的特定请求（如存储过程）或对所有请求可访问。
>>
>>指示DBMS对检索出的数据（而不是指出表中活动数据）进行复制，使数据在游标打开和访问期间不变化。

## 21.2 使用游标
>使用游标涉及几个明确的步骤：
>>在使用游标前，必须声明（定义）它。这个过程实际上没有检索数据，它只是定义要使用的SELECT语句和游标选项。
>>
>>一旦声明，就必须打开游标以供使用。这个过程用前面定义的SELECT语句把数据实际检索出来。
>>
>>对于填有数据的游标，根据需要取出（检索）各行。
>>
>>在结束游标使用时，必须关闭游标，可能的话，释放游标（有赖于具体的DBMS）。

# 21.2.1 创建游标
```
#DB2、MariaDB、MySQL、SQL Server
DECLARE CustCursor CURSOR
FOR
SELECT * FROM Customers
WHERE cust_email IS NULL

#Oracle、 PostgreSQL
DECLARE CURSOR CustCursor
IS
SELECT * FROM Customers
WHERE cust_email IS NULL
```

# 21.2.2 使用游标
```
# 大多数DBMS使用
OPEN CURSOR CustCursor

# Oracle
DECLARE TYPE CustCursor IS REF CURSOR
RETURN Customers%ROWTYPE;
DECLARE CustRecord Customers%ROWTYPE
BEGIN
OPEN CustCursor;
LOOP
FETCH CustCursor INTO CustRecord;
EXIT WHEN CustCursor%NOTFOUND;
...
END LOOP;
CLOSE CustCursor;
END;

# SQL Server
DECLARE @cust_id CHAR(10),
        @cust_name CHAR(50),
        @cust_address CHAR(50),
        @cust_city CHAR(50),
        @cust_state CHAR(5),
        @cust_zip CHAR(10),
        @cust_country CHAR(50),
        @cust_contact CHAR(50),
        @cust_email CHAR(255)
OPEN CustCursor
FETCH NEXT FROM CustCursor
INTO @cust_id, @cust_name, @cust_address,
    @cust_city, @cust_state, @cust_zip,
    @cust_country, @cust_contact, @cust_email
WHILE @@FETCH_STATUS = 0
BEGIN
FETCH NEXT FROM CustCursor
INTO @cust_id, @cust_name, @cust_address,
    @cust_city, @cust_state, @cust_zip,
    @cust_country, @cust_contact, @cust_email
END
CLOSE CustCursor
```
### 21.2.3 关闭游标
```
# DB2\Oracle\PostgreSQL
CLOSE CustCursor

# SQL Server
CLOSE CustCursor
DEALLOCATE CURSOR CustCursor
```
\# 油游标一旦关闭，就不能使用，如果要使用，就必须再次打开它，再次打开不需要声明，只需要OPEN即可。

# 22 高级SQL特性
>几个高级特新
>> 约束
>>
>>索引
>>
>>触发器

## 22.1 约束
>虽然可以在插入新行时进行检查（在另一个表上执行SELECT，以保证所有值合法并存在），但最好不要这样做，原因如下：
>>如果在客户端层面上实施数据库完整性规则，则每个客户端都要被迫实施这些规则，一定会有一些客户端不实施这些规则。
>>
>>在执行UPDATE和DELETE操作时，也必须实施这些规则。
>>
>>执行客户端检查是非常耗时的，而DBMS执行这些检查会相对高效。

>大多数约束都是在数据库表上施加约束来实施引用完整性。
>
>大多数约束都是在表定义中定义的，使用CREATE TABLE 或ALTER TABLE
>
>每个DBMS提供自己的约束支持，具体参阅具体的DBMS文档

### 22.1.1 主键
>表中任意列只要满足以下条件，都可以用于主键：
>>任意两行的主键值都不相同。
>>
>>每行都具有一个主键值（即列中不允许NULL值）。
>>
>>包含主键值的列从不修改或更新。（大多数DBMS不允许这么做，但如果你使用的DBMS允许这样做，好吧，千万别！）
>>
>>主键值不能重用。如果从表中删除某一行，其主键值不分配给新行。

```
# Example
CREATE TABLE Vendors
(
vend_id CHAR(10) NOT NULL PRIMARY KEY,
vend_name CHAR(50) NOT NULL,
vend_address CHAR(50) NULL,
vend_city CHAR(50) NULL,
vend_state CHAR(5) NULL,
vend_zip CHAR(10) NULL,
vend_country CHAR(50) NULL
);

# 修改表定义
ALTER TABLE Vendors
ADD CONSTRAINT PRIMARY KEY (vend_id);
```

> SQLite不允许使用 ALTER TABLE 定义键，要求在初始化的CREATE TABLE中定义它们。

### 22.1.2 外键
>外键是表中的一列，其值必须列在另一表的主键中。外键是保证引用完整性的极其重要部分。

```
CREATE TABLE Orders
(
order_num INTEGER NOT NULL PRIMARY KEY,
order_date DATETIME NOT NULL,
cust_id CHAR(10) NOT NULL REFERENCES Customers(cust_id)
);
```

>外键有助防止意外删除
>>帮助保证引用完整性外
>>在定义外键后，DBMS不允许删除在另一个表中具有关联行的行。由于需要一系列的删除，因而利用外键可以防止意外删除数据。
>
>有的DBMS支持称为级联删除（cascading delete）的特性，删除一行，所有相关的数据都会被删除。

### 22.1.3 唯一约束
>唯一约束用来保证一列（或一组列）中的数据是唯一的。它们类似于主键，但存在以下重要区别。
>>表可包含多个唯一约束，但每个表只允许一个主键。
>>
>>唯一约束列可包含NULL值。
>>
>>唯一约束列可修改或更新。
>>
>>唯一约束列的值可重复使用。
>>
>>与主键不一样，唯一约束不能用来定义外键。
>
>唯一约束的语法类似于其他约束的语法。唯一约束既可以用UNIQUE关键字在表定义中定义，也可以用单独的CONSTRAINT定义。

### 22.1.4 检查约束
>检查约束的常见用途有以下几点:
>>检查最小或最大值。例如，防止0个物品的订单（即使0是合法的数）。
>>
>>指定范围。例如，保证发货日期大于等于今天的日期，但不超过今天起一年后的日期。
>>
>>只允许特定的值。例如，在性别字段中只允许M或F。

```
CREATE TABLE OrderItems
(
order_num INTEGER NOT NULL,
order_item INTEGER NOT NULL,
prod_id CHAR(10) NOT NULL,
quantity INTEGER NOT NULL CHECK (quantity > 0),
item_price MONEY NOT NULL
);

#检查名为gender的列只包含M或F
ADD CONSTRAINT CHECK (gender LIKE '[MF]')
```

>用户定义数据类型
>>有的DBMS允许用户定义自己的数据类型。它们是定义检查约束（或其他约束）的基本简单数据类型。
>>
>>定制数据类型的优点是只需施加约束一次（在数据类型定义中），而每当使用该数据类型时，都会自动应用这些约束。

## 22.2 索引
>主键数据总是排序的，这是DBMS的工作。因此，按主键检索特定行总是一种快速有效的操作。
>
>索引可以定义在一个或者多个列上定义
>
>在开始创建索引前，应该记住以下内容：
>>索引改善检索操作的性能，但降低了数据插入、修改和删除的性能。在执行这些操作时，DBMS必须动态地更新索引。
>>
>>索引数据可能要占用大量的存储空间。
>>
>>并非所有数据都适合做索引。取值不多的数据（如州）不如具有更多可能值的数据（如姓或名），能通过索引得到那么多的好处。
>>
>>索引用于数据过滤和数据排序。如果你经常以某种特定的顺序排序数据，则该数据可能适合做索引。
>>
>>可以在索引中定义多个列（例如，州加上城市）。这样的索引仅在以州加城市的顺序排序时有用。如果想按城市排序，则这种索引没有用处。

```
CREATE INDEX prod_name_ind
ON PRODUCTS (prod_name);
```

>检查索引
>>
>>索引的效率随表数据的增加或改变而变化
>>
>>最好定期检查索引，并根据需要对索引进行调整。

## 22.3 触发器
> 触发器是特殊的存储过程，它在特定的数据库活动发生时自动执行。触发器可以与特定表上的INSERT、UPDATE和DELETE操作（或组合）相关联。
>
>与存储过程不一样（存储过程只是简单的存储SQL语句），触发器与单个的表相关联。与Orders表上的INSERT操作相关联的触发器只在Orders表中插入行时执行。类似地，Customers表上的INSERT和UPDATE操作的触发器只在表上出现这些操作时执行。
>
>触发器内的代码具有以下数据的访问权：
>>INSERT操作中的所有新数据；
>>
>>UPDATE操作中的所有新数据和旧数据；
>>
>>DELETE操作中删除的数据。
>
>下面是触发器的一些常见用途。
>>保证数据一致。例如，在INSERT或UPDATE操作中将所有州名转换为大写。
>>
>>基于某个表的变动在其他表上执行活动。例如，每当更新或删除一行时将审计跟踪记录写入某个日志表。
>>
>>进行额外的验证并根据需要回退数据。例如，保证某个顾客的可用资金不超限定，如果已经超出，则阻塞插入。
>>
>>计算计算列的值或更新时间戳。

```
# SQL Server
CREATE TRIGGER customer_state
ON Customers
FOR INSERT, UPDATE
AS
UPDATE Customers
SET cust_state = Upper(cust_state)
WHERE Customers.cust_id = inserted.cust_id;

# Oracle\ PostgreSQL
CREATE TRIGGER customer_state
AFTER INSERT OR UPDATE
FOR EACH ROW
BEGIN
UPDATE Customers
SET cust_state = Upper(cust_state)
WHERE Customers.cust_id = :OLD.cust_id
END;
```

\# 一般来说约束的处理比触发器更快，因此，应当尽量使用约束

## 22.4 数据库安全
>大多数DBMS都给管理员提供了管理机制，利用管理机制授予或限制对数据的访问。
>
>任何安全系统的基础都是用户授权和身份确认。有的DBMS为此结合使用了操作系统的安全措施，而有的维护自己的用户及密码列表，还有一些结合使用外部目录服务服务器。

>一般说来，需要保护的操作有：
>>对数据库管理功能（创建表、更改或删除已存在的表等）的访问；
>>
>>对特定数据库或表的访问；
>>
>>访问的类型（只读、对特定列的访问等）；
>>
>>仅通过视图或存储过程对表进行访问；
>>
>>创建多层次的安全措施，从而允许多种基于登录的访问和控制；
>>
>>限制管理用户账号的能力。
>
>安全性使用SQL的GRANT和REVOKE语句来管理，不过，大多数DBMS提供了交互式的管理实用程序，这些实用程序在内部使用GRANT和REVOKE语句。
