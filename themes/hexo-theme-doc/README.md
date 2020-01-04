# hexo-theme-doc

这是一个hexo的一个模板，

[hexo官网](https://hexo.io/zh-cn/)

[hexo文档](https://hexo.io/zh-cn/docs/)

# 开始使用

1. 新建hexo项目
2. 在hexo项目的`themes`文件夹下引入`hexo-theme-doc`模板：`$ cd themes && git clone https://github.com/rustdoc-cn/hexo-theme-doc`

# 配置

修改hexo项目的配置文件：`_config.yml`

1. 修改`title`
2. 修改`url`
3. 修改`root`
4. 配置`permalink: :category/:title.html`
5. 配置`default_category: ''`
6. 配置`theme: hexo-theme-doc`

# 新建页面

在hexo项目`source`目录的`_data`目录下新建`hello-world.md`，内容如下：

```markdown
---
layout: default
id: hello-world
title: 你好世界
indexshow: true
categories:
- introduction
---

This is our what it is markdown file

- one
- two
- three
```

"`---`" 包裹的内容为页面配置文件，其中`id`是markdown文件名，也是将会生成的静态文件名；`title`是显示标题名；`indexshow`是默认首页页面，为`true`则设为首页；`categories`是分类，也可以删除`categories`配置，并在`_data`目录下建立相应的文件夹，如：`introduction`，将`hello-world.md`移到`introduction`下。

"`---`" 以下是markdown内容。

# 导航菜单

在hexo项目`source`目录下新建`_data`文件夹，在`_data`目录下新建`nav.yml`文件，内容如下：

```yaml
- category: introduction
  title: 介绍
  items:
  - id: hello-world
    title: 你好世界
  - id: hello-world2
    title: 你好世界
- category: introduction2
  title: 介绍2
  items:
  - id: hello-world
    title: 你好世界
  - id: hello-world2
    title: 你好世界
```

`category`为分类，与页面配置的分类一致；`title`为分类名；`items`为页面列表，保持与页面一致。

# 启动

`$ hexo s`查看效果。

