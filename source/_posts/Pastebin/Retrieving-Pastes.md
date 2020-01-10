---
layout: default
id: Retrieving-Pastes
title: 检索粘贴
---

## 检索粘贴

最后一步是创建`retrieve`路径，给定一个`<id>`，将返回相应的粘贴（如果存在）。

这是实现此`retrieve`路线的第一步。下面的路由将一个`<id>`作为动态路径元素。处理程序使用`id`来构造到内部粘贴的路径`upload/`，然后尝试在该路径下打开文件，并选择`File`是否存在（如果存在）。Rocket将`None` [响应器](https://api.rocket.rs/v0.4/rocket/response/trait.Responder.html#provided-implementations)视为**404**错误，这正是我们要在不存在请求的粘贴时返回的错误。

```rust
use std::fs::File;
use rocket::http::RawStr;

#[get("/<id>")]
fn retrieve(id: &RawStr) -> Option<File> {
    let filename = format!("upload/{id}", id = id);
    File::open(&filename).ok()
}
```

确保路由已挂载在根路径上：

```rust
fn main() {
    rocket::ignite().mount("/", routes![index, upload, retrieve]).launch();
}
```

不幸的是，这段代码有问题。您能发现问题吗？该[`RawStr`](https://api.rocket.rs/v0.4/rocket/http/struct.RawStr.html)类型应该提醒你的！

问题是，用户控制 `id`的值，因此，可以强制服务在 `upload/` 中打开不打算打开的文件。例如，假设您稍后决定一个特殊的文件 `upload/_credentials.txt` 将存储一些重要的私有信息。如果用户向 `/_credentials.txt`发出 `GET` 请求，服务器将读取并返回  `upload/_credentials.txt`文件，从而泄漏敏感信息。这是一个大问题；它被称为全路径泄漏攻击，而Rocket提供了防止这种和其他类型攻击发生的工具。

为了防止攻击，我们需要在使用前进行*验证* `id`。由于`id`是动态参数，因此我们可以使用Rocket的[FromParam](https://api.rocket.rs/v0.4/rocket/request/trait.FromParam.html)特性来执行验证，并在使用前确保验证`id`有效`PasteID`。我我们通过在`src/paste-id.rs`中为`PasteID`实现`FromParam`来实现，如下所示：

```rust
use rocket::request::FromParam;

/// Returns `true` if `id` is a valid paste ID and `false` otherwise.
fn valid_id(id: &str) -> bool {
    id.chars().all(|c| {
        (c >= 'a' && c <= 'z')
            || (c >= 'A' && c <= 'Z')
            || (c >= '0' && c <= '9')
    })
}

/// Returns an instance of `PasteID` if the path segment is a valid ID.
/// Otherwise returns the invalid ID as the `Err` value.
impl<'a> FromParam<'a> for PasteID<'a> {
    type Error = &'a RawStr;

    fn from_param(param: &'a RawStr) -> Result<PasteID<'a>, &'a RawStr> {
        match valid_id(param) {
            true => Ok(PasteID(Cow::Borrowed(param))),
            false => Err(param)
        }
    }
}
```

然后，我们只需要将处理程序中的`id`类型更改为`PasteID`。然后，Rocket将确保`<id>`在调用检索路由之前表示有效的`PasteID`，从而防止对检索路由的攻击：

```rust
#[get("/<id>")]
fn retrieve(id: PasteID) -> Option<File> {
    let filename = format!("upload/{id}", id = id);
    File::open(&filename).ok()
}
```

请注意，我们的`valid_id`功能过于简单，可以通过例如检查的长度`id`是否在某些已知范围内或根据需要将敏感文件列入黑名单来加以改进。

使用`FromParam`和其他火箭特性的妙处在于它们集中了策略。例如，在这里，我们已经将有效`PasteID`s 的策略集中在动态参数中。在将来的任何时候，如果添加了其他需要使用的路由`PasteID`，则无需做进一步的工作：只需在签名中使用该类型，Rocket就会处理其余的工作。