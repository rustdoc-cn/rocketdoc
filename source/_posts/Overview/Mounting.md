---
layout: default
id: Mounting
title: 挂载
---

## 挂载

在Rocket可以向路由发送请求之前，必须先 *挂载* 该路由：

```rust
fn main() {
    rocket::ignite().mount("/hello", routes![world]);
}
```

`mount`方法接受以下输入：

1. 一个基本路径，作为一个其下包含路由列表的命名空间，这里的例子中为`"/hello"`。
2. 一个路由列表，通过`routes!`宏生成：这里的例子中为`routes![world]`，其中可包含多条路由：`routes![a, b, c]`。

这将通过`ignite`函数创建一个新的Rocket实例，并将`world`路由挂载到“/hello”路径，使Rocket知道该路径。对“/hello/world”的GET请求将指向world函数。

### **注意：**在许多情况下，基本路径将只是`"/"`。

### 命名空间

当在根目录以外的模块中声明路由时，安装时可能会遇到意外错误：

```rust
mod other {
    #[get("/world")]
    pub fn world() -> &'static str {
        "Hello, world!"
    }
}

#[get("/hello")]
pub fn hello() -> &'static str {
    "Hello, outside world!"
}

use other::world;

fn main() {
  // error[E0425]: cannot find value `static_rocket_route_info_for_world` in this scope
  rocket::ignite().mount("/hello", routes![hello, world]);
}
```

发生这种情况是因为`routes!`宏将路由的名称隐式转换为由Rocket的代码所生成的结构的名称。解决方案是改为使用命名空间路径引用路由：

```rust
rocket::ignite().mount("/hello", routes![hello, other::world]);
```

