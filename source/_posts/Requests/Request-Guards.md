---
layout: default
id: Request-Guards
title: 请求防护
---

## 请求防护

请求防护是Rocket最强大的工具之一。顾名思义，请求防护器保护处理程序不被基于传入请求中包含的信息错误地调用。更具体地说，请求防护是一种表示任意验证策略的类型。验证策略是通过[`FromRequest`](https://api.rocket.rs/v0.4/rocket/request/trait.FromRequest.html)特性实现的。实现`FromRequest`的每种类型都是一个请求防护器。

请求防护出现在处理程序的输入时。任意数量的请求防护可以在路由处理程序中以参数出现。Rocket将在调用处理程序之前自动调用请求防护的[`FromRequest`](https://api.rocket.rs/v0.4/rocket/request/trait.FromRequest.html)实现。Rocket只在所有防护通过时向处理程序发送请求。

例如，下面的虚拟处理程序使用3个请求防护，`A`、`B`和`C`。如果输入在`route`属性中没有命名，则将其标识为请求防护。

```rust
#[get("/<param>")]
fn index(param: isize, a: A, b: B, c: C) -> ... { ... }
```

请求防护按从左到右的顺序。在上面的例子中，顺序是A后B后C。失败是短路；如果一个保护失败，则不尝试其余的保护。要了解有关请求保护和实现它们的更多信息，请参阅 [`FromRequest`](https://api.rocket.rs/v0.4/rocket/request/trait.FromRequest.html) 文档。

### 自定义防护

您可以为自己的类型实现`FromRequest`。例如，为了防止敏感路由在请求头中不存在`ApiKey`的情况下运行，可以创建实现`from request`的`ApiKey`类型，然后将其用作请求防护：

```rust
#[get("/sensitive")]
fn sensitive(key: ApiKey) -> &'static str { ... }
```

您还可以为`AdminUser`类型实现`FromRequest`，该类型使用传入的`cookie`对管理员进行身份验证。然后，在参数列表中具有`AdminUser`或`ApiKey`类型的任何处理程序都被保证只有在满足适当的条件时才被调用。请求保护集中化策略，从而产生更简单、更安全的应用程序。

### 防护透明度

当请求防护类型通过[`FromRequest`](https://api.rocket.rs/v0.4/rocket/request/trait.FromRequest.html)被实现，并且不是`Copy`类型时，存在一个请求防护值，提供了一个类型级别的证明，即当前的请求已经针对任意策略进行了验证。通过规定数据访问方法通过请求防护来验证授权证明，这提供了保护应用程序不受访问控制侵犯的强大方法。我们称这种使用请求防护的概念为证人保护透明度。

作为一个具体的例子，下面的应用程序有一个函数`health_records`，它返回数据库中的所有健康记录。因为健康记录是敏感信息，所以只能由超级用户访问。`SuperUser`请求防护对超级用户进行身份验证和授权，其`FromRequest`实现是构建`SuperUser`的唯一方法。通过如下声明的`health_records`功能，可以保证在编译时违反健康记录的访问控制被阻止：

```rust
fn health_records(user: &SuperUser) -> Records { ... }
```

推断如下：

1. `health_records`函数需要`&SuperUser`类型。
2. `SuperUser`类型的唯一构造函数是`FromRequest`。
3. Rocket只能通过`FromRequest`提供活动 `&Request`来构造。
4. 因此，必须有一个`Request`授权`SuperUser`调用`health_records`。

### 注意

以牺牲保护类型中的存在时间参数为代价，通过将传递给`FromRequest`的`Request`的生存期绑定到请求保护，确保保护值始终与活动请求相对应，可以使保证变得更加强大。

我们建议对所有数据访问使用请求保护透明度。

## 转发防护

请求防护和发是执行策略的强大组合。为了演示，我们考虑如何使用这些机制实现一个简单的授权系统。

我们从两个请求防护开始：

- `User`：经过身份验证的普通用户。

  `User`的`FromRequest`实现检查`cookie`是否标识用户并返回用户值（如果是）。如果没有用户可以通过身份验证，防护就会转发。

- `AdminUser`：以管理员身份验证的用户。

  `AdminUser`的`FromRequest`实现检查`cookie`是否标识管理用户，如果是，则返回`AdminUser`值。如果没有用户可以通过身份验证，防护就会转发。

我们现在将这两个防护与转发结合使用，以实现以下三个路由，每个路由都指向位于`/admin`的管理控制面板：

```rust
#[get("/admin")]
fn admin_panel(admin: AdminUser) -> &'static str {
    "Hello, administrator. This is the admin panel!"
}

#[get("/admin", rank = 2)]
fn admin_panel_user(user: User) -> &'static str {
    "Sorry, you must be an administrator to access this page."
}

#[get("/admin", rank = 3)]
fn admin_panel_redirect() -> Redirect {
    Redirect::to("/login")
}
```

以上三种路由编码认证和授权。只有当管理员登录时， `admin_panel` 路由才会成功。只有这样才会显示管理面板。如果用户不是管理员，则`AdminUser`防护将转发。由于`admin_panel_user`路由排在第二位，因此尝试排在第二位。如果有任何用户登录，则此路由成功，并显示授权失败消息。最后，如果用户未登录，则尝试`admin_panel_redirect`路由。因为这条路由没有防护，所以总是成功的。用户被重定向到登录页。