---
layout: default
id: Testing-Hello-World
title: 测试 Hello World！
---

## 测试 Hello World！

为了巩固对如何测试Rocket应用程序的直觉，我们逐步介绍了如何测试“ Hello，world！”。下面的应用程序：

```rust
#[get("/")]
fn hello() -> &'static str {
    "Hello, world!"
}

fn rocket() -> Rocket {
    rocket::ignite().mount("/", routes![hello])
}

fn main() {
    rocket().launch();
}
```

注意，我们将实例的*创建*与`Rocket`实例的*启动*分开了。正如您很快就会看到的那样，这使我们的应用程序的测试变得更容易，更冗长，更不易出错。

### 配置

首先，我们将`test`使用正确的导入创建一个模块：

```rust
#[get("/")]
fn hello() -> &'static str {
    "Hello, world!"
}

fn rocket() -> Rocket {
    rocket::ignite().mount("/", routes![hello])
}

fn main() {
    rocket().launch();
}
```

您还可以将`test`模块的主体移到它自己的文件中，例如`tests.rs`，然后使用以下命令将模块导入到main文件中：

```rust
#[cfg(test)] mod tests;
```

### 测试

测试我们的“你好，世界！” 应用程序，我们首先`Client`为我们的`Rocket`实例创建一个。没关系使用类似的方法`expect`，并`unwrap`在测试过程：我们*希望*我们的测试出问题的时候死机。

```rust
let client = Client::new(rocket()).expect("valid rocket instance");
```

然后，我们创建一个新`GET /`请求并将其分派，取回应用程序的响应：

```rust
let mut response = client.get("/").dispatch();
```

最后，我们确保响应中包含我们期望的信息。在这里，我们要确保两件事：

1. 状态为`200 OK`。
2. 正文是字符串“ Hello，world！”。

我们通过`Response`直接检查对象来做到这一点：

```rust
assert_eq!(response.status(), Status::Ok);
assert_eq!(response.body_string(), Some("Hello, world!".into()));
```

就这样！总的来说，这看起来像：

```rust
#[cfg(test)]
mod test {
    use super::rocket;
    use rocket::local::Client;
    use rocket::http::Status;

    #[test]
    fn hello_world() {
        let client = Client::new(rocket()).expect("valid rocket instance");
        let mut response = client.get("/").dispatch();
        assert_eq!(response.status(), Status::Ok);
        assert_eq!(response.body_string(), Some("Hello, world!".into()));
    }
}
```

可以使用运行测试`cargo test`。您可以[在GitHub上找到此示例](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/testing)的完整源代码。