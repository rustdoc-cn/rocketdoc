---
layout: default
id: Request-Local-State
title: 请求本地状态
---

## 请求本地状态

虽然托管状态是全局的且在应用程序范围内可用，但请求本地状态是给定请求的本地状态，随请求一起携带，并在请求完成后丢弃。请求本地状态可以在请求 `Request` 可用时使用，例如在整流罩、请求保护器或响应器中。

请求本地状态被缓存：如果给定类型的数据已经被存储，它将被重用。这对于在路由和处理单个请求（如处理身份验证的请求）期间可能多次调用的请求保护程序特别有用。

作为示例，请考虑以下 `RequestId` 的请求保护实现，它使用请求本地状态为每个请求生成并公开唯一的整数ID：

```rust
/// A global atomic counter for generating IDs.
static request_id_counter: AtomicUsize = AtomicUsize::new(0);

/// A type that represents a request's ID.
struct RequestId(pub usize);

/// Returns the current request's ID, assigning one only as necessary.
impl<'a, 'r> FromRequest<'a, 'r> for RequestId {
    fn from_request(request: &'a Request<'r>) -> request::Outcome {
        // The closure passed to `local_cache` will be executed at most once per
        // request: the first time the `RequestId` guard is used. If it is
        // requested again, `local_cache` will return the same value.
        Outcome::Success(request.local_cache(|| {
            RequestId(request_id_counter.fetch_add(1, Ordering::Relaxed))
        }))
    }
}
```

请注意，没有请求本地状态，将不可能：

1. 将一条数据（这里是一个ID）直接与请求相关联。
2. 确保每个请求最多生成一次值。

有关更多示例，请参阅[`FromRequest`请求本地状态](https://api.rocket.rs/v0.4/rocket/request/trait.FromRequest.html#request-local-state)文档，该文档使用请求本地状态来缓存昂贵的身份验证和授权计算，以及该[`Fairing`](https://api.rocket.rs/v0.4/rocket/fairing/trait.Fairing.html#request-local-state)文档，该文档使用请求本地状态来实现请求计时。