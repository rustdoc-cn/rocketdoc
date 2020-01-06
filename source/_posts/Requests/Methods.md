---
layout: default
id: Methods
title: 方法
---

## 请求 Requests

路由属性和函数签名一起指定请求必须为真的内容，才能调用路由的处理程序。你已经看到一个这样的例子：

```rust
#[get("/world")]
fn handler() { .. }
```

此路由表明它仅与`GET`对该`/world`路由的请求匹配。Rochet确保在`handler`调用之前是这种情况。当然，除了指定请求的方法和路径之外，您还可以做更多的事情。除其他外，您可以要求Rocket自动验证：

- 动态路径段的类型。
- *几个*动态路径段的类型。
- 传入正文数据的类型。
- 查询字符串，表单和表单值的类型。
- 请求的预期传入或传出格式。
- 任何任意的，用户定义的安全性或验证策略。

路由属性和函数签名协同工作来描述这些验证。Rocket的代码生成负责实际验证属性。本节描述如何要求Rocket根据所有这些属性和更多属性进行验证。

## 请求方法 Methods

Rocket route属性可以是`get`、`put`、`post`、`delete`、`head`、`patch`或`options`中的任意一个，每个属性都对应于要匹配的HTTP方法。例如，以下属性将与根路径的POST请求匹配：

```rust
#[post("/")]
```

这些属性的语法在 [`rocket_codegen`](https://api.rocket.rs/v0.4/rocket_codegen/attr.route.html) API文档中正式定义。

### HEAD请求

当存在`GET`排除匹配的路由时，Rocket会自动处理`HEAD`请求。它通过从响应中删除主体（如果有）来实现。您还可以通过声明`HEAD`请求的路由来专门处理`HEAD`请求；Rocket不会干扰应用程序显式处理的`HEAD`请求。

### 重新解释

由于HTML表单只能作为`GET`或`POST`请求直接提交，Rocket在某些条件下重新解释请求方法。如果`POST`请求包含内容类型为`application/x-www-form-urlencoded`的正文，并且表单的第一个字段的值为`name _method`和有效的`HTTP method name`（例如“`PUT`”），则该字段的值将用作传入请求的方法。这允许Rocket应用程序提交非`POST`表单。 [todo example](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/todo/static/index.html.tera#L47) 使用此功能提交web表单中的`PUT`和`DELETE`请求。