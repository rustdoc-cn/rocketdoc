---
layout: default
id: Overview
title: 概述
---

# 整流罩 Fairings

整流罩是Rocket处理结构化中间件的方法。借助整流罩，您的应用程序可以进入请求生命周期，以记录或重写有关传入请求和传出响应的信息。

## 概述

实现该[`Fairing`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html)特征的任何类型都是*整流罩*。整流罩挂在Rocket的请求生命周期中，接收事件的回调，例如传入请求和传出响应。Rocket将有关这些事件的信息传递给整流罩；整流罩可以根据信息做它想要的。这包括重写请求或响应，记录有关事件的信息或什么都不做。

Rocket的整流罩很像其他框架的中间件，但它们有一些主要区别：

- 整流罩**不能**终止或直接响应传入的请求。
- 整流罩**不能**将任意的非请求数据注入请求中。
- 整流罩*会*阻止应用程序启动。
- 整流罩*可以*检查和修改应用程序的配置。

如果您熟悉其他框架的中间件，则可能会发现本能地达到目标。在这样做之前，请记住，Rocket提供了一组丰富的机制，例如[请求防护](/rocketdoc/Requests/Methods.html)和[数据防护](/rocketdoc/Requests/Body-Data.html)，可用于以一种干净，可组合且健壮的方式解决问题。

### 警告

作为一般经验法则，只能通过整流罩来实现*全局适用的*措施。除非身份验证或授权适用于所有或绝大多数应用程序，否则不应使用整流罩来实现身份验证或授权（而是更喜欢使用[请求防护](/rocketdoc/Requests/Request-Guards.html)）。另一方面，您应该使用整流罩来记录时间和使用情况统计数据，或者强制执行全局安全策略。

### 注册

整流罩通过实例上的[`attach`](https://api.rocket.rs/v0.4/rocket/struct.Rocket.html#method.attach)方法向Rocket注册[`Rocket`](https://api.rocket.rs/v0.4/rocket/struct.Rocket.html)。只有安装了整流罩后，它的回调才会触发。例如，以下代码片段将两个整流罩`req_fairing`和附加`res_fairing`到新的Rocket实例：

```rust
rocket::ignite()
    .attach(req_fairing)
    .attach(res_fairing)
    .launch();
```

整流罩按其注册顺序执行：第一个注册的整流罩的回调先于所有其他整流罩执行。由于整流罩回调可能不是可交换的，因此整流罩的注册顺序可能很重要。

### 回调

Rocket发出整流罩回调有四个事件。这些事件的每个描述如下：

- **注册（`on_attach`）**

  首先通过该[`attach`](https://api.rocket.rs/v0.4/rocket/struct.Rocket.html#method.attach)方法附加整流罩时，将调用Attach回调。Attach回调可以任意修改`Rocket`正在构造的实例，并可以选择中止启动。附加整流罩通常用于解析和验证配置值，中止不良配置以及将解析后的值插入托管状态以供以后检索。

- **启动（`on_launch`）**

  在Rocket应用程序启动之前立即调用启动回调。启动回调可以检查`Rocket`正在启动的实例。启动回调可以是与正在启动的Rocket应用程序相关的启动服务的便捷挂钩。

- **请求（`on_request`）**

  收到请求后立即调用请求回调。请求回调可以随意修改请求，并查看传入的数据。但是，它可能不会中止或直接响应该请求；这些问题可以通过请求防护或响应回调更好地处理。

- **响应（`on_response`）**

  准备将响应发送给客户端时，将调用响应回调。响应回调可以修改部分或全部响应。这样，当较大的应用程序失败时，可以通过根据需要重写**404**响应来使用响应整流罩来提供响应。作为另一个示例，响应整流罩也可以用于将标头注入所有传出响应中。

