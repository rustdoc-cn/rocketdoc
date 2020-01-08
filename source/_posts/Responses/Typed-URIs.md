---
layout: default
id: Typed-URIs
title: 类型化Uri
---

## 类型化Uri

Rocket的[`uri!`](https://api.rocket.rs/v0.4/rocket_codegen/macro.uri.html)宏允许您以健壮，类型安全和URI安全的方式构建URI来路由应用程序中的路由。类型或路由参数不匹配在编译时被捕获，并且对路由URI的更改会自动反映在生成的URI中。

`uri!`宏返回一个[`Origin`](https://api.rocket.rs/v0.4/rocket/http/uri/struct.Origin.html)与所提供的航线的URI结构内插与所述给定值。`uri!`使用[`UriDisplay`](https://api.rocket.rs/v0.4/rocket/http/uri/trait.UriDisplay.html)值类型的实现，将每个传入的值呈现在URI中的适当位置。该`UriDisplay`实现可确保呈现的值是URI安全的。

注意， `Origin` 实现 `Into<Uri>` （扩展为`TryInto<Uri>`），因此可以根据需要使用 `.into()`将其转换为 [`Uri`](https://api.rocket.rs/v0.4/rocket/http/uri/enum.Uri.html) ，并传递给 [`Redirect::to()`](https://api.rocket.rs/v0.4/rocket/response/struct.Redirect.html#method.to)等方法。

例如，给定以下路由：

```rust
#[get("/person/<name>?<age>")]
fn person(name: String, age: Option<u8>) -> T
```

`person` 的URIs可以创建如下：

```rust
// with unnamed parameters, in route path declaration order
let mike = uri!(person: "Mike Smith", 28);
assert_eq!(mike.to_string(), "/person/Mike%20Smith?age=28");

// with named parameters, order irrelevant
let mike = uri!(person: name = "Mike", age = 28);
let mike = uri!(person: age = 28, name = "Mike");
assert_eq!(mike.to_string(), "/person/Mike?age=28");

// with a specific mount-point
let mike = uri!("/api", person: name = "Mike", age = 28);
assert_eq!(mike.to_string(), "/api/person/Mike?age=28");

// with optional (defaultable) query parameters ignored
let mike = uri!(person: "Mike", _);
let mike = uri!(person: name = "Mike", age = _);
assert_eq!(mike.to_string(), "/person/Mike");
```

Rocket会在编译时通知您任何不匹配的参数：

```shell
error: person route uri expects 2 parameters but 1 was supplied
 --> examples/uri/src/main.rs:9:29
  |
9 |     uri!(person: "Mike Smith");
  |                  ^^^^^^^^^^^^
  |
  = note: expected parameters: name: String, age: Option<u8>
```

Rocket还会在编译时通知您任何类型错误：

```rust
error: the trait bound u8: FromUriParam<Query, &str> is not satisfied
 --> examples/uri/src/main.rs:9:35
  |
9 |     uri!(person: age = "10", name = "Mike");
  |                        ^^^^ FromUriParam<Query, &str> is not implemented for u8
  |
```

我们建议您为路由构造uri时仅使用`uri!`。

### 忽略

如前所述，可以在查询中使用`_`表达式来代替查询参数`uri!`。路由URI中的相应类型必须实现[`Ignorable`](https://api.rocket.rs/v0.4/rocket/http/uri/trait.Ignorable.html)。忽略的参数不会内插到结果中`Origin`。路径参数不可忽略。

#### 派生 `UriDisplay`

该`UriDisplay`特性可以导出自定义类型。对于出现在URI的路径部分中的类型，请使用派生[`UriDisplayPath`](https://api.rocket.rs/v0.4/rocket_codegen/derive.UriDisplayPath.html)；对于出现在URI的查询部分中的类型，请使用派生[`UriDisplayQuery`](https://api.rocket.rs/v0.4/rocket_codegen/derive.UriDisplayQuery.html)。

例如，请考虑以下表单结构和路由：

```rust
#[derive(FromForm, UriDisplayQuery)]
struct UserDetails<'r> {
    age: Option<usize>,
    nickname: &'r RawStr,
}

#[post("/user/<id>?<details..>")]
fn add_user(id: usize, details: Form<UserDetails>) { .. }
```

通过使用派生`UriDisplayQuery`，将`UriDisplay`自动生成的实现，从而允许`add_user`使用`uri!`以下命令生成URI ：

```rust
uri!(add_user: 120, UserDetails { age: Some(20), nickname: "Bob".into() })
  => "/user/120?age=20&nickname=Bob"
```

 [`UriPart`](https://api.rocket.rs/v0.4/rocket/http/uri/trait.UriPart.html) 特性对将URI的一部分标记为 [`Path`](https://api.rocket.rs/v0.4/rocket/http/uri/enum.Path.html) 或 [`Query`](https://api.rocket.rs/v0.4/rocket/http/uri/enum.Query.html)类型进行类型化。换句话说，实现UriPart类型是在类型级别表示URI的一部分的标记类型。[`UriDisplay`](https://api.rocket.rs/v0.4/rocket/http/uri/trait.UriDisplay.html)和[`FromUriParam`](https://api.rocket.rs/v0.4/rocket/http/uri/trait.FromUriParam.html)等特性通过 `UriPart`：`P: UriPart`绑定了一个泛型参数。这将为每个特征创建两个实例：`UriDisplay<Query>`和`UriDisplay<Path>`，以及`FromUriParam<Query>`和`FromUriParam<Path>`。

顾名思义，`Path`当在URI的路径部分中显示参数时使用特性的版本，而在URI `Query`的查询部分中显示参数时使用版本的特性。这些特性的不同版本恰好存在，以便在类型级别区分要写入URI的值，从而在面对两个位置之间的差异时允许类型安全。例如，虽然`None`在查询部分使用值有效，但完全省略该参数，*但*在路径部分无效。通过在类型系统区分，这两个条件可以适当地通过的不同的实施方式实施`FromUriParam`和`FromUriParam`。

### 转换

将[`FromUriParam`](https://api.rocket.rs/v0.4/rocket/http/uri/trait.FromUriParam.html)用于执行对传递给每个值的转换`uri!`之前将显示它`UriDisplay`。如果`FromUriParam`存在用于`T`part URI part 的类型的实现`P`，则`S`可以在`uri!`宏中为type为`T`in的声明的URI参数使用type的值`P`。例如，Rocket提供的以下实现允许`&str`在`uri!`调用中声明为的URI参数使用`String`：

```rust
impl<P: UriPart, 'a> FromUriParam<P, &'a str> for String { .. }
```

需要注意的其他转换包括：

- `&str` to `RawStr`
- `String` to `&str`
- `String` to `RawStr`
- `T` to `Option<T>`
- `T` to `Result<T,E>`
- `T` to `Form<T>`
- `&str` to `&Path`
- `&str` to `PathBuf`

转换*嵌套*。例如，`T`当需要一个类型值时，可以提供一个类型值`Option<Form<T>>`：

```rust
#[get("/person/<id>?<details>")]
fn person(id: usize, details: Option<Form<UserDetails>>) -> T

uri!(person: id = 100, details = UserDetails { .. })
```

有关[`FromUriParam`](https://api.rocket.rs/v0.4/rocket/http/uri/trait.FromUriParam.html)更多详细信息，请参见文档。