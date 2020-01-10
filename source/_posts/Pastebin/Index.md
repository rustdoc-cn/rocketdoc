---
layout: default
id: Index
title: 主页
---

## 主页

我们将创建的第一条路由是该`index`路由。这是用户首次访问该服务时将看到的页面。因此，路线应填写表单的请求`GET /`。我们通过将以下`index`函数添加到来声明路由及其处理程序`src/main.rs`：

```rust
#[get("/")]
fn index() -> &'static str {
    "
    USAGE

      POST /

          accepts raw data in the body of the request and responds with a URL of
          a page containing the body's content

      GET /<id>

          retrieves the content for the paste with id `<id>`
    "
}
```

这将`index`请求的路由声明`GET /`为返回具有指定内容的静态字符串。Rocket将采用字符串并将其作为带有的完整HTTP响应的正文返回`Content-Type: text/plain`。您可以[在Responder特性](https://api.rocket.rs/v0.4/rocket/response/trait.Responder.html)的[API文档中](https://api.rocket.rs/v0.4/rocket/response/trait.Responder.html)了解有关Rocket如何制定响应的更多信息。

请记住，在Rocket向其分发请求之前，首先需要安装路由。要挂载`index`路由，请修改main函数，使其显示为：

```rust
fn main() {
    rocket::ignite().mount("/", routes![index]).launch();
}
```

现在，您应该可以使用`cargo run`该应用程序并访问根路径（`/`）以查看正在显示的文本。