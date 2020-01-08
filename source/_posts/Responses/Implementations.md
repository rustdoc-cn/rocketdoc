---
layout: default
id: Implementations
title: 实现响应器
---

## 实现响应器

Rocket工具`Responder`为多种类型的鲁斯特的标准库，包括`String`，`&str`，`File`，`Option`，和`Result`。该[`Responder`](https://api.rocket.rs/v0.4/rocket/response/trait.Responder.html)文档描述了这些详细，但我们简单介绍几个在这里。

### 字符串

 `&str` 和 `String` 的 `Responder` 实现是直截了当的：字符串用作大小合适的主体，响应的内容类型设置为 `text/plain`。要了解这样一个 `Responder` 实现的外观，以下是`String`的实现：

```rust
impl Responder<'static> for String {
    fn respond_to(self, _: &Request) -> Result<Response<'static>, Status> {
        Response::build()
            .header(ContentType::Plain)
            .sized_body(Cursor::new(self))
            .ok()
    }
}
```

由于这些实现，您可以直接从处理程序中返回 `&str`或`String`类型：

```rust
#[get("/string")]
fn handler() -> &'static str {
    "Hello there! I'm a string!"
}
```

#### `Option`

`Option`是包装响应器：只有在`T`实现器时才能返回 `Option<T>` 。如果 `Option` 为 `Some`，则使用包装的响应程序响应客户端。否则，将向客户端返回 **404 - Not Found** 错误。

此实现使 `Option` 在不知道处理时间是否存在内容之前返回一种方便的类型。例如，由于 `Option`的缘故，我们可以实现一个文件服务器，在找到文件时返回 `200` ，而在仅4行惯用行中没有找到文件时返回 `404` ：

```rust
#[get("/<file..>")]
fn files(file: PathBuf) -> Option<NamedFile> {
    NamedFile::open(Path::new("static/").join(file)).ok()
}
```

#### `Result`

`Result`是一种特殊的包装响应器：其功能取决于错误类型`E`是否实现`Responder`。

当错误类型`E`实现时`Responder`，使用包裹`Responder`在中的`Ok`或`Err`（可能是其中的任意一个）来响应客户端。这意味着可以在运行时动态选择响应器，并且可以根据情况使用两种不同类型的响应。例如，重新访问文件服务器，我们可能希望在找不到文件时向用户提供更多反馈。我们可以这样进行：

```rust
use rocket::response::status::NotFound;

#[get("/<file..>")]
fn files(file: PathBuf) -> Result<NamedFile, NotFound<String>> {
    let path = Path::new("static/").join(file);
    NamedFile::open(&path).map_err(|_| NotFound(format!("Bad path: {}", path)))
}
```

如果错误类型`E` *未*实现`Responder`，则使用该`Debug`实现将错误简单地记录到控制台，然后将`500`错误返回给客户端。

