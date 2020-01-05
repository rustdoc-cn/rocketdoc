---
layout: default
id: Launching
title: 启动
---

## 启动

既然Rocket知道了路由，您就可以告诉Rocket通过该`launch`方法开始接受请求。该方法启动服务器并等待传入的请求。当请求到达时，Rocket会找到匹配的路由，并将请求分派给路由的处理程序。

我们通常`launch`从`main`函数调用。我们完整的*hello,world！*因此，应用程序如下所示：

```rust
#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

#[get("/world")]
fn world() -> &'static str {
    "Hello, world!"
}

fn main() {
    rocket::ignite().mount("/hello", routes![world]).launch();
}
```

请注意`#![feature]`行：这告诉Rust我们正在选择夜间发布渠道中可用的编译器功能。该行通常**必须**位于板条根`main.rs`中。我们还通过`#[macro_use] extern crate rocket`导入了`rocket`crate及其所有宏。最后，我们在`main`函数中调用`launch`方法。

运行该应用程序，控制台显示：

```shell
🔧  Configured for development.
    => address: localhost
    => port: 8000
    => log: normal
    => workers: [logical cores * 2]
    => secret key: generated
    => limits: forms = 32KiB
    => keep-alive: 5s
    => tls: disabled
🛰  Mounting '/hello':
    => GET /hello/world (world)
🚀  Rocket has launched from http://localhost:8000
```

如果我们访问`localhost:8000/hello/world`，则会看到`Hello, world!`，与我们预期的完全一样。

`cargo run`可以在[GitHub上](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/hello_world)找到该示例的完整包装箱的版本。您可以在[GitHub examples目录中](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/)找到许多其他完整的示例，涵盖了Rocket的所有功能。