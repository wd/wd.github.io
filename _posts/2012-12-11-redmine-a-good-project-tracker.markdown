---
layout: post
title: "redmine-a-good-project-tracker"
date: 2012-12-11 14:53
comments: true
tags: linux
---
其实很早，大概2，3年前就听说了 redmine 了，不过他环境是 ruby 的，一直没有勇气去搭一个环境。现在项目人多了，bug 阿 feature 阿，就需要记录一下了，因为有些事情不记录下来总是会忘记。之前是尝试通过 wiki ＋ bugfree 来记录的，bugfree 记录在提测之后的一些问题，wiki 记录一些 feature request 什么的。bugfree 我们没权限管理，wiki 记录又不方便，然后我就又想起来 redmine 了。

哦对，其实公司还提供了一个 jira 给大家用，我用了几次我觉得那玩意太难用了，和那个 confluence 的 wiki 一样难用。

本身搭建没什么难度，编译一个 ruby，然后 gem 安装几个包，下载 redmine，使用 rake 命令操作就好了。启动他的 server 之后，就可以访问了。下面几个东西是我花了一些时间配置的。

## 和 ldap 集成

在 redmine 的设置里面，本身是有一项和 redmine 集成的功能的，设置 basedn，和下面的 attributes 内容（sAMAccountName,givenName,sN,mail)就可以了。点测试，得能通过。

在我这里，光设置这个还不行，还需要 hack 一段代码。注意下面的那个 `@xxxx.com`，这个对应你自己的。

``` diff
ndex: app/models/auth_source_ldap.rb
===================================================================
--- app/models/auth_source_ldap.rb	(版本 10947)
+++ app/models/auth_source_ldap.rb	(工作副本)
@@ -135,11 +135,12 @@
   # Get the user's dn and any attributes for them, given their login
   def get_user_dn(login, password)
     ldap_con = nil
-    if self.account && self.account.include?("$login")
-      ldap_con = initialize_ldap_con(self.account.sub("$login", Net::LDAP::DN.escape(login)), password)
-    else
-      ldap_con = initialize_ldap_con(self.account, self.account_password)
-    end
+    ldap_con = initialize_ldap_con(login + '@xxxxx.com', password)
+    #if self.account && self.account.include?("$login")
+    #  ldap_con = initialize_ldap_con(self.account.sub("$login", Net::LDAP::DN.escape(login)), password)
+    #else
+    #  ldap_con = initialize_ldap_con(self.account, self.account_password)
+    #end
     login_filter = Net::LDAP::Filter.eq( self.attr_login, login )
     object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
     attrs = {}
@@ -149,6 +150,8 @@
       search_filter = search_filter & f
     end
 
+    logger.debug "------------get_user_dn #{login} #{self.base_dn} #{search_filter} #{search_attributes}" if logger && logger.debug?
+
     ldap_con.search( :base => self.base_dn,
                      :filter => search_filter,
                      :attributes=> search_attributes) do |entry|
```

总之登陆验证的代码关键就在这里了，可以自己做尝试，建议先写最简单的代码测试。比如

``` ruby
require 'rubygems'
require 'net/ldap'

ldap = Net::LDAP.new :host => 'qunarldap.corp.qunar.com',
     :port => 389,
     :auth => {
           :method => :simple,
           :username => "wd@xxxx.com",
           :password => "pwd"
     }

filter = Net::LDAP::Filter.eq("sAMAccountName","wd*")
object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )
search_filter = filter & object_filter

treebase = "你的 basedn" #

attr = ["dn", "givenName", "sN", "mail"]

ldap.search(:base => treebase, :filter => search_filter, :attributes => attr ) do |entry|
  puts "DN: #{entry.dn}"
  entry.each do |attribute, values|
    puts "   #{attribute}:"
    values.each do |value|
      puts "      --->#{value}"
    end
  end
end

p ldap.get_operation_result
```

搞定这块，就可以通过 ldap 用户直接登陆了，登陆会自动创建用户。

## 通过回复邮件自动创建和更新 issue

用过 bugzilla 的都知道，可以通过邮件回复的方式来 comment issue。redmine 也提供了这个功能。我这种对 mail 服务器无权的用户，只能申请一个邮箱专门做这个事情了。公司邮箱是 exchange 的，没有打开 imap。redmine 只提供了 imap，pop 之类的方式。好在还有 davmail。先配置好一个 davmail，然后通过 imap 来做这个事情，imap 比 pop 好处多很多，比如可以指定 inbox，可以 move 到 read 之类，就不多说了。

crontab 指令大概如下。

``` bash
#!/bin/bash

LOG=/export/redmine/log/mail_recieve.log

echo "start $(date)" >> $LOG

/usr/local/ruby/bin/rake --silent -f /export/redmine/Rakefile redmine:email:receive_imap RAILS_ENV="production" host=localhost username=abc password=def port=1143 move_on_success=read move_on_failure=failed unknown_user=accept >> $LOG 2>&1

echo "end $(date)" >> $LOG
```

不过如果 redmine 就这么简单就搞定的话，那我也没必要单独拿出来掰了。关键是，通过 imap 死活就是不行。只好又看了一下代码。

``` diff
Index: lib/redmine/imap.rb
===================================================================
--- lib/redmine/imap.rb	(版本 10947)
+++ lib/redmine/imap.rb	(工作副本)
@@ -30,8 +30,9 @@
         imap.login(imap_options[:username], imap_options[:password]) unless imap_options[:username].nil?
         imap.select(folder)
         imap.search(['NOT', 'SEEN']).each do |message_id|
-          msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
-          logger.debug "Receiving message #{message_id}" if logger && logger.debug?
+          #msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
+          msg = imap.fetch(message_id,'BODY[]')[0].attr['BODY[]']
+          logger.debug "Receiving message #{message_id}, msg:\n#{msg}" if logger && logger.debug?
           if MailHandler.receive(msg, options)
             logger.debug "Message #{message_id} successfully received" if logger && logger.debug?
             if imap_options[:move_on_success]
```

这里把那个 RFC822 改成 BODY[] 就好了，入丝般润滑。。。

## 过滤掉邮件回复的垃圾内容

邮件回复 ok 之后，紧跟着问题就是，他会把整封邮件都作为回复记录进去，这个太恶心了。还好他提供了设置，在 email notification 选项里面，配置一个 email header `--Reply above this line--`，在 incoming mail 里面配置一个 Truncate emails after one of these lines `--Reply above this line--`，他就会截取这个字符前面的内容了。

不过还有问题就是，一般邮件回复都开头都是个 `On xxxx xxx wrote:`，这个他不会截掉，那就再 hack 一下。。

``` diff
--- app/models/mail_handler.rb	(版本 10947)
+++ app/models/mail_handler.rb	(工作副本)
@@ -463,9 +464,12 @@
 
   # Removes the email body of text after the truncation configurations.
   def cleanup_body(body)
-    delimiters = Setting.mail_handler_body_delimiters.to_s.split(/[\r\n]+/).reject(&:blank?).map {|s| Regexp.escape(s)}
+    #delimiters = Setting.mail_handler_body_delimiters.to_s.split(/[\r\n]+/).reject(&:blank?).map {|s| Regexp.escape(s)}
+    delimiters = Setting.mail_handler_body_delimiters.to_s.split(/[\r\n]+/).reject(&:blank?).map {|s| s}
+
     unless delimiters.empty?
       regex = Regexp.new("^[> ]*(#{ delimiters.join('|') })\s*[\r\n].*", Regexp::MULTILINE)
+      #regex = Regexp.new("(^[> ]*(#{ delimiters.join('|') })\s*[\r\n].*)|(On (.*)wrote:[\r\n].*)", Regexp::MULTILINE)
       body = body.gsub(regex, '')
     end
     body.strip
```

这里搞定之后，在那个 Truncate emails after one of these lines 里面就可以写正则了，增加一行 `On (.*)wrote:`，然后就可以了。

## code review

增加了一个 code review 插件，已有项目需要在项目的模块里面启用。并且需要 admin 在角色配置里面，给相应角色增加 code review 的权限。不过貌似这插件不太好用，只能一行一行来。
