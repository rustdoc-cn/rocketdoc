---
layout: default
id: Rocket.toml
title: Rocket配置文件
---

## Rocket配置文件

可选`Rocket.toml`文件可用于指定每个环境的配置参数。如果不存在，则使用默认配置参数。Rocket从当前工作目录开始搜索文件。如果没有找到，Rocket将检查父目录。Rocket继续检查父目录，直到到达根目录为止。

该文件必须是一系列TOML表，每个环境最多一个，以及一个可选的“全局”表。每个表都包含与该环境的配置参数相对应的键/值对。如果缺少配置参数，则使用默认值。以下是一个完整的`Rocket.toml`文件，其中每个标准配置参数均指定有默认值：

```toml
[development]
address = "localhost"
port = 8000
workers = [number of cpus * 2]
keep_alive = 5
log = "normal"
secret_key = [randomly generated at launch]
limits = { forms = 32768 }

[staging]
address = "0.0.0.0"
port = 8000
workers = [number of cpus * 2]
keep_alive = 5
log = "normal"
secret_key = [randomly generated at launch]
limits = { forms = 32768 }

[production]
address = "0.0.0.0"
port = 8000
workers = [number of cpus * 2]
keep_alive = 5
log = "critical"
secret_key = [randomly generated at launch]
limits = { forms = 32768 }
```

Rocket自动计算 `workers` 和 `secret_key` 默认参数；以上值不是有效的TOML语法。当手动指定 `workers` 值时，该值应为整数： `workers =10`。手动指定密钥时，该值应为256位base64编码字符串。这样的字符串可以使用诸如openssl`:openssl rand-base64 32`之类的工具生成。

"global"伪环境可用于全局设置和/或重写配置参数。在`[global]`表中定义的参数，在每个环境中都会设置或重写该参数（如果已经存在）。例如，给定以下 `Rocket.toml`文件，在每个环境中， `address` 的值都是 `"1.2.3.4"` ：

```toml
[global]
address = "1.2.3.4"

[development]
address = "localhost"

[production]
address = "0.0.0.0"
```

