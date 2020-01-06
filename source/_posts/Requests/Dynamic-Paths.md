---
layout: default
id: Dynamic-Paths
title: 动态路径
---

## 动态路径

您可以通过在路由的路径中使用尖括号将变量名声明为动态路径段。例如，如果我们想说*你好！*不仅限于世界，我们可以声明一个路由，如下所示：

```rust
#[get("/hello/<name>")]
fn hello(name: &RawStr) -> String {
    format!("Hello, {}!", name.as_str())
}
```

如果将路由挂载在根（`.mount("/", routes![hello])`）上，则具有两个非空段的路径的任何请求（第一个段为`hello`）将被分派到该`hello`路由。例如，如果我们要访问`/hello/John`, 这个程序将响应 `Hello, John!`。

允许任意数量的动态路径段。路径段可以是任何类型，包括您自己的类型，只要该类型实现了[`FromParam`](https://api.rocket.rs/v0.4/rocket/request/trait.FromParam.html) 特征(trait)。我们称这些类型为参数保护。Rocket为许多标准库类型以及一些特殊的Rocket类型实现了[`FromParam`](https://api.rocket.rs/v0.4/rocket/request/trait.FromParam.html) 。有关提供的实现的完整列表，请参阅[`FromParam`](https://api.rocket.rs/v0.4/rocket/request/trait.FromParam.html)  API文档。这里有一个更完整的路线来说明各种用法：

```rust
#[get("/hello/<name>/<age>/<cool>")]
fn hello(name: String, age: u8, cool: bool) -> String {
    if cool {
        format!("You're a cool {} year old, {}!", age, name)
    } else {
        format!("{}, we need to talk about your coolness.", name)
    }
}
```

### 注意：Rocket将原始字符串与解码字符串分开键入。

您可能已经[`RawStr`](https://api.rocket.rs/v0.4/rocket/http/struct.RawStr.html)在上面的代码示例中注意到了一个陌生的类型。这是Rocket提供的一种特殊类型，代表HTTP消息中未经过滤，未经验证和未经解码的原始字符串。它的存在是为了验证串输入，通过类型，例如表示分离`String`，`&str`和`Cow`，从未经验证的输入，由下式表示`&RawStr`。它还提供了有用的方法来将未验证的字符串转换为已验证的字符串。

因为是`&RawStr` 实现了 [`FromParam`](https://api.rocket.rs/v0.4/rocket/request/trait.FromParam.html)，所以它可以用作动态段的类型，如上面的示例所示，其中的值表示可能未解码的字符串。相比之下，一个`String`保证被解码。应该使用哪个取决于您是要直接但潜在地不安全地访问字符串（`&RawStr`），还是要以分配为代价安全地访问字符串（`String`）。

### 多段路径

您也可以通过在路径中使用`<param..>`来匹配多个路径段。此类参数的类型（称为段防护）必须实现[`FromSegments`](https://api.rocket.rs/v0.4/rocket/request/trait.FromSegments.html)。段防护必须是路径的最后组成部分：段防护之后的任何文本都将导致编译时错误。

例如，以下路由与以`/page/`开头的所有路径匹配：

```rust
use std::path::PathBuf;

#[get("/page/<path..>")]
fn get_page(path: PathBuf) -> T { ... }
```

`path`参数中将提供`/page/`之后的路径。`PathBuf`的`FromSegments`实现确保路径不会导致[路径遍历攻击](https://www.owasp.org/index.php/Path_Traversal)。这样，一个安全可靠的静态文件服务器可以用4行实现：

```rust
#[get("/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/").join(file)).ok()
}
```

### 提示：Rocket使静态文件的服务更加容易！

如果需要从Rocket应用程序中提供静态文件，请考虑使用 [`rocket_contrib`](https://api.rocket.rs/v0.4/rocket_contrib/) 中的 [`StaticFiles`](https://api.rocket.rs/v0.4/rocket_contrib/serve/struct.StaticFiles.html) 自定义处理程序，这使得它非常简单：

`rocket.mount("/public", StaticFiles::from("/static"))`