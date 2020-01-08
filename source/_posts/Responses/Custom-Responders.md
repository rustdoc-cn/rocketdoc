---
layout: default
id: Custom-Responders
title: 自定义响应器
---

## 自定义响应器

该[`Responder`](https://api.rocket.rs/v0.4/rocket/response/trait.Responder.html)特性文档详细介绍如何通过明确落实特征实现自定义的响应器。但是，对于大多数使用情况，Rocket可以自动导出的实现`Responder`。特别是，如果您的自定义响应程序包装了现有的响应程序，标头或设置了自定义状态或内容类型，`Responder`则可以自动派生：

```rust
#[derive(Responder)]
#[response(status = 500, content_type = "json")]
struct MyResponder {
    inner: OtherResponder,
    header: SomeHeader,
    more: YetAnotherHeader,
    #[response(ignore)]
    unrelated: MyType,
}
```

对于上面的示例，Rocket生成了一个`Responder`实现：

- 将响应的状态设置为`500: Internal Server Error`。
- 将Content-Type设置为`application/json`。
- 将标头`self.header`和`self.more`添加到响应中。
- 使用`self.inner`完成响应。

请注意，第*一个*字段用作内部响应者，而所有其余字段（除非使用忽略`#[response(ignore)]`）都作为标头添加到响应中。可选`#[response]`属性可用于自定义响应的状态和内容类型。由于`ContentType`和`Status`本身都是标头，因此您还可以通过简单地包括这些类型的字段来动态设置内容类型和状态。

有关使用`Responder`派生的更多信息，请参见[`Responder`派生](https://api.rocket.rs/v0.4/rocket_codegen/derive.Responder.html)文档。