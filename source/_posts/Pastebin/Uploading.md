---
layout: default
id: Uploading
title: 上传
---

## 上传

您可能会想到，pastebin最复杂的方面是处理上传请求。当用户尝试上传pastebin时，我们的服务需要为上传生成唯一的ID，读取数据，将其写到文件或数据库中，然后返回带有该ID的URL。从生成ID开始，我们将一步一步地完成每个步骤。

#### 唯一ID

生成唯一且有用的ID是一个有趣的话题，但这超出了本教程的范围。相反，我们仅提供`PasteID`表示*可能*唯一ID 的结构的代码。通读代码，然后将其复制/粘贴到目录中命名的新文件`paste_id.rs`中`src/`：

```rust
use std::fmt;
use std::borrow::Cow;

use rand::{self, Rng};

/// Table to retrieve base62 values from.
const BASE62: &[u8] = b"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

/// A _probably_ unique paste ID.
pub struct PasteID<'a>(Cow<'a, str>);

impl<'a> PasteID<'a> {
    /// Generate a _probably_ unique ID with `size` characters. For readability,
    /// the characters used are from the sets [0-9], [A-Z], [a-z]. The
    /// probability of a collision depends on the value of `size` and the number
    /// of IDs generated thus far.
    pub fn new(size: usize) -> PasteID<'static> {
        let mut id = String::with_capacity(size);
        let mut rng = rand::thread_rng();
        for _ in 0..size {
            id.push(BASE62[rng.gen::<usize>() % 62] as char);
        }

        PasteID(Cow::Owned(id))
    }
}

impl<'a> fmt::Display for PasteID<'a> {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{}", self.0)
    }
}
```

然后，在`src/main.rs`中添加以下内容`extern crate rocket`：

```rust
extern crate rand;

mod paste_id;

use paste_id::PasteID;
```

最后，将`rand`板条箱的依赖项添加到`Cargo.toml`文件中：

```toml
[dependencies]
# existing Rocket dependencies...
rand = "0.6"
```

然后，确保您的应用程序使用新代码进行构建：

```
cargo build
```

对于我们添加的新代码，您可能会看到许多 "unused"的警告：这是可以预期的。我们将很快使用新代码。

### 数据处理

信不信由你，困难的部分已经完成！（*哇！*）。

要处理上传，我们需要一个地方来存储上传的文件。为简化起见，我们将上传的文件存储在名为的目录中`upload/`。在`upload`目录旁边创建一个`src`目录：

```shell
mkdir upload
```

对于`upload`路线，我们需要`use`一些项目：

```rust
use std::io;
use std::path::Path;

use rocket::Data;
use rocket::http::RawStr;
```

该[数据](https://api.rocket.rs/v0.4/rocket/data/struct.Data.html)结构是关键的位置：它代表一个未打开的流以传入请求正文数据。我们将使用它来将传入的请求有效地流式传输到文件。

### 上传路径

我们终于准备好编写`upload`路线了。在我们向您展示代码之前，您应该尝试自己编写路由。这是一个提示：可能的路由和处理程序签名如下所示：

```rust
#[post("/", data = "<paste>")]
fn upload(paste: Data) -> io::Result<String>
```

您的代码应：

1. 创建`PasteID`您选择的新长度。
2. 在`upload/`给定的内部构造一个文件名`PasteID`。
3. 将传输`Data`到具有构造文件名的文件。
4. 根据构造URL `PasteID`。
5. 将URL返回给客户端。

这是我们的版本（在中`src/main.rs`）

```rust
#[post("/", data = "<paste>")]
fn upload(paste: Data) -> io::Result<String> {
    let id = PasteID::new(3);
    let filename = format!("upload/{id}", id = id);
    let url = format!("{host}/{id}\n", host = "http://localhost:8000", id = id);

    // Write the paste out to the file and return the URL.
    paste.stream_to_file(Path::new(&filename))?;
    Ok(url)
}
```

确保路由已挂载在根路径上：

```rust
fn main() {
    rocket::ignite().mount("/", routes![index, upload]).launch();
}
```

测试您的路线可通过行驶`cargo run`。在另一个终端上，使用上载文件`curl`。然后，验证文件是否已`upload`使用正确的ID 保存到目录中：

```shell
# in the project root
cargo run

# in a seperate terminal
echo "Hello, world." | curl --data-binary @- http://localhost:8000
# => http://localhost:8000/eGs

# back to the terminal running the pastebin
<ctrl-c>     # kill running process
ls upload    # ensure the upload is there
cat upload/* # ensure that contents are correct
```

请注意，由于我们尚未创建`GET /`路线，因此访问返回的URL将导致**404**。我们现在将修复它。