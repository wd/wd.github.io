---
layout: post
title: "Some tips for bash scripting"
date: 2012-12-02 19:43
comments: true
tags: web
---
最近几天写了一些 bash 脚本，又有些心得，记录一下。

## 获取当前路径的绝对路径

比较常见的需求可能是获取相对路径，这样方便程序复制到其他目录也可以运行。使用 `$(dirname $0)` 就可以获取相对路径，不过这里说的是绝对路径。

其实也简单，相对路径加上当前目录，那不就是绝对路径么。不过是，有时候 `$(dirname $0)` 取到的也可能是绝对路径（一般期望相对路径的程序也能跑通，所以不大关心）。

可以用下面的做法，大意是先判断一下获取到的路径是不是 `/` 开头，如果是，那就不处理，如果不是，那就把当前的路径附加上去得到一个绝对路径。

``` bash
PG_DIR="$(dirname $0)/../"

echo "$PG_DIR" | grep -q ^/

if [ $? -ne 0 ];then
        PG_DIR="$(pwd)/$PG_DIR"
fi
```

## 使用 getopt 获取命令行参数

获取参数比较常见的做法是取 `$1` `$2` 这些，不过不太专业，这里说的是类似于 `--prefix=/path/to/install -v` 这种。

bash 本身提供了一个内部命令 `getopts` 来做这个事情，不过那个只能支持 short_opts，就是类似 `-v` 这种，不支持长的。

getopt 是一个 GNU 程序，他支持 long_opts。下面是个例子。代码基本来自网上。

``` bash
ARGS=$(getopt -a -o h -l initdb::,help -- "$@")
[ $? -ne 0 ] && usage

eval set -- "${ARGS}" 

while true
do
        case $1 in
                --initdb)
                        initdb $2
                        ;;
                -h|--help)
                        usage;
                        ;;
                --)
                        shift
                        break
                        ;;
        esac
        shift
done
```

解释一下上面的参数的含义:
* `-o` 参数指定的就是短参数，我试过，貌似还得指定至少一个短参数。
* `-l` 参数指定的就是长参数。
* 多个参数用逗号 `,` 分隔。
* 参数后面跟一个冒号 `:` 表示这个参数(option)必须要给一个参数(argument)，类似上面的 `--prefix=/path/to/install` 这种。
* 参数后面跟2个冒号 `::` 表示这个参数后面的参数可有可无。比如例子里面的 `--initdb`

## find exec 提示 No such file or directory

这个是之前用来日志删除的一个程序，大概命令类似 `find ./ -name '2012*' -exec rm -r {} \;`，后来总发现报 `No such file or directory` 这个错误，可是去看的时候，发现那些目录也被删掉了。开始觉得可能是有其他人的程序也在删除这个目录，问了一圈结果没人删。

后来经过测试琢磨找到原因了，在于这个命令的执行思路大概是先去找那个名字的文件或者目录，然后挨个执行后面的命令。那么，如果找到的既有上级目录，也有下级文件的时候，如果目录先被删掉了，那删文件的时候可不就是 `No such file or directory` 么。

好在 find 提供了一个参数 `-prune`
```
       -prune True; if the file is a directory, do not descend into it. If -depth is given, false; no effect.  Because -delete implies -depth, you can-
              not usefully use -prune and -delete together.
```
