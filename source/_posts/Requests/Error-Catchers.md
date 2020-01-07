---
layout: default
id: Error-Catchers
title: 你好，世界！
---

## 错误捕捉器

路由可能由于多种原因而失败。这些包括：

- 防护失败.
- 处理程序返回而[`Responder`](https://rocket.rs/v0.4/guide/responses/#responder)失败。
- 没有匹配的路线。

如果出现上述任何情况，Rocket将向客户端返回一个错误。为此，Rocket调用与错误状态代码对应的捕捉器。捕捉器就像一条路线，只是它只处理错误。Rocket为所有标准HTTP错误代码提供默认的捕获器。若要重写默认捕获器，或为自定义状态代码声明捕获器，请使用[`catch`](https://api.rocket.rs/v0.4/rocket_codegen/attr.catch.html) 属性，该属性接受与要捕获的HTTP状态代码相对应的单个整数。例如，要为`404 Not Found`声明一个捕获器，您可以编写：

```rust
#[catch(404)]
fn not_found(req: &Request) -> T { .. }
```

与路由一样，返回类型（这里是`T`）必须实现 `Responder`.。具体的实现可能如下：

```rust
#[catch(404)]
fn not_found(req: &Request) -> String {
    format!("Sorry, '{}' is not a valid path.", req.uri())
}
```

与路由一样，Rocket需要知道一个捕获器之前，它是用来处理错误。这个过程被称为“注册”一个捕获器，类似于挂载路由：通过 [`catchers!`](https://api.rocket.rs/v0.4/rocket_codegen/macro.catchers.html) 宏产生捕获器列表调用 [`register()`](https://api.rocket.rs/v0.4/rocket/struct.Rocket.html#method.register)方法。添加上面声明的404 捕获器的调用如下所示：

```rust
rocket::ignite().register(catchers![not_found])
```

与路由请求处理程序不同，捕获器只接受零个或一个参数。如果catcher接受一个参数，那么它必须是 [`&Request`](https://api.rocket.rs/v0.4/rocket/struct.Request.html) 类型GitHub上的[错误捕捉器示例](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/errors)充分说明了它们的使用。