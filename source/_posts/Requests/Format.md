---
layout: default
id: Format
title: 格式
---

## 格式

路由可以通过`format`参数指定接受的request请求或者返回的response的数据格式。参数的值为指定HTTP媒体类型的一个字符串。例如，JSON数据参数值为`application/json`。

当路由指定的方法为带有请求体的方法（PUT, POST, DELETE, 和 PATCH），指定`format`属性之后，Rockt就会检测新来的请求的header中的`Content-Type`。只有请求的`Content-Type`和参数`format`中的值一直的时候才能匹配该路由。

请思考下面的例子：

```rust
#[post("/user", format = "application/json", data = "<user>")]
fn new_user(user: Json<User>) -> T { ... }
```

在`post`属性中`format`参数声明了，新来的请求中,仅仅为`Content-Type: application/json`才能匹配`new_user`路由。（参数`data`会在下一节中讲到）。

当路由指定的是没有请求体的方法（GET, HEAD, 和 OPTIONS），指定`format`参数之后，Rocket会检测新来的请求中header中的`Accept`。仅仅在header的`Accept`中指定的希望收到的媒体类型和`format`参数指定的一致的请求才会匹配。

请思考下面的例子：

```rust
#[get("/user/<id>", format = "application/json")]
fn user(id: usize) -> Json<User> { ... }
```

在`get`属性中的`format`参数指明了，在新来的请求中header中的`Accept`指定的媒体类型为`application/json`时才能匹配`user`。