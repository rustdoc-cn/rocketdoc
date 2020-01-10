---
layout: default
id: Ad-Hoc-Fairings
title: 临时 Fairings
---

## 临时 Fairings

在简单的情况下，实现此`Fairing`特征可能很麻烦。这就是为什么Rocket提供[`AdHoc`](https://api.rocket.rs/v0.4/rocket/fairing/struct.AdHoc.html)类型的原因，它可以通过简单的函数或闭合来创建整流罩。使用`AdHoc`类型非常简单：只需调用`on_attach`，`on_launch`，`on_request`，或`on_response`在构造函数`AdHoc`来创建一个`AdHoc`从函数或闭合结构。

例如，下面的代码创建一个`Rocket`带有两个注册的临时整流罩的实例。第一个是名为“ Launch Printer”的启动整流罩，仅打印一条消息，指示该应用程序即将启动。第二个名为“ Put Rewriter”（请求整理），将所有请求的方法重写为`PUT`。

```rust
use rocket::fairing::AdHoc;
use rocket::http::Method;

rocket::ignite()
    .attach(AdHoc::on_launch("Launch Printer", |_| {
        println!("Rocket is about to launch! Exciting! Here we go...");
    }))
    .attach(AdHoc::on_request("Put Rewriter", |req, _| {
        req.set_method(Method::Put);
    }));
```

