---
layout: default
id: Validating-Responses
title: 验证响应
---

## 验证响应

`LocalRequest`的`dispatch`返回一个[`LocalResponse`](https://api.rocket.rs/v0.4/rocket/local/struct.LocalResponse.html)可以透明地使用作为[`Response`](https://api.rocket.rs/v0.4/rocket/struct.Response.html)值。在测试过程中，通常会根据预期属性验证响应。这些内容包括响应HTTP状态，标头的包含以及预期的正文数据。

该[`Response`](https://api.rocket.rs/v0.4/rocket/struct.Response.html)类型提供了简化此类验证的方法。我们在下面列出一些：

- [`status`](https://api.rocket.rs/v0.4/rocket/struct.Response.html#method.status)：返回响应中的HTTP状态。
- [`content_type`](https://api.rocket.rs/v0.4/rocket/struct.Response.html#method.content_type)：返回响应中的Content-Type标头。
- [`headers`](https://api.rocket.rs/v0.4/rocket/struct.Response.html#method.headers)：返回响应中所有标头的映射。
- [`body_string`](https://api.rocket.rs/v0.4/rocket/struct.Response.html#method.body_string)：以形式返回主体数据`String`。
- [`body_bytes`](https://api.rocket.rs/v0.4/rocket/struct.Response.html#method.body_bytes)：以形式返回主体数据`Vec<u8>`。

这些方法通常与`assert_eq!`或`assert!`宏结合使用，如下所示：

```rust
let rocket = rocket::ignite();
let client = Client::new(rocket).expect("valid rocket instance");
let mut response = client.get("/").dispatch();

assert_eq!(response.status(), Status::Ok);
assert_eq!(response.content_type(), Some(ContentType::Plain));
assert!(response.headers().get_one("X-Special").is_some());
assert_eq!(response.body_string(), Some("Expected Body.".into()));
```

