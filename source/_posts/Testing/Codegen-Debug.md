---
layout: default
id: Codegen-Debug
title: 代码生成调试
---

## 代码生成调试

检查Rocket的代码生成所发出的代码是很有用的，特别是当您遇到奇怪的类型错误时。要让Rocket记录发送到控制台的代码，请在编译时设置 `ROCKET_CODEGEN_DEBUG` 环境变量：

```shell
ROCKET_CODEGEN_DEBUG=1 cargo build
```

在编译期间，您应该看到如下输出：

```shell
 --> examples/hello_world/src/main.rs:7:1
  |
7 | #[get("/")]
  | ^^^^^^^^^^^
  |
  = note:
    fn rocket_route_fn_hello<'_b>(
        __req: &'_b ::rocket::Request,
        __data: ::rocket::Data
    ) -> ::rocket::handler::Outcome<'_b> {
        let responder = hello();
        ::rocket::handler::Outcome::from(__req, responder)
    }
```

这对应于Rocket为`hello`路由生成的外观请求处理程序。