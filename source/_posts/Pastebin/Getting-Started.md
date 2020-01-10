---
layout: default
id: Getting-Started
title: 入门
---

## 入门

让我们开始吧！首先，创建一个新的Cargo二进制项目，名为`rocket-pastebin`：

```shell
cargo new --bin rocket-pastebin
cd rocket-pastebin
```

然后将通常的Rocket依赖项添加到`Cargo.toml`文件中：

```toml
[dependencies]
rocket = "0.4.2"
```

最后，创建一个基本的Rocket应用程序以在中运行`src/main.rs`：

```rust
#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

fn main() {
    rocket::ignite().launch();
}
```

通过运行应用程序确保一切正常：

```shell
cargo run
```

此时，我们尚未声明任何路由或处理程序，因此访问任何页面都将导致Rocket返回**404**错误。在本教程的其余部分中，我们将创建三个路由和随附的处理程序。