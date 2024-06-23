# Localization
# 本地化
This is localization folder of THAIC.
Following is the introduction of how to add a new language for THAIC.
这是东方梦摇篮的本地化文件夹。
以下是关于如何为梦摇篮添加一个新语言的介绍。

# Steps to Add a New Language for THAIC
# 为东方梦摇篮添加一个新语言的步骤

## Step 1
## 步骤 1
Create a folder named by your language. 
Then copy all the files from one of other folders.
创建一个以你的语言命名的文件夹。
然后从其他文件夹中的一个复制所有文件。

## Step 2
## 步骤 2
Find "lang_registration.lua" in "THlib" directory.
In this file, you need to call function `aic.l10n.init` with 3 arguments: formal_name(name of folder), simplified_name(write in 2 uppercase letters) and full_name(will be displayed in game).
This is a sample:
```
aic.l10n.init("zh_cn", "CH", "中文(CN)")
```
在THlib目录中找到“lang_registration.lua”。
在这个文件中，你需要使用3个参数调用函数`aic.l10n.init`：正式名称（文件夹的名称），简化名称（使用两个大写字母）和全名（将会在游戏中显示）。
这是一个例子：
```
aic.l10n.init("zh_cn", "CH", "中文(CN)")
```

## Step 3
## 步骤 3
Start your translation following the tips in the files.
根据文件中的提示开始你的翻译。
