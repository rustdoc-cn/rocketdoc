---
layout: default
id: Query-Strings
title: 查询字符串
---

## 查询字符串

可以使用与路径段几乎相同的方式将查询段声明为静态或动态：

```rust
#[get("/hello?wave&<name>")]
fn hello(name: &RawStr) -> String {
    format!("Hello, {}!", name.as_str())
}
```

上面的`hello`路由匹配任何`GET`请求到`/hello`，该请求至少有一个`name`查询键和一个任意顺序的`wave`查询段，忽略任何额外的查询段。`name`查询参数的值用作`name`函数参数的值。例如，请求`/hello?wave&name=John`会返回`Hello, John!`。其他可能导致相同结果的请求包括：

- `/hello?name=John&wave` (重新排序)
- `/hello?name=John&wave&id=123` (附加段)
- `/hello?id=123&name=John&wave` (重新排序, 附加段)
- `/hello?name=Bob&name=John&wave` (最后一个值)

允许任意数量的动态查询段。查询段可以是任何类型，包括您自己的类型，只要该类型实现了[`FromFormValue`](https://api.rocket.rs/v0.4/rocket/request/trait.FromFormValue.html)特征即可。

### 可选参数

允许缺少查询参数。只要请求的查询字符串包含路由查询字符串的所有静态组件，则请求将被路由到该路由。这允许使用可选参数，即使缺少参数也可以进行验证。

为此，使用`Option<T>`作为参数类型。当请求中缺少查询参数时，将不提供任何参数作为值。使用`Option<T>`的路由如下所示：

```rust
#[get("/hello?wave&<name>")]
fn hello(name: Option<&RawStr>) -> String {
    name.map(|name| format!("Hi, {}!", name))
        .unwrap_or_else(|| "Hello!".into())
}
```

路径为`/hello`和`wave`查询段的任何`GET`请求都将路由到此路由。如果存在`name=value`查询段，则路由返回字符串“`Hi,value!`”。如果不存在`name`查询段，则路由返回“`Hello!`”。

正如`Option<T>`类型的参数在查询中缺少参数时将具有值`None`一样，`bool`类型的参数在缺少参数时将具有值`false`。通过实现[`FromFormValue::default()`](https://api.rocket.rs/v0.4/rocket/request/trait.FromFormValue.html#method.default)，可以为实现`FromFormValue`的自己的类型自定义缺少参数的默认值。

### 多段参数

与路径一样，还可以使用`<param..>`匹配查询中的多个段。此类参数的类型（称为查询保护）必须实现`FromQuery`特性。查询保护必须是查询的最终组件：查询参数之后的任何文本都将导致编译时错误。

查询保护将验证所有其他不匹配的查询段（通过静态或动态查询参数）。虽然您可以自己实现`FromQuery`，但大多数用例将通过使用`Form`或`LenientForm`查询保护来处理。表单部分详细说明了如何使用这些类型。简而言之，这些类型允许您使用具有命名字段的结构自动验证查询/表单参数：

```rust
use rocket::request::Form;

#[derive(FromForm)]
struct User {
    name: String,
    account: usize,
}

#[get("/item?<id>&<user..>")]
fn item(id: usize, user: Form<User>) { /* ... */ }
```

对请求 `/item?id=100&name=sandal&account=400`，上面的 `item` 路由将`id`设置为`100`，`user`设置为`User { name: "sandal", account: 400 }`。若要捕获无法验证的表单，请使用`Option` 或 `Result` 类型：

```rust
#[get("/item?<id>&<user..>")]
fn item(id: usize, user: Option<Form<User>>) { /* ... */ }
```

有关更多查询处理示例，请参见[`query_params` 示例](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/query_params)。