---
layout: default
id: Responder
title: 响应器
---

# 响应 Responses

您可能已经注意到，处理程序的返回类型似乎是任意的，这是因为可以返回实现[`Responder`](https://api.rocket.rs/v0.4/rocket/response/trait.Responder.html)特征的任何类型的值，包括您自己的值。在本节中，我们将描述Rocket 的`Responder`特性以及一些有用`Responder`的特性。我们还将简要讨论如何实现自己的`Responder`。

## 响应器

实现的类型知道如何[`Response`](https://api.rocket.rs/v0.4/rocket/response/)从其值生成a 。阿`Response`包括一个HTTP状态，标头和主体。主体既可以*固定大小*或*流*。给定的`Responder`实现决定使用哪个。例如，`String`使用固定大小的主体，而`File`使用流式响应。响应者可以根据`Request`他们正在响应的传入来动态调整其响应。

实现[`Responder`](https://api.rocket.rs/v0.4/rocket/response/trait.Responder.html)程序的类型知道如何从其值生成响应。响应`Response`包括HTTP状态、头和正文。主体可以是固定大小的，也可以是流式的。给定的响应器 `Responder` 实现决定使用哪个。例如，字符串`String`使用固定大小的正文，而文件 `File` 使用流式响应。响应器可以根据其响应的传入请求 `Request` 动态调整其响应。

### 包装

在描述一些响应器之前，我们注意到响应器通常会*包装*其他响应器。也就是说，响应器可以采用以下形式，其中`R`某些类型实现了`Responder`：

```rust
struct WrappingResponder<R>(R);
```

包装响应程序`R`在用相同响应进行响应之前会修改返回的响应。例如，Rocket `Responder`在[`status`模块](https://api.rocket.rs/v0.4/rocket/response/status/)中提供，以覆盖包装好的状态代码`Responder`。例如，[`Accepted`](https://api.rocket.rs/v0.4/rocket/response/status/struct.Accepted.html)类型将状态设置为`202 - Accepted`。可以如下使用：

```rust
use rocket::response::status;

#[post("/<id>")]
fn new(id: usize) -> status::Accepted<String> {
    status::Accepted(Some(format!("id: '{}'", id)))
}
```

同样，[`content`模块中](https://api.rocket.rs/v0.4/rocket/response/content/)的类型可用于覆盖响应的Content-Type。例如，要将Content-Type设置`&'static str`为JSON，可以使用以下 [`content::Json`](https://api.rocket.rs/v0.4/rocket/response/content/struct.Json.html) 类型：

```rust
use rocket::response::content;

#[get("/")]
fn json() -> content::Json<&'static str> {
    content::Json("{ 'hi': 'world' }")
}
```

### 警告：这与 [`rocket_contrib`](https://api.rocket.rs/v0.4/rocket_contrib/)中的 [`Json`](https://api.rocket.rs/v0.4/rocket_contrib/json/struct.Json.html)不同！

### 错误

响应器可能会失败；他们不必*总是*产生回应。相反，他们可以返回`Err`带有给定状态码的。发生这种情况时，Rocket会将请求转发给[错误捕获器](https://rocket.rs/v0.4/guide/requests/#error-catchers)以获取给定的状态码。

如果已为给定的状态码注册了一个错误捕获器，则Rocket将调用它。捕获器创建并向客户端返回响应。如果未注册任何错误捕获器，并且错误状态代码是标准HTTP状态代码之一，则将使用默认错误捕获器。默认错误捕获器返回带有状态代码和描述的HTML页面。如果没有用于自定义状态代码的捕获器，Rocket将使用**500**错误捕获器返回响应。

### 状态

虽然不鼓励这样做，但也可以通过直接返回[`Status`](https://api.rocket.rs/v0.4/rocket/response/status/)来手动将请求转发给捕获器。例如，如果要转发到406：不可接受，您可以写：

```rust
use rocket::http::Status;

#[get("/")]
fn just_fail() -> Status {
    Status::NotAcceptable
}
```

由生成的响应`Status`取决于状态码本身。如上所述，对于错误状态代码（在[400，599]范围内），`Status`转发到相应的错误捕获器。下表总结了`Status`针对这些代码和其他代码生成的响应：

| **状态码范围**  | **响应**                        |
| --------------- | ------------------------------- |
| [400, 599]      | 转发给捕获器以获取给定状态。    |
| 100, [200, 205] | 给定状态为空。                  |
| All others.     | 无效。错误传给`500`错误捕获器。 |