---
title: “Resume”
date: 2019-02-12T15:14:28+08:00
tags: [“简历”, “resume”]
toc: false
comment: false
---

- [PDF](/resume-en.pdf)
- [中文版](/resume/)

## About Me

I have worked in many positions, and have strong knowledge of front-end/back-end developing, Linux system maintain, database maintain, network, security, etc.

Preferred jobs:

- Advertise delivery system developer or team manager (Full time)
- SRE (Full time, or remote)
- DBA (Full time, or remote)

Preferred locations:

- Singapore
- Beijing
- London
- US

Contact me: `wd # wdicc.com`.

## Experience

### BrilliantAero.com (2017 - present), Co-founder, tech and product leader

Build and lead both engineer team and product team, wrote application for iOS, Android, setup website. Mainly using JavaScript, Python, and React Native related technology.

- Team: About 10, include front-end/back-end developers, UX/UE designer, product manager.
- Setup our office environments, like router, GitLab, file server, Wiki, VPN, DNS server and many other related services.
- Back-end: use frameworks like Django, Celery, Channels to build our API service. The databases were PostgreSQL and Redis.
   - After setting up the framework, I didn’t take part in too much coding in the follow-up, mainly controlling the architecture.
   - Use Celery to run timed tasks, and Redis as the broker.
   - Use Channels to run the WebSocket service, to broadcast notifications to the client(Web/APP) in real-time.
   - Use PostGIS to do some geographical location calculations.
- Automated deployment: Use Ansiable for automated deployment solutions, including backend deployment and APP building and packaging.
   - We use Docker to run our backend services.
- Front-end APP: Established the RN react development architecture, used popular tools such as Reduc/Reselect/Saga/TypeScript. We used RN to develop two mobile APPs, and one Pad APP. They all packaged using Fastlane.
   - The code architecture has been changed and migrated to TypeScript.
   - I spent most of time on building the RN APP, fix bugs on various clients, and third-party modules adaptations, there are lots of trivial problems.
- Front-end WEB: I didn’t have taken part much, we used frameworks like Vue+Mobx and React+Redux, I only fixed some issues on using of Vue.
- Android Pad and PC system customization.
   - Made some customization on Lenovo’s Pads system to prevent the Pad from being abused.
   - Made a customized Linux system for our customer’s PC based on Porteus, which can limit use, prevent system modifications, and easily restore the system.
   - I have also tried customizing the Openwrt router system to implement the limits, but this solution was unused in the end.
- Other things such as domain name application filing, server application initialization and deployment, database backup.


### Qunar.com (2010 - 2016), senior technical director

- Team: More than 30 when leaving.
- Build up a team to analyze data for Vacation BU, including log collection, ETL, and displays.
   - Designed and promoted the unique identification of Qunar users and built and maintained a Greenplum cluster as our data warehouse.
   - Developed a data tracking system using Nginx + fluentd.
   - Developed a Dashboard system for data engineers to make various reports for product managers.
- Build up a team to operation and maintain over hundred PostgreSQL servers, and setup the monitor system.
   - The monitoring system initially used Nagios. After encountering performance issues and use Gearman to expanded to multiple nodes didn’t solve the problem very well, I finally switched it to Zabbix, the features of passive discovery and passive checking solved the performance issue.
   - By collecting some useful information of the databases such as the number of times the index is used, the size of the databases and tables, we can provide the historical information for troubleshoot.
   - By collecting the queries running in the database to Elastic Search, engineers could use the tool to find slow or frequently queries themselves.
   - Tried to use Pacemaker + Etcd to implement a centralized cluster for PostgreSQL deployment and management, but didn’t finish yet.
- Developed and maintained the CPM and CPC AD delivery system, the page view is about 1 billion per day at the moment.
   - Familiar with every components of the advertising delivery system, such as the AD display engine, anti-cheating, click service, billing system, and adverting sales logic.
   - During the period, migrated the Ad display engine system which based on Apache+Lua to Nginx+lua(Openresty), improved performance and stability.
- Mobile App and website for ticket booking related business.

### Taobao.com (2009 - 2010), software engineer.

Analyze data for linezing.com which collecting data/logs from taobao.com using Hadoop/Hive, and some development work for the user website. Tech stack: SQL, Java, Shell, HTML, JavaScript.

### Yahoo China (2007 - 2009), SRE

Wrote a Nagios plugin to centralize monitoring. Basic SRE duty.

## Education

BeiHang University(AKA BUAA), China, bachelor (1998-2002)
