---
layout: default
id: Hello-World
title: 你好，世界！
---

## 你好，世界！

让我们编写第一个Rocket应用程序！首先创建一个新的基于二进制的Cargo项目，然后切换到新目录：

```shell
cargo new hello-rocket --bin
cd hello-rocket
```

现在，将Rocket添加为依赖项`Cargo.toml`：

```shell
[dependencies]
rocket = "0.4.2"
```

进行修改`src/main.rs`，使其包含Rocket `Hello, world!`程序的代码，如下所示：

```rust
#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

#[get("/")]
fn index() -> &'static str {
    "Hello, world!"
}

fn main() {
    rocket::ignite().mount("/", routes![index]).launch();
}
```

我们现在不会确切解释该程序的功能。我们将其留给指南的其余部分。简而言之，它将创建一条`index`路由，将该路由 *绑定* 在 `/` 路径上，然后启动应用程序。使用`cargo run`编译并运行程序。您应该看到以下内容：

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
🛰  Mounting '/':
    => GET / (index)
🚀  Rocket has launched from http://localhost:8000
```

访问`http://localhost:8000`以查看您的第一个Rocket应用程序在运行！

### 提示：不喜欢颜色或表情符号？

您可以通过将`ROCKET_CLI_COLORS`环境变量设置为`0`或`off`在运行Rocket二进制文件时禁用颜色和表情符号：

```shell
ROCKET_CLI_COLORS=off cargo run
```