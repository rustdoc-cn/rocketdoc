---
layout: default
id: Methods
title: 方法
---

# 请求 Requests

路由属性和函数签名一起指定请求必须为真的内容，才能调用路由的处理程序。你已经看到一个这样的例子：

```rust
#[get("/world")]
fn handler() { .. }
```

这个路由指定了它仅匹配到`/world`的`GET`请求。Rocket在调用处理器之前会验证这一点。当然，你可以做的不仅仅是指定请求的路径和方法。除了其它事情，Rocket还可以自动地进行数据验证：

- 动态路径段的类型。
- 路由动态参数的个数。
- 请求体的数据类型。
- 查询字符串，表单和表单值的类型。
- 请求的预期传入或传出格式。
- 任何用户定义的安全验证策略。

路由属性和函数签名共同描述了这些验证规则。Rocket的代码生成器实际担任了验证这些数据的工作。这一节主要讲怎样使用Rocket来进行这些数据验证和其他验证。

## 请求方法 Methods

Rocket route属性可以是`get`、`put`、`post`、`delete`、`head`、`patch`或`options`中的任意一个，每个属性都对应于要匹配的HTTP方法。例如，以下属性将与根路径的POST请求匹配：

```rust
#[post("/")]
```

这些属性的语法在 [`rocket_codegen`](https://api.rocket.rs/v0.4/rocket_codegen/attr.route.html) API文档中正式定义。

### HEAD请求

当存在一个GET路由时，Rocket会自动处理对应路由的`HEAD`请求。如果能够匹配的上，Rocket将原来的响应体过滤掉，作为`HEAD`路由的响应。你也可以为`HEAD`请求单独声明一个路由； Rocket并不会干涉你程序中对`HEAD`请求的处理。

### 重解析

因为浏览器只能发送`GET`和`POST`请求，Rocket在特定条件下会*重解析*请求的方法。如果`POST`请求的`header`里包含`Content-Type:application/x-www-form-urlencoded`，并且表单的第一个字段名为`_method`，值为HTTP请求的合法方法（例如`"PUT"`）,Rocket将会以这个值中的方法，作为这次请求的方法。这会使Rocket应用程序可以提交非`POST`的表单。[例子todo](https://github.com/SergioBenitez/Rocket/tree/v0.3.13/examples/todo/static/index.html.tera#L47) 里面用了这个特性，通过网页表单提交`PUT`和`DELETE`请求。