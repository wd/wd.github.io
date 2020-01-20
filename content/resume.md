---
title: “Resume”
date: 2019-02-12T15:14:28+08:00
tags: [“简历”, “resume”]
toc: false
comment: false
---

- [PDF](/resume.pdf)
- [English version](/resume-en/)

个人技术知识面比较广，前端后端运维数据库、系统部署CI/CD、系统架构拆分等都有丰富的经验。也有日 PV 上亿的系统的开发、设计和维护经验。团队方面有从零组建团队的能力，有大型团队的组建和管理能力，期待我们的合作能给双方带来共赢。

## 联系方式:

* 邮箱: wd@wdicc.com, 电话/微信: ![phone](/phone.jpg)
* blog: https://wdicc.com/ ， github: https://github.com/wd

## 工作经历

### 新晨航空（2017 - 现在），公司合伙人，技术和产品负责人

- 组建团队：招聘产品技术设计 10 人左右。
- 办公环境：搭建办公室开发用服务器，Debian, GitLab, Prometheus, VPN, Wiki, NFS, DNS, 翻墙等。
- 后端：使用 Django 搭建后端开发框架，使用了 Celery, Channels 等。数据库使用的是 PostgreSQL + Redis。
  - 使用 Celery 跑定时任务，Redis 做 broker。
  - 使用了 Channels 跑 WebSocket 服务，实时广播通知给用户端（Web/APP）。
  - 我们需要做一些地理位置的计算，主要使用了 PostGIS 来做图形交叠判断。
- 自动化部署：使用 Ansiable 搭建代码自动化部署方案，包括后端发布，APP 打包等。
  - 后端服务器上面都是跑的 Docker，分了三套环境。
- 前端 APP：搭建了 RN react 开发框架，使用到了 Redux/Reselect/Saga/TypeScript 等流行的工具，使用 RN 开发了两款上架 APP，一款 Pad 用 APP。使用 Fastlane 打包。
  - 代码架构改了一版，现在都迁移到了 TypeScript。
  - 主要的精力应该都花在了构建 RN APP 的需求上面，各种客户端上面的 bug，第三方模块适配等等，琐事和小问题巨多。
- 前端 WEB：Web 开发参与不多，使用了 Vue+MobX 和 React+Redux 这些，优化了一些 Vue 使用上面的问题。
- Android Pad 系统和 PC 系统定制。
  - 联想的 Pad root 之后，对系统做了一些定制，防止 Pad 被滥用。
  - 联想的一体机，使用 Porteus 这个基于 Linux 的系统对台机做了定制，可以限制使用，和防止系统出问题，以及方便的恢复系统。
  - 还试过定制 Openwrt 路由器系统实现限制功能，不过这个方案最后没用。
- 其他的还有比如域名申请备案，服务器申请初始化部署，数据库备份等等一堆的事情。

主要开发语言是 React Native 相关技术，后端是 Python。

### 去哪儿网（2010 - 2016），高级技术总监

- 团队：离开的时候整个团队大概 30 多人。
- 数据工作：带领团队建立了度假部门的统计体系，包括日志收集分析入库展示等工作。
  - 设计和推广了 Qunar 用户唯一标识，搭建维护了一套 Greenplum 集群作为数据仓库。
  - 开发了数据追踪系统以支持 native/h5/RN 混合开发，使用了 Nginx + Fluentd。
  - 开发了一个 Dashboard 系统，方便数据工程师给产品经理做各种报表。
- PostgreSQL DBA 团队：带领团队维护公司几百个实例，建立了相应的监控体系。
  - 监控系统一开始使用 Nagios，遇到瓶颈之后使用 Gearman 扩展到多机，发现性能还是不行，后统一切换为 Zabbix 被动发现+检测方式。
  - 把数据库一些状态表信息例如索引使用次数，数据库大小等通过 Nagios 收集画图，方便看到历史信息排错。
  - 把数据库的查询 SQL 情况放到 Elastic Search 引擎，方便排查慢查询，频繁的查询等。
  - 尝试使用 Pacemaker + Etcd 实现集群集中部署和管理，做了一半没做完。😭
- 广告系统：带领团队负责公司的 CPM/CPC 广告系统，日 PV 达十亿。
  - 熟悉广告系统的各必备模块，例如广告展示引擎，防作弊，点击服务，计费体系，广告售卖逻辑等。
  - 期间曾将一套基于 Apache+Lua 的系统迁移到了 Nginx+Lua，提升了性能和稳定性。
- 度假无线团队：开发维护去哪儿 APP 里面度假模块（iOS, Android）， HTML5 版本的度假网站。

主要开发语言比较多，基本主流的都用了，包括 Perl，Lua，Python, Java 等。

### 淘宝网（2009 - 2010），开发工程师

- 做了一些基于 Hadoop 和 Hive 的统计，以及量子统计的 Web 后台界面的开发。

主要开发语言是 SQL, Java, Shell, HTML, JavaScript。

### Yahoo 中国（2007 - 2009），SRE、数据统计

- 战略数据平台部的 AppOPS 职位(类似 SRE)，负责大概 100 台机器的运维。期间开发了一个基于 Nagios 的中心配置的监控插件，方便实现个性化的监控需求。
- 参与了一些统计工作。

主要开发语言是 PHP，Perl，Shell。

### 深圳乐酷（2005 - 2007），运维

- 主要做运维工作，一个人维护大概几十台服务器，公司现在应该已经没有了。

### 宇航出版社（2002 - 2005），编辑、运维

- 刚加入做编辑工作，后面出于兴趣同时开始维护公司的网站和商城服务器。

## 学历

北京航空航天大学 2002 年本科毕业，应用物理与应用电子技术专业。
