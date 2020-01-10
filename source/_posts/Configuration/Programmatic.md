---
layout: default
id: Programmatic
title: 程式化
---

## 程式化

除了使用环境变量或配置文件外，还可以使用[`rocket::custom()`](https://api.rocket.rs/v0.4/rocket/fn.custom.html)方法和来配置Rocket [`ConfigBuilder`](https://api.rocket.rs/v0.4/rocket/config/struct.ConfigBuilder.html)：

```rust
use rocket::config::{Config, Environment};

let config = Config::build(Environment::Staging)
    .address("1.2.3.4")
    .port(9234)
    .finalize()?;

rocket::custom(config)
    .mount(..)
    .launch();
```

配置通过`rocket::custom()`替换对或环境变量的调用`rocket::ignite()`以及所有配置`Rocket.toml`。换句话说，使用`rocket::custom()`结果`Rocket.toml`会忽略环境变量。