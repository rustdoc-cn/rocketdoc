---
layout: default
id: Configuring-TLS
title: 配置TLS
---

## 配置TLS

**警告：** Rocket的内置TLS **不**适合生产使用。其目的是为开发利用的*唯一*。

Rocket包括对TLS> = 1.2（传输层安全性）的内置本机支持。为了启用TLS支持，Rocket必须使用该`"tls"`功能进行编译。为此，请将`"tls"`功能添加到文件的`rocket`依赖项中`Cargo.toml`：

```toml
[dependencies]
rocket = { version = "0.4.2", features = ["tls"] }
```

TLS通过`tls`配置参数进行配置。的值`tls`必须是包含两个键的表：

- `certs`：*[string]* PEM格式的证书链路径
- `key`：*[string]*证书中PEM格式的私钥文件的路径`certs`

推荐的指定这些参数的方法是通过`global`环境：

```toml
[global.tls]
certs = "/path/to/certs.pem"
key = "/path/to/key.pem"
```

当然，您始终可以指定每个环境的配置值：

```toml
[development]
tls = { certs = "/path/to/certs.pem", key = "/path/to/key.pem" }
```

或通过环境变量：

```shell
ROCKET_TLS={certs="/path/to/certs.pem",key="/path/to/key.pem"} cargo run
```

