---
layout: default
id: Local-Dispatching
title: 本地调试
---

# 测试

每个应用程序都应该经过良好的测试并且易于理解。Rocket提供了执行单元和集成测试的工具。它还提供了一种检查Rocket生成的代码的方法。

## 本地调试

通过将请求分配到的本地实例来测试Rocket应用程序`Rocket`。该[`local`](https://api.rocket.rs/v0.4/rocket/local/)模块包含所有必要的结构。特别是，它包含一个[`Client`](https://api.rocket.rs/v0.4/rocket/local/struct.Client.html)用于创建[`LocalRequest`](https://api.rocket.rs/v0.4/rocket/local/struct.LocalRequest.html)可针对给定[`Rocket`](https://api.rocket.rs/v0.4/rocket/struct.Rocket.html)实例调度的结构的结构。用法很简单：

1. 构造一个`Rocket`代表应用程序的实例。

   ```rust
   let rocket = rocket::ignite();
   ```

2. 使用`Rocket`实例构造一个`Client`。

   ```rust
   let client = Client::new(rocket).expect("valid rocket instance");
   ```

3. 使用`Client`实例构造请求。

   ```rust
   let req = client.get("/");
   ```

4. 调度请求以检索响应。

   ```rust
   let response = req.dispatch();
   ```



