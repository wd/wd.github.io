+++
title = "Join 后面跟两个表"
tags = ["linux", "mysql", "sql"]
status = "publish"
type = "post"
published = true
comments = true
date = "2012-08-05"
description = ""
+++


发现 sql 的写法真是千奇百怪，经常遇到没见过的写法。前几天就遇到了一个 sql 在 join 后写两个表，用逗号分隔。类似下面。



<pre class="prettyprint lang-sql">
select a.a, b.f from t1 a left join ( b, c ) on ( b.id = c.id and b.a = a.a )
</pre>


看到 sql 的这些用法我一般都是去 pgsql 的文档里面去查，因为 pg 的文档里面一般会指明一种用法是否标准 sql，多写标准 sql 可以避免知识不能转移。不过去查了发现 pg 不支持这种写法，也去 pg 里面执行了，确实不支持。


然后就去看 mysql 的文档，里面有对于这种写法的<a href="http://dev.mysql.com/doc/refman/5.1/en/join.html">支持</a>。



<pre class="prettyprint lang-text">
 The syntax of table_factor is extended in comparison with the SQL Standard. The latter accepts only table_reference, not a list of them inside a pair of parentheses.

This is a conservative extension if we consider each comma in a list of table_reference items as equivalent to an inner join. For example:

SELECT * FROM t1 LEFT JOIN (t2, t3, t4)
                 ON (t2.a=t1.a AND t3.b=t1.b AND t4.c=t1.c)

is equivalent to:

SELECT * FROM t1 LEFT JOIN (t2 CROSS JOIN t3 CROSS JOIN t4)
                 ON (t2.a=t1.a AND t3.b=t1.b AND t4.c=t1.c)

In MySQL, JOIN, CROSS JOIN, and INNER JOIN are syntactic equivalents (they can replace each other). In standard SQL, they are not equivalent. INNER JOIN is used with an ON clause, CROSS JOIN is used otherwise. 
</pre>


可以看到，这种写法就是等于是让括号里面的 b,c 使用 inner join 的方式连接，当然如果 on 里面没有指定 join 方式，最后就是个笛卡尔集。然后<a href="http://dev.mysql.com/doc/refman/5.1/en/nested-join-optimization.html">这里</a> 有更多的一些说明，还有下面这种写法。



<pre class="prettyprint lang-sql">
t1 LEFT JOIN t2 ON t1.a=t2.a, t3
</pre>


这些写法都有各自的含义。


其实这么看来，这个方式好像是比较方便的，不过是对于不明白的人如果乱用，这玩意出的错也是很诡异很难排查的。


另外注意上面的语句里面写了，mysql 里面的 join, inner join, cross join 是完全同样的东西。

