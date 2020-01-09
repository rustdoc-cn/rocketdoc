---
layout: default
id: Managed-State
title: 管理状态
---

# 状态 State

许多Web应用程序都需要维护状态。这可以像维护访问次数计数器一样简单，也可以像需要访问作业队列和多个数据库一样复杂。Rocket提供了以安全，简单的方式实现此类交互的工具。

## 托管状态

维护状态的启用功能是托管状态。顾名思义，托管状态是Rocket为应用程序管理的状态。状态是按类型管理的：Rocket将最多管理给定类型的一个值。

使用托管状态的过程很简单：

1. 使用状态的初始值对与应用程序对应的`Rocket`实例调用`manage`。
2. 将 `State<T>` 类型添加到任何请求处理程序中，其中`T`是传递给的值的类型`manage`。

### **注意：**所有托管状态都必须是线程安全的。

由于Rocket自动为您的应用程序提供多线程，因此处理程序可以同时访问托管状态。结果，托管状态必须是线程安全的。感谢Rust，通过确保在托管状态下存储的值的类型实现`Send`+ 来检查此条件`Sync`。

### 添加状态

要指示Rocket管理应用程序的状态，请`Rocket`在的实例上调用[`manage`](https://api.rocket.rs/v0.4/rocket/struct.Rocket.html#method.manage)方法。例如，要让Rocket管理`HitCount`内部结构`AtomicUsize`的初始值为`0`，我们可以编写以下代码：

```rust
use std::sync::atomic::AtomicUsize;

struct HitCount {
    count: AtomicUsize
}

rocket::ignite().manage(HitCount { count: AtomicUsize::new(0) });
```

只要每次调用引用不同类型的值，`manage`方法就可以调用任意次数。例如，要让Rocket同时管理`HitCount`值和`Config`值，我们可以编写：

```rust
rocket::ignite()
    .manage(HitCount { count: AtomicUsize::new(0) })
    .manage(Config::from(user_input));
```

### 检索状态

可以通过以下[`State`](https://api.rocket.rs/v0.4/rocket/struct.State.html)类型来检索由Rocket 管理的状态：托管状态的[请求防护](https://rocket.rs/v0.4/guide/requests/#request-guards)。要使用请求防护，请将`State`类型添加到任何请求处理程序中，其中`T`是托管状态的类型。例如，我们可以检索和当前响应`HitCount`的`count`路线如下：

```rust
use rocket::State;

#[get("/count")]
fn count(hit_count: State<HitCount>) -> String {
    let current_count = hit_count.count.load(Ordering::Relaxed);
    format!("Number of visits: {}", current_count)
}
```

您也可以`State`在一条路线中检索多个类型：

```rust
#[get("/state")]
fn state(hit_count: State<HitCount>, config: State<Config>) -> T { ... }
```

### 警告

如果您请求一个未被管理(`managed`)的`T`的`State<T>`，Rocket将不会调用违规的路由。相反，Rocket将记录一条错误消息并向客户端返回500个错误。

您可以[在GitHub上](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/state)`HitCount`的[状态](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/state)示例中使用该结构找到完整的示例，并在API文档中了解有关该[`manage`方法](https://api.rocket.rs/v0.4/rocket/struct.Rocket.html#method.manage)和[`State`类型的](https://api.rocket.rs/v0.4/rocket/struct.State.html)更多信息。

### 防护内

从`FromRequest`实现中检索托管状态也很有用。为此，只需`State`使用[`Request::guard()`](https://api.rocket.rs/v0.4/rocket/struct.Request.html#method.guard)方法将其作为防护来调用。

```rust
fn from_request(req: &'a Request<'r>) -> request::Outcome<T, ()> {
    let hit_count_state = req.guard::<State<HitCount>>()?;
    let current_count = hit_count_state.count.load(Ordering::Relaxed);
    ...
}
```

