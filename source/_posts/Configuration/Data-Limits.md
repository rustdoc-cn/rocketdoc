---
layout: default
id: Data-Limits
title: 数据限制
---

## 数据限制

该`limits`参数配置了Rocket对于给定数据类型将接受的最大数据量。该参数是一个表，其中每个键对应一种数据类型，每个值对应于Rocket对于该类型应接受的最大字节数。

默认情况下，Rocket限制形式为32KiB（32768字节）。要增加限制，只需设置`limits.forms`配置参数。例如，要将全局的表单限制增加到128KiB，我们可以编写：

```toml
[global.limits]
forms = 131072
```

该`limits`参数可以包含不是Rocket特有的键和值。例如，该[`Json`](https://api.rocket.rs/v0.4/rocket_contrib/json/struct.Json.html#incoming-data-limits)类型读取`json`限制值以限制传入的JSON数据。您还应该将`limits`参数用于应用程序的数据限制。可以通过该[`Request::limits()`](https://api.rocket.rs/v0.4/rocket/struct.Request.html#method.limits)方法在运行时检索数据限制。