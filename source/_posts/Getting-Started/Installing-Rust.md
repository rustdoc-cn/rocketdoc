---
layout: default
id: Installing-Rust
title: 安装 Rust
---

# 入门

让我们创建并运行我们的第一个Rocket应用程序。我们将确保我们具有Rust的兼容版本，创建一个依赖于Rocket的新Cargo项目，然后运行该应用程序。

## 安装Rust

Rocket充分利用了Rust的语法扩展和其他高级的，不稳定的功能。因此，我们需要使用 **nightly** 版本的Rust。如果您已经可以使用最新的Rust **nightly** 安装，请随时跳到下一部分。

要安装 **nightly** 版本的Rust，建议使用`rustup`。按照[网站](https://rustup.rs/)上的说明进行安装`rustup`。安装`rustup`后，通过运行以下命令将Rust **nightly** 配置为默认的工具链：

```shell
rustup default nightly
```

如果愿意，在以下部分中设置项目目录后，您可以通过在目录中运行以下命令，使用目录覆盖来仅对Rocket项目使用 **nightly** 版本：

```shell
rustup override set nightly
```

### 警告：Rocket 需要使用最新的 *nightly* 版本 Rust。

如果您的Rocket应用程序突然停止构建，请通过以下方式更新您的工具链和依赖项，以确保您使用的是 Rust **Nightly** 和 Rocket 的最新版本：

`rustup update && cargo update`
