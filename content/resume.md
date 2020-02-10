---
title: “Resume”
date: 2019-02-12T15:14:28+08:00
tags: [“简历”, “resume”]
toc: false
comment: false
---

- [PDF](/resume.pdf)
- [English version](/resume-en/)

个人技术知识面比较广，前端后端运维数据库、系统部署CI/CD、系统架构拆分等都有丰富的经验，对代码高要求，有代码洁癖。有日上亿请求高并发高性能系统的开发、设计和维护经验。有从零组建团队的能力，有大型团队的组建和管理能力，期待我们的合作能给双方带来共赢。

## 联系方式:

* 邮箱: wd@wdicc.com, 电话/微信: ![phone](/phone.jpg)
* blog: https://wdicc.com/ ， github: https://github.com/wd

## 工作经历

### 新晨航空（2017 - 现在），公司合伙人，技术和产品负责人

- ✳️ 团队：
  - 招聘产品技术设计 10 人左右，完成 6 个网站，3 个 APP(iOS/Android) 的开发。
  - 小公司人才难找，很多事情都需要亲力亲为才行，基本一个人分支撑了公司整个技术和产品体系的建立。
- ✳️ APP：使用了 Redux/Reselect/Saga/TypeScript 等流行的工具框架。
  - RN 版本一路从 0.4x 升级到了现在的 0.6x，很多艰辛。
  - 开发了 10 余款 RN 扩展自用，部分开源到了 github。
- ✳️ WEB：使用 Vue+MobX/React+Redux。
- ✳️ 后端：使用 Django/Celery/Channels/nginx/gunicorn/stomp.py/supervisord，PostgreSQL/PostGIS+Redis 搭建。
  - Django/PostgreSQL/Channels 等都跟着官方升级到了最新版本。
  - 使用 PostGIS 做一些地理图形的计算和存储。
- ✳️ 自动化：
  - Gitlab 自动检查提交的代码规范和跑测试用例。
  - 前后端发布和 APP 打包使用 Ansiable + Docker + Fastlane 等，开发了一个发布到 firim 的 Falstlane 扩展。
  - 监控预警服务器指标使用 AWS Cloudwatch，应用部分通过 Prometheus + Alertmanager 实现。
  - 定时任务跑业务报表和备份数据库，basebackup + xlog 实现恢复到任意时间点。
- ✳️ 其他都一些事情
  - 办公室开发用服务器，Debian, GitLab, Prometheus, VPN, Wiki, NFS, DNS，Rsyslog 等。
  - 联想Pad 系统定制，基于 Android 做定制，防止被滥用和方便恢复。
  - 联想一体机系统定制，基于 Porteus/Linux 二次开发，防止被滥用和方便恢复。
  - 其他的还有比如域名申请备案，AWS ACL 管理等。

主要开发语言是 React Native/Objective C/Java/Python/Shell/JavaScript/TypeScript/SQL 等。


### 去哪儿网（2010 - 2016），高级技术总监

- ✳️ 团队：
  - 整个团队大概 30 多人，从无到有建立的。总共大致分 4 个小团队。
- ✳️ 大数据团队：带领团队建立了公司的统计体系，包括日志收集分析入库展示等工作。
  - 设计了 Qunar 用户唯一标识，开创了 Qunar 统计的标准化，使用 flume/logstash/kafka/storm/hadoop 收集存放日志，使用 Greenplum 集群作为数据仓库。
  - 开发了数据追踪系统 skynet 以支持 native/h5/RN 混合开发，使用了 Nginx + Fluentd。
  - 开发了 Dashboard 系统，方便数据工程师给产品/运营做各种报表。
- ✳️ DBA 团队：带领团队维护公司几百个 PostgreSQL 实例，建立了相应的运维监控体系。
  - 使用 Nagios + Zabbix 建立监控体系，制定数据库使用规范，通过 saltstack 管理维护。
  - 通过 pgbouncer+keepalived+haproxy 实现failover/load balance。
  - 把数据库一些状态表信息例如索引使用次数，数据库大小等通过 Nagios 收集画图，方便看到历史信息排错。
  - 把数据库的查询 SQL 情况放到 Elastic Search 引擎，方便排查慢查询，频繁的查询等。
  - 使用 Pacemaker + Etcd 实现集群集中部署和管理。
- ✳️ 广告系统：带领团队负责公司的 CPM/CPC 广告系统，日请求量达x亿，年收入x亿。
  - 熟悉广告系统的各必备模块，例如广告展示引擎，防作弊，点击服务，计费体系，广告售卖逻辑等。
  - 使用高性能的 Nginx+Lua+Solr/Lucene做展示模块，计费结算体系基于 SQL 存储过程。
- ✳️ 度假无线团队：占度假部门收入的 40%。
  - 主要负责去哪儿 APP 里面度假模块（iOS, Android）， HTML5 版本的度假网站。
  - 使用 SpringMVC/MyBatis/Duboo 这些搭建。

主要开发语言比较多，基本主流的都用了，包括 Perl/Lua/Python/Java/SpringMVC/MyBatis/Dubbo/SQL 等。

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
