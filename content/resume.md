---
title: “Resume”
date: 2019-02-12T15:14:28+08:00
tags: [“简历”, “resume”]
toc: false
comment: false
---

- [English version](/resume-en/)

## 联系方式

* 邮箱: wd@wdicc.com
* blog: https://wdicc.com/ ， github: https://github.com/wd

## 学历

北京航空航天大学 2002 年本科毕业，应用物理与应用电子技术专业。

## 个人介绍

* 十几年项目开发和管理经验，技术知识面比较广，熟悉大数据平台搭建，广告系统开发，数据库运维，电商系统开发等。
* 对系统架构拆分有丰富的经验，对代码高要求，有代码洁癖，有责任心，善于整合各种新技术到项目，提升项目开发质量和速度。
* 有日上亿请求高并发高性能系统的开发、设计和维护经验。
* 有从零组建团队的能力，有大型团队的组建和管理能力，有很强的沟通表达能力和团队合作精神。

## 工作经历
### 新晨航空（2017 - 现在），公司合伙人，技术和产品负责人
- 参与公司战略目标制定，制定和落实相应的产品和相应的技术落地方案，共计完成 6 个网站，3 个 APP(分别有iOS/Android) 的研发。
- 负责公司产研人员的招聘和团队组建工作，期间招聘产品技术和设计 10 人左右。
- 建立公司的项目开发/发布/测试的流程，建立公司业务报表和服务器监控体系。
- 进行相关的技术难点攻坚，新技术引入落地，项目架构设计，代码评审等工作。
- 目前公司年盈利 200 多万，已经基本收支平衡。

### 去哪儿网（2010 - 2016），高级技术总监
- 总共负责 4 个团队和方向的工作：大数据团队，PostgreSQL DBA 团队，广告系统开发团队，度假事业部无线开发团队。
- 招聘组建团队成员 30+ 人，负责人才培养考核，定期组织团队内培训与交流，注重人才梯队培养，培养了3-5名技术总监。
- 参与公司的校园招聘，技术人员培训，晋升评审，相关技术委员会制度规划和制定等工作。
- 参与产品需求评审，负责产品架构、技术选型和落地。
- 进行相关的技术难点攻坚，新技术引入落地，项目架构设计，代码评审等工作。参与和主导开发了很多项目，具体项目在后面详述。
- 在职期间，负责的业务线年收入 x 亿。

### 淘宝网（2009 - 2010），开发工程师

- 参与量子统计的开发。

### Yahoo 中国（2007 - 2009），SRE、数据统计

- 初期是战略数据平台部的 AppOPS (类似 SRE)，负责大概 100 台机器的运维。
- 后期参与开发，开发了一个基于 Nagios 的中心配置的监控插件，方便实现个性化的监控需求。
- 后面也参与了一些统计工作。

主要开发语言是 PHP，Perl，Shell。

### 深圳乐酷（2005 - 2007），运维

- 主要做运维工作，一个人维护大概几十台服务器，基于 nagios 和短信猫建立了公司的监控和报警通知服务，以及服务监控和自恢复功能，当时还做了通过短信控制重启服务的功能。

### 宇航出版社（2002 - 2005），编辑、运维

- 刚加入时做计算机图书的编辑工作，后面出于兴趣同时开始维护公司的网站和商城服务器，建立了公司的商城和邮件服务器等。

## 项目介绍
### 酷飞/空管在线 APP（2017 - 现在）
- 使用了 Redux/Reselect/Saga/TypeScript 等流行的工具框架，实现一次开发多个平台使用。
- RN 版本一路从 0.4x 升级到了现在的 0.6x，解决升级过程中出现的各种不兼容问题。
- 主导进行了两次大的升级：项目迁移到了 redux 统一了状态管理，和支持了 TypeScript。
- 开发了 10 余款 RN 扩展自用，部分开源到了 github。
- 项目使用 Ansiable + Fastlane 打包发布，开发了一个发布到 firim 的 Falstlane 扩展。
- 使用了 Bugly/CodePush 做自动升级，还使用了极光推送，友盟统计，微信微博登陆等常用的服务。

主要开发语言是 React Native/Objective C/Java/Ruby/Shell/JavaScript/TypeScript 等。

### 新晨后端项目（2017 - 现在）
- 使用 Django/Celery/Channels/nginx/gunicorn/stomp.py/supervisord，和 PostgreSQL/PostGIS+Redis 等工具和数据库。
- 搭建了项目初始的开发框架，制定代码/权限验证/接口/model命名/项目打包发布规范等。通过 Gitlab trigger 自动检查提交的代码规范和跑测试用例。
- 使用 Channels + PostgreSQL trigger/notify 实现了基于 websocket 的通知实时下发服务。
- 项目使用 Ansiable + docker 发布，前几天花了 2 天时间迁移到了流行的 kubernetes 上面。
- 监控预警服务器指标使用 AWS Cloudwatch，应用部分通过 Prometheus + Alertmanager 实现。
- 定时任务跑业务报表和备份数据库，备份基于 basebackup + xlog 实现恢复到任意时间点。
- 目前 Django/PostgreSQL/Channels 等都跟着官方升级到了最新版本。

主要开发语言是 Python/Shell/SQL 等。

### 大数据平台（2011 - 2017）
- 设计了 Qunar 用户唯一标识，搭建了 Beacon/track/click 服务，开创了 Qunar 统计的标准化。
- 搭建了公司第一套 hadoop 集群(3节点)，可以方便的扩展提升计算能力。
- 组建了度假事业部的统计团队，搭建基于 Greenplum 集群的数据仓库，建立了使用 flume/logstash/kafka/storm/hadoop 一整套 ETL 方案处理度假事业部的数据。
- 设计开发了数据追踪系统 skynet 以支持 native/h5/RN 混合开发模式下的统计整合，前端使用的是 Nginx + lua + Fluentd + ruby，数据最终都会进数据仓库。
- 设计开发了业务报表系统，可以方便数据工程师简单的通过配置给产品/运营/决策层做各种报表。
- 完成了度假业务供应商的结算/对账，和产出结算报表工作。

主要开发语言是 Lua/Shell/Ruby/Java/Haoop/Hive/SQL 等。

### PostgreSQL DBA（2011 - 2017）
- 带领团队维护公司上百个 PostgreSQL 实例，规范打包/安装/配置/备份/监控/维护等工作，制定数据库使用规范普及给开发人员。
- 使用 Nagios + Zabbix 建立监控体系，以及通过 saltstack 管理和完成所有的配置文件和部署。
- 通过 pgbouncer + keepalived + haproxy 实现 Failover/Load balance。
- 把数据库一些状态表信息例如索引使用次数，数据库大小等通过 Nagios 收集画图，方便看到历史信息排错。
- 把数据库的查询 SQL 情况放到 ElasticSearch 引擎，方便排查慢查询，频繁的查询等。
- 使用 Pacemaker + Etcd 实现集群集中部署和管理。

主要开发语言是 Shell/Python/Perl 等。

### CPC/CPM 广告系统（2011 - 2017）
- 带领团队开发公司的 CPM/CPC 广告系统，日请求量达 x 亿，年收入 x 亿。
- 我直接参与开发了其中的点击计费模块（Apache + perl + redis），QP + Dumper 模块（nginx + lua + python）。
- 对于广告系统的各必备模块也都比较熟悉，例如广告展示引擎，反作弊，竞价计费日结等技术实现逻辑，以及业务方面例如广告竞价定向等售卖逻辑等。
- 使用高性能的 Nginx + Lua + Solr/Lucene 做展示模块，计费结算基于 SQL 存储过程。

主要开发语言是 Shell/Python/Perl/Lua/Java/SQL 等。

### 度假无线 APP 和后端（2012 - 2017）
- 主要负责去哪儿 APP 里面度假模块（iOS, Android）， 和 HTML5 版本的度假网站。
- App 使用 Objective C 和 Java 开发，后面大部分页面都切换到了 React Native 开发，方便快速开发和迭代。
- 后端使用 SpringMVC/MyBatis/Duboo 等 Java 相关技术栈。
- 度假无线团队收入占度假部门收入的 40%。

主要开发工具包括 Java/SpringMVC/MyBatis/Dubbo/Objective C 等。

### 量子统计（2009 - 2010）
- 量子统计前身是雅虎统计，我参与了量子统计的一个大的改版，针对商家后台功能的开发工作。
- 前端展示主要是使用的是 JavaScript/HTML/Jquery 这些。
- 后端用的是 php，统计数据是基于 hive/hadoop 产生的，当时分析的是整个淘宝平台所有商家的数据，指标包括店铺访问量，用户来源分析，跳出率，广告效果等。

主要开发工具包括 Hadoop/Hive/Java/JavaScript 等。
