---
layout: default
id: Body-Data
title: 正文数据
---

## 正文数据

身体数据处理，像许多火箭一样，是类型导向的。若要指示处理程序需要正文数据，请使用`data=“<param>”`对其进行批注，其中`param`是处理程序中的参数。参数的类型必须实现`FromData`特性。看起来像这样，假设T实现`FromData`：

```rust
#[post("/", data = "<input>")]
fn new(input: T) -> String { ... }
```

实现`FromData`的任何类型也称为数据保护。

### 表单

表单是web应用程序中处理的最常见的数据类型之一，Rocket使处理它们变得简单。假设您的应用程序正在为新的`todo`任务处理表单提交。表单包含两个字段：`complete`复选框和`description`、文本字段。您可以轻松地在Rocket中处理表单请求，如下所示：

```rust
#[derive(FromForm)]
struct Task {
    complete: bool,
    description: String,
}

#[post("/todo", data = "<task>")]
fn new(task: Form<Task>) -> String { ... }
```

只要 [`Form`](https://api.rocket.rs/v0.4/rocket/request/struct.Form.html) 类型的泛型参数实现[`FromForm`](https://api.rocket.rs/v0.4/rocket/request/trait.FromForm.html)特征，它就实现`FromData`特征。在这个例子中，我们为任务结构自动派生了`FromForm`特征。对于字段实现[`FromFormValue`](https://api.rocket.rs/v0.4/rocket/request/trait.FromFormValue.html)的任何结构，都可以派生`FromForm`。如果`POST/todo`请求到达，表单数据将自动解析为 `Task` 结构。如果到达的数据不是正确的内容类型，则会转发请求。如果数据不解析或只是无效，则返回可自定义的`400错误请求`或`422不可处理的实体`错误。与以前一样，可以使用选项和结果类型捕获转发或失败：

```rust
#[post("/todo", data = "<task>")]
fn new(task: Option<Form<Task>>) -> String { ... }
```

#### 宽松解析

Rocket的`FromForm`解析在默认情况下是严格的。换句话说，只有当表单包含`T`中的确切字段集时， `Form<T>` 才能从传入表单成功解析。换句话说， `Form<T>` 将在缺少和/或额外字段时出错。例如，如果传入表单包含字段“a”、“b”和“c”，而`T`仅包含“a”和“c”，则该表单将不会解析为`form<T>`。

Rocket允许您通过 [`LenientForm`](https://api.rocket.rs/v0.4/rocket/request/struct.LenientForm.html) 数据类型选择退出此行为。只要表单包含`T`中字段的超集，`LenientForm<T>`就会从传入表单成功解析。换句话说，`LenientForm<T>`会自动丢弃多余的字段，而不会出错。例如，如果传入表单包含字段“a”、“b”和“c”，而T仅包含“a”和“c”，则该表单将解析为`LenientForm<T>`。

你可以在任何你想使用的地方使用一个`LenientForm`。它的泛型参数也是实现`FromForm`所必需的。例如，我们可以简单地将上面的`Form`替换为`LenientForm`，以获得宽松的解析：

```rust
#[derive(FromForm)]
struct Task { .. }

#[post("/todo", data = "<task>")]
fn new(task: LenientForm<Task>) { .. }
```

#### 字段重命名

默认情况下，Rocket将传入表单字段的名称与结构字段的名称匹配。虽然这种行为是典型的，但也可能需要在按预期解析表单字段和结构字段时使用不同的名称。通过使用 `#[form(field = "name")]`字段注释，您可以要求Rocket为给定的结构字段查找不同的表单字段。

例如，假设您正在编写一个从外部服务接收数据的应用程序。外部服务发布一个名为`type`的字段的表单。由于`type`是Rust中的保留关键字，因此不能用作字段的名称。要解决此问题，可以使用字段重命名，如下所示：

```rust
#[derive(FromForm)]
struct External {
    #[form(field = "type")]
    api_type: String
}
```

Rocket将自动将名为`type`的表单字段与名为`api_type`的结构字段匹配。

#### 字段验证

表单字段可以通过 [`FromFormValue`](https://api.rocket.rs/v0.4/rocket/request/trait.FromFormValue.html) 特性的实现轻松验证。例如，如果要验证窗体中某个用户的年龄是否超过某个年龄，则可以定义新的`AdultAge`类型，将其用作窗体结构中的字段，并实现`FromFormValue`，以便它只验证超过该年龄的整数：

```rust
struct AdultAge(usize);

impl<'v> FromFormValue<'v> for AdultAge {
    type Error = &'v RawStr;

    fn from_form_value(form_value: &'v RawStr) -> Result<AdultAge, &'v RawStr> {
        match form_value.parse::<usize>() {
            Ok(age) if age >= 21 => Ok(AdultAge(age)),
            _ => Err(form_value),
        }
    }
}

#[derive(FromForm)]
struct Person {
    age: AdultAge
}
```

如果表单的提交年龄不正确，Rocket将不会调用需要该结构的有效表单的处理程序。可以对字段使用 `Option` 或`Result`类型来捕获分析失败：

```rust
#[derive(FromForm)]
struct Person {
    age: Option<AdultAge>
}
```

对于具有空字段的枚举，还可以派生`FromFormValue`特性：

```rust
#[derive(FromFormValue)]
enum MyValue {
    First,
    Second,
    Third,
}
```

派生为修饰的枚举生成`FromFormValue`特性的实现。当表单值与变量名的字符串化版本匹配（大小写无关）并返回所述变量的实例时，实现将成功返回。

 [form validation](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/form_validation) 和 [form kitchen sink](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/form_kitchen_sink) 示例提供了进一步的说明。

### JSON

处理`JSON`数据并不困难：只需使用 [`rocket_contrib`](https://api.rocket.rs/v0.4/rocket_contrib/)中的 [`Json`](https://api.rocket.rs/v0.4/rocket_contrib/json/struct.Json.html) 类型：

```rust
#[derive(Deserialize)]
struct Task {
    description: String,
    complete: bool
}

#[post("/todo", data = "<task>")]
fn new(task: Json<Task>) -> String { ... }
```

唯一的条件是`Json`中的泛型类型实现 [Serde](https://github.com/serde-rs/json) 的 `Deserialize` 特性。有关完整的示例，请参见GitHub上的 [JSON 示例](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/json)。

#### 流

有时您只想直接处理传入的数据。例如，您可能希望将传入的数据流输出到文件。Rocket通过 [`Data`](https://api.rocket.rs/v0.4/rocket/data/struct.Data.html)类型使此操作尽可能简单：

```rust
#[post("/upload", format = "plain", data = "<data>")]
fn upload(data: Data) -> io::Result<String> {
    data.stream_to_file("/tmp/upload.txt").map(|n| n.to_string())
}
```

上面的路由接受对 `/upload`  路径的任何`POST`请求， `Content-Type: text/plain` 传入的数据流输出到`tmp/upload.txt`，如果上传成功，写入的字节数将作为纯文本响应返回。如果上载失败，则返回错误响应。以上处理程序已完成。真的很简单！请参阅 [GitHub example](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/raw_upload) 的GitHub示例代码。

### 警告：读取传入数据时应始终设置限制。

为了防止DoS攻击，您应该限制您愿意接受的数据量。[`take()`](https://doc.rust-lang.org/std/io/trait.Read.html#method.take)读卡器适配器使此操作变得简单：`data.open().take(LIMIT)`。