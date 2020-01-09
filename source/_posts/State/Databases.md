---
layout: default
id: Databases
title: 数据库
---

## 数据库

Rocket包含与数据库无关的内置ORM支持。特别是，Rocket提供了一个过程宏，使您可以轻松地通过连接池将Rocket应用程序连接到数据库。*数据库连接池*是一个数据结构，保持在应用程序以后使用活动的数据库连接。连接池支持的此实现基于[`r2d2`](https://crates.io/crates/r2d2)请求防护并通过请求防护公开连接。数据库是通过Rocket的常规配置机制分别配置的：`Rocket.toml`文件，环境变量或过程。

使用此库将Rocket应用程序连接到数据库只需三个简单步骤：

1. 在中配置数据库`Rocket.toml`。
2. 将请求防护类型和整流罩与每个数据库相关联。
3. 使用请求防护在处理程序中检索连接。

目前，Rocket提供了对以下数据库的内置支持：

| 种类Kind | 驱动程序Driver                                               | Version  | `Poolable` Type                                              | 功能Feature            |
| -------- | ------------------------------------------------------------ | -------- | ------------------------------------------------------------ | ---------------------- |
| MySQL    | [Diesel](https://diesel.rs/)                                 | `1`      | [`diesel::MysqlConnection`](http://docs.diesel.rs/diesel/mysql/struct.MysqlConnection.html) | `diesel_mysql_pool`    |
| MySQL    | [`rust-mysql-simple`](https://github.com/blackbeam/rust-mysql-simple) | `16`     | [`mysql::conn`](https://docs.rs/mysql/14.0.0/mysql/struct.Conn.html) | `mysql_pool`           |
| Postgres | [Diesel](https://diesel.rs/)                                 | `1`      | [`diesel::PgConnection`](http://docs.diesel.rs/diesel/pg/struct.PgConnection.html) | `diesel_postgres_pool` |
| Postgres | [Rust-Postgres](https://github.com/sfackler/rust-postgres)   | `0.15`   | [`postgres::Connection`](https://docs.rs/postgres/0.15.2/postgres/struct.Connection.html) | `postgres_pool`        |
| Sqlite   | [Diesel](https://diesel.rs/)                                 | `1`      | [`diesel::SqliteConnection`](http://docs.diesel.rs/diesel/prelude/struct.SqliteConnection.html) | `diesel_sqlite_pool`   |
| Sqlite   | [`Rustqlite`](https://github.com/jgallagher/rusqlite)        | `0.16`   | [`rusqlite::Connection`](https://docs.rs/rusqlite/0.14.0/rusqlite/struct.Connection.html) | `sqlite_pool`          |
| Neo4j    | [`rusted_cypher`](https://github.com/livioribeiro/rusted-cypher) | `1`      | [`rusted_cypher::GraphClient`](https://docs.rs/rusted_cypher/1.1.0/rusted_cypher/graph/struct.GraphClient.html) | `cypher_pool`          |
| Redis    | [`redis-rs`](https://github.com/mitsuhiko/redis-rs)          | `0.10`   | [`redis::Connection`](https://docs.rs/redis/0.9.0/redis/struct.Connection.html) | `redis_pool`           |
| MongoDB  | [`mongodb`](https://github.com/mongodb-labs/mongo-rust-driver-prototype) | `0.3.12` | [`mongodb::db::Database`](https://docs.rs/mongodb/0.3.12/mongodb/db/type.Database.html) | `mongodb_pool`         |
| Memcache | [`memcache`](https://github.com/aisk/rust-memcache)          | `0.11`   | [`memcache::Client`](https://docs.rs/memcache/0.11.0/memcache/struct.Client.html) | `memcache_pool`        |

### 用法

要将您的Rocket应用程序连接到给定的数据库，请首先在与您的环境相匹配的表中标识“种类”和“驱动程序”。必须启用与您的数据库类型相对应的功能。这是在“功能”列中标识的功能。例如，对于Diesel-based SQLite 数据库，您应该输入`Cargo.toml`：

```toml
[dependencies.rocket_contrib]
version = "0.4.2"
default-features = false
features = ["diesel_sqlite_pool"]
```

然后，在`Rocket.toml`环境变量中（或等效于环境变量），在`databases`表中配置数据库的URL ：

```toml
[global.databases]
sqlite_logs = { url = "/path/to/database.sqlite" }
```

在应用程序的源代码中，创建一个具有一个内部类型的类似单元的结构。此类型应为“`Poolable`类型”列中列出的类型。然后用 `#[database]`属性装饰类型，提供在上一步中配置为唯一参数的数据库的名称。最后，附加 `YourType::fairing()`返回的整流罩，该整流罩由`#[database]`属性生成：

```rust
#[macro_use] extern crate rocket_contrib;

use rocket_contrib::databases::diesel;

#[database("sqlite_logs")]
struct LogsDbConn(diesel::SqliteConnection);

fn main() {
    rocket::ignite()
       .attach(LogsDbConn::fairing())
       .launch();
}
```

就这样！每当需要连接到数据库时，请使用您的类型作为请求保护：

```rust
#[get("/logs/<id>")]
fn get_logs(conn: LogsDbConn, id: usize) -> Result<Logs> {
    logs::filter(id.eq(log_id)).load(&*conn)
}
```

如果应用程序使用默认情况下不可用的数据库引擎功能，例如支持`chrono`或`uuid`，则可以通过在`Cargo.toml`中添加这些功能来启用这些功能，如下所示：

```toml
[dependencies]
postgres = { version = "0.15", features = ["with-chrono"] }
```

有关Rocket内置数据库支持的更多信息，请参阅[`rocket_contrib::databases`](https://api.rocket.rs/v0.4/rocket_contrib/databases/index.html)模块文档。