---
layout: default
id: Implementing
title: 实现
---

## 实现

回想一下，整流罩是实现[`Fairing`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html)特征的任何类型。一个`Fairing`实现有一个必需的方法：[`info`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html#tymethod.info)，它返回一个[`Info`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html#tymethod.info)结构。Rocket使用此结构为整流罩分配名称，并确定整流罩正在注册的回调集。一个`Fairing`可以实现任何可用的回调：[`on_attach`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html#method.on_attach)，[`on_launch`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html#method.on_launch)，[`on_request`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html#method.on_request)，和[`on_response`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html#method.on_response)。每个回调都有一个默认的实现，该实现完全不执行任何操作。

#### 要求

`Fairing`必须实现一个类型`Send + Sync + 'static`。这意味着整流罩必须可跨线程边界（`Send`），线程安全（`Sync`）发送，并且只有静态引用（如果有）（`'static`）。请注意，这些界限*并不*禁止`Fairing`保持状态：状态仅需要是线程安全的且可静态使用或分配堆。

#### 例子

想象一下，我们要记录应用程序已收到的数量`GET`和`POST`请求。虽然我们可以做到这一点与要求警卫和管理状态，它需要我们每一个注释`GET`，并`POST`用自定义类型要求，污染处理程序签名。相反，我们可以创建一个在全球范围内起作用的简单整流罩。

`Counter`下面的整流罩代码正是实现了这一点。整流罩接收到请求的回调，在那里它增加在每个计数器`GET`和`POST`请求。它还接收一个响应回调，在该回调中，它`/counts`通过返回记录的计数数来响应未路由的请求。

```rust
struct Counter {
    get: AtomicUsize,
    post: AtomicUsize,
}

impl Fairing for Counter {
    // This is a request and response fairing named "GET/POST Counter".
    fn info(&self) -> Info {
        Info {
            name: "GET/POST Counter",
            kind: Kind::Request | Kind::Response
        }
    }

    // Increment the counter for `GET` and `POST` requests.
    fn on_request(&self, request: &mut Request, _: &Data) {
        match request.method() {
            Method::Get => self.get.fetch_add(1, Ordering::Relaxed),
            Method::Post => self.post.fetch_add(1, Ordering::Relaxed),
            _ => return
        }
    }

    fn on_response(&self, request: &Request, response: &mut Response) {
        // Don't change a successful user's response, ever.
        if response.status() != Status::NotFound {
            return
        }

        // Rewrite the response to return the current counts.
        if request.method() == Method::Get && request.uri().path() == "/counts" {
            let get_count = self.get.load(Ordering::Relaxed);
            let post_count = self.post.load(Ordering::Relaxed);
            let body = format!("Get: {}\nPost: {}", get_count, post_count);

            response.set_status(Status::Ok);
            response.set_header(ContentType::Plain);
            response.set_sized_body(Cursor::new(body));
        }
    }
}
```

