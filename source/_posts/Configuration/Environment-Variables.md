---
layout: default
id: Environment-Variables
title: 环境变量
---

## 环境变量

可以通过环境变量覆盖所有配置参数，包括附加参数。要覆盖配置参数`{param}`，请使用名为的环境变量`ROCKET_{PARAM}`。例如，要覆盖“端口”配置参数，可以使用以下命令运行应用程序：

```shell
ROCKET_PORT=3721 ./your_application

🔧  Configured for development.
    => ...
    => port: 3721
```

环境变量优先于所有其他配置方法：如果设置了变量，它将用作参数的值。将变量值解析为TOML语法。作为说明，请考虑以下示例：

```toml
ROCKET_INTEGER=1
ROCKET_FLOAT=3.14
ROCKET_STRING=Hello
ROCKET_STRING="Hello"
ROCKET_BOOL=true
ROCKET_ARRAY=[1,"b",3.14]
ROCKET_DICT={key="abc",val=123}
```

