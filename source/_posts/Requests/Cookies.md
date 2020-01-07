---
layout: default
id: Cookies
title: Cookies
---

## Cookies

[`Cookies`](https://api.rocket.rs/rocket/http/enum.Cookies.html) 是一个重要的内建的请求警卫：你可以获取，设置，和删除cookies。因为`Cookies`是一个请求警卫，因此Cookies的类型可以作为处理器的参数：

```rust
use rocket::http::Cookies;

#[get("/")]
fn index(cookies: Cookies) -> Option<String> {
    cookies.get("message")
        .map(|value| format!("Message: {}", value))
}
```

因此cookise可以在处理器中使用。上面的例子中，获取了cookies中的`message`信息。`Cookies`警卫也可以设置或者删除cookies信息。GitHub上的[cookies例子](https://github.com/SergioBenitez/Rocket/tree/v0.3.17/examples/cookies)说明了更多是用`Cookies`类型操作cookies的方法，同时[`Cookies`](https://api.rocket.rs/rocket/http/enum.Cookies.html) 文档包含了所有的使用方法。

### 加密Cookies

通过[`Cookies::add()`](https://api.rocket.rs/rocket/http/enum.Cookies.html#method.add) 方法添加cookies是*“显而易见的”*，所有的值都能被客户端看到。对于敏感数据，Pocket提供了*加密*cookies。

加密cookies和常规的cookies类似，只是经过了认证模式加密，认证模式加密同时提供了机密性，完成行，和真实性。这意味着加密cookies不能被客户检查，篡改或制造。 如果您愿意，可以将加密cookies视为签名和加密。

加密cookies的获取，添加，和删除的API和常规的相同，只是方法末尾多了`_private`。分别是：[`get_private`](https://api.rocket.rs/rocket/http/enum.Cookies.html#method.get_private)，[`add_private`](https://api.rocket.rs/rocket/http/enum.Cookies.html#method.add_private)，和 [`remove_private`](https://api.rocket.rs/rocket/http/enum.Cookies.html#method.remove_private)。使用的例子如下：

```rust
/// Retrieve the user's ID, if any.
#[get("/user_id")]
fn user_id(cookies: Cookies) -> Option<String> {
    cookies.get_private("user_id")
        .map(|cookie| format!("User ID: {}", cookie.value()))
}

/// Remove the `user_id` cookie.
#[post("/logout")]
fn logout(mut cookies: Cookies) -> Flash<Redirect> {
    cookies.remove_private(Cookie::named("user_id"));
    Flash::success(Redirect::to("/"), "Successfully logged out.")
}
```

### 密匙

Rocket使用256bit的密匙加密cookies，密匙在配置参数`secret_key`中指定。如果不指定，Rocket会自动生成一个新密匙。需要注意的是，加密cookie的解密密匙必须和加密密匙相同才能解密。因此，如果当程序重启之后还要正确解密之前加密的cookie，就必须在配置中指定`secret_key`。如果在正式环境中程序启动时发现配置中没有指定`secret_key`，Rocket会发出一个警告。

通常使用`openssl`之类的工具来生成合适的`secret_key`。`openssl`生成一个256bit的base64密匙使用命令`openssl rand -base64 32`。

关于配置的更多信息，请看本指南的 [配置](/rocketdoc/Configuration/Environment.html) 这一节。

### 一次一个

为了安全起见，目前Rocket要求在同一时间最多只能有一个活跃的Cookies实例。多个Cookies实例的情况并不常见，但是一旦遇到，处理器就会不知所措。

如果真的出现，Roocket会在console里输出如下信息：

```log
=> Error: Multiple `Cookies` instances are active at once.
=> An instance of `Cookies` must be dropped before another can be retrieved.
=> Warning: The retrieved `Cookies` instance will be empty.
```

当违反这个规则调用处理器时，就会输出上述日志。解决这个问题只能是调用处理器的时候，保证统一时间只能有一个Cookies。大家共同容易犯的一个错误是，同时使用Cookies警卫和Custom警卫，并且通过Custom警卫又获取了一次Cookies。如下：

```rust
#[get("/")]
fn bad(cookies: Cookies, custom: Custom) { .. }
```

因为首先验证Cookies警卫，之后在Custom警卫里再次获取Cookies实例的时候，已经存在一个Cookies了。
这个方案可以简单的通过调换警卫的顺序实现：

```rust
#[get("/")]
fn good(custom: Custom, cookies: Cookies) { .. }
```

