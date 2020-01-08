---
layout: default
id: Rocket-Responders
title: Rocket响应器
---

## Rocket响应器

Rocket的一些最佳功能是通过响应程序实现的。您可以在[`response`](https://api.rocket.rs/v0.4/rocket/response/)模块和[`rocket_contrib`](https://api.rocket.rs/v0.4/rocket_contrib/)库中找到许多这些响应者。其中包括：

- [`Content`](https://api.rocket.rs/v0.4/rocket/response/struct.Content.html) -用于覆盖响应的Content-Type。
- [`NamedFile`](https://api.rocket.rs/v0.4/rocket/response/struct.NamedFile.html)-流文件到客户端；根据文件扩展名自动设置Content-Type。
- [`Redirect`](https://api.rocket.rs/v0.4/rocket/response/struct.Redirect.html) -将客户端重定向到其他URI。
- [`Stream`](https://api.rocket.rs/v0.4/rocket/response/struct.Stream.html)-从任意`Read`er类型向客户端发送响应。
- [`status`](https://api.rocket.rs/v0.4/rocket/response/status/) -包含覆盖响应状态代码的类型。
- [`Flash`](https://api.rocket.rs/v0.4/rocket/response/struct.Flash.html) -设置访问时将其删除的“ Flash” Cookie。
- [`Json`](https://api.rocket.rs/v0.4/rocket_contrib/json/struct.Json.html) -自动将值序列化为JSON。
- [`MsgPack`](https://api.rocket.rs/v0.4/rocket_contrib/msgpack/struct.MsgPack.html) -自动将值序列化到MessagePack。
- [`Template`](https://api.rocket.rs/v0.4/rocket_contrib/templates/struct.Template.html) -使用把手或Tera渲染动态模板。

### 流

该`Stream`类型值得特别注意。当需要将大量数据发送到客户端时，最好将数据流式传输到客户端，以避免消耗大量内存。火箭提供了这种[`Stream`](https://api.rocket.rs/v0.4/rocket/response/struct.Stream.html)类型，使其变得容易。的`Stream`类型可以从任何被创建`Read`类型。例如，要从本地Unix流进行流传输，我们可以编写：

```rust
#[get("/stream")]
fn stream() -> io::Result<Stream<UnixStream>> {
   UnixStream::connect("/path/to/my/socket").map(|s| Stream::from(s))
}
```

#### JSON格式

[`rocket_contrib`](https://api.rocket.rs/v0.4/rocket_contrib/)中的[`Json`](https://api.rocket.rs/v0.4/rocket_contrib/json/struct.Json.html)响应器使您可以轻松地对格式正确的JSON数据进行响应：只需返回`Json<T>`类型的值，其中`T`是要序列化为`Json`的结构类型。类型`T`必须实现[`serde`](https://docs.serde.rs/serde/)的 [`Serialize`](https://docs.serde.rs/serde/trait.Serialize.html) 特性，该特性可以自动派生。

例如，为了响应`Task`结构的JSON值，我们可以这样写：

```rust
use rocket_contrib::json::Json;

#[derive(Serialize)]
struct Task { ... }

#[get("/todo")]
fn todo() -> Json<Task> { ... }
```

该`Json`类型将结构序列化为JSON，将Content-Type设置为JSON，并以固定大小的主体发出序列化的数据。如果序列化失败，则返回**500-Internal Server Error**。

[GitHub上](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/json)的[JSON示例](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/json)提供了进一步的说明。