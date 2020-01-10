---
layout: default
id: Finished-Product
title: 成品
---

# Pastebin 教程

为了让您了解真正的Rocket应用程序的外观，本指南的这一节是有关如何在Rocket中创建Pastebin应用程序的教程。pastebin是一个简单的Web应用程序，允许用户上载文本文档，以后再通过特殊URL对其进行检索。它们通常用于共享代码段，配置文件和错误日志。在本教程中，我们将构建一个简单的pastebin服务，该服务允许用户从其终端上载文件。该服务将使用上载文件的URL进行回复。

## 成品

您将要构建的应用程序的完整版本已在[paste.rs中](https://paste.rs/)实时部署。随意使用该应用程序，以了解其工作方式。例如，要上传名为的文本文档`test.txt`，您可以执行以下操作：

```shell
curl --data-binary @test.txt https://paste.rs/
# => https://paste.rs/IYu
```

成品由以下路由组成：

- index：**`GET /`**-返回一个简单的HTML页面，其中包含有关如何使用该服务的说明
- 上传：**`POST /`**-接受请求正文中的原始数据，并使用包含正文内容的页面的URL进行响应
- 检索：**`GET /<id>`**-检索ID为的粘贴的内容`<id>`

