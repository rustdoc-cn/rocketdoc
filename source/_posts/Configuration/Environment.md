---
layout: default
id: Environment
title: 环境
---

# 配置

Rocket的目标是拥有一个灵活且可用的配置系统。可以通过配置文件，环境变量或两者来配置Rocket应用程序。配置分为三个环境：开发，登台和生产。通过环境变量选择工作环境。

## 环境

在任何时间点，Rocket应用程序都在给定的*配置环境中运行*。共有三种环境：

- `development`（简称：`dev`）
- `staging`（简称：`stage`）
- `production`（简称：`prod`）

没有采取任何措施，Rocket应用程序将在`development`用于调试构建的`production`环境和用于非调试构建的环境中运行。可以通过`ROCKET_ENV`环境变量来更改环境。例如，要在`staging`环境中启动应用程序，我们可以运行：

```shell
ROCKET_ENV=stage cargo run
```

请注意，您可以使用环境名称的短或长格式来指定环境，`stage` *或* `staging`在此处指定。Rocket告诉我们选择的环境及其启动时的配置：

```shell
$ sudo ROCKET_ENV=staging cargo run

🔧  Configured for staging.
    => address: 0.0.0.0
    => port: 8000
    => log: normal
    => workers: [logical cores * 2]
    => secret key: generated
    => limits: forms = 32KiB
    => keep-alive: 5s
    => tls: disabled
🛰  Mounting '/':
    => GET / (hello)
🚀  Rocket has launched from http://0.0.0.0:8000
```

