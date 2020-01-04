---
layout: default
id: Running-Examples
title: 运行示例
categories:
- Quickstart
---

# 快速开始

在开始编写Rocket应用程序之前，您需要安装 **nightly** 版本的Rust。我们建议您使用 [rustup](https://rustup.rs/) 安装或配置这样的版本。如果您没有安装Rust，并希望获得更多指导，请参阅 “[入门](/rocketdoc/Getting-Started/Installing-Rust.html)” 部分。

## 运行示例

开始使用Rocket进行实验的最快方法是克隆Rocket存储库并运行`examples/`目录中包含的示例。例如，以下命令运行`hello_world`示例：

```shell
git clone https://github.com/SergioBenitez/Rocket
cd Rocket
git checkout v0.4.2
cd examples/hello_world
cargo run
```

`examples/`目录中有许多示例。它们都可以运行`cargo run`。

### 注意

示例`Cargo.toml`文件将指向本地克隆的`rocket`库。复制示例供自己使用时，应`Cargo.toml`按照[《入门指南》](/rocketdoc/Getting-Started/Hello-World.html)中的说明修改文件。