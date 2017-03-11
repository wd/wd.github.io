+++
title = "octopress and gitcafe"
date = "2013-06-12T21:30:00+08:00"
comments = true
tags = ["linux"]
description = ""
+++

ocotpress 支持 github，不过 github 的 pages 貌似被墙了，且速度慢。gitcafe 速度还不错，也支持 pages，刚好可以切换过去。我只是简单粗暴的修改了几个文件。

``` diff
diff --git a/.gitignore b/.gitignore
index 85ed25d..5858b25 100644
--- a/.gitignore
+++ b/.gitignore
@@ -12,3 +12,4 @@ source/stylesheets/screen.css
 vendor
 node_modules
 .themes/fabric/
+gitcafe
diff --git a/Rakefile b/Rakefile
index 53072e5..62061e0 100644
--- a/Rakefile
+++ b/Rakefile
@@ -27,6 +27,9 @@ new_post_ext    = "markdown"  # default new post file extension when using the n
 new_page_ext    = "markdown"  # default new page file extension when using the new_page task
 server_port     = "4000"      # port for preview server eg. localhost:4000

+gitcafe_dir      = "gitcafe"
+gitcafe_branch   = "gitcafe-pages"
+

 desc "Initial setup for Octopress: copies the default theme into the path of Jekyll's generator. Rake install defaults to rake install[classic] to install a different them
 task :install, :theme do |t, args|
@@ -219,7 +214,7 @@ end
 ##############

 desc "Default deploy task"
-task :deploy do
+task :deploy_old do
   # Check if preview posts exist, which should not be published
   if File.exists?(".preview-mode")
     puts "## Found posts in preview mode, regenerating files ..."
@@ -231,6 +226,31 @@ task :deploy do
   Rake::Task["#{deploy_default}"].execute
 end

+desc "deploy gitcafe"
+task :deploy do
+  # Check if preview posts exist, which should not be published
+  if File.exists?(".preview-mode")
+    puts "## Found posts in preview mode, regenerating files ..."
+    File.delete(".preview-mode")
+    #Rake::Task[:generate].execute # 这个地方每次都会 generate 我一般喜欢先 generate 本地看好没问题之后再 deploy，所以就注释掉了
+  end
+
+  puts "## Deploying branch to Gitcafe Pages "
+  puts "\n## copying #{public_dir} to #{gitcafe_dir}"
+  cp_r "#{public_dir}/.", gitcafe_dir
+  cd "#{gitcafe_dir}" do
+    system "git add ."
+    system "git add -u"
+    puts "\n## Commiting: Site updated at #{Time.now.utc}"
+    message = "Site updated at #{Time.now.utc}"
+    system "git commit -m \"#{message}\""
+    puts "\n## Pushing generated #{gitcafe_dir} website"
+    system "git push origin #{gitcafe_branch} --force"
+    puts "\n## Gcafe Pages deploy complete"
+  end
+end
+
+
 desc "Generate website and deploy"
 task :gen_deploy => [:integrate, :generate, :deploy] do
 end
```

然后需要在 octopus 根目录 clone 一下你的 gitcafe 项目到 gitcafe 目录
``` bash
$ git clone git@gitcafe.com:wd/wd gitcafe
....
```

然后就可以试试看 `rake generate` , `rake preview`, `rake deploy` 了。
