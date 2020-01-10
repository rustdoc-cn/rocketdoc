---
layout: default
id: Extras
title: 附加功能
---

## 附加功能

除了覆盖缺省配置参数，配置文件还可以定义为任意数量的值*额外的*配置参数。尽管Rocket不直接使用这些参数，但其他库或您自己的应用程序也可以根据需要使用它们。例如，[Template](https://api.rocket.rs/v0.4/rocket_contrib/templates/struct.Template.html)类型接受`template_dir`配置参数的值。该参数可以设置`Rocket.toml`如下：

```toml
[development]
template_dir = "dev_templates/"

[production]
template_dir = "prod_templates/"
```

这会将`template_dir`额外的配置参数设置为`"dev_templates/"`在`development`环境中`"prod_templates/"`运行时和在`production`环境中运行时。启动时，Rocket会将`[extra]`标签附加到额外的配置参数中：

```shell
🔧  Configured for development.
    => ...
    => [extra] template_dir: "dev_templates/"
```

要在您的应用程序中检索自定义的额外配置参数，我们建议结合使用[临时 Fairings](/rocketdoc/Fairings/Ad-Hoc-Fairings.html)和[托管状态](/rocketdoc/State/Managed-State.html)。例如，如果您的应用程序使用自定义`assets_dir`参数：

```rust
[development]
assets_dir = "dev_assets/"

[production]
assets_dir = "prod_assets/"
```

以下代码将：

1. 阅读临时`attach`整流罩中的配置参数。
2. 将已解析的参数存储在`AssertsDir`处于托管状态的结构中。
3. `assets`通过`State`防护装置检索路径中的参数。

```rust
struct AssetsDir(String);

#[get("/<asset..>")]
fn assets(asset: PathBuf, assets_dir: State<AssetsDir>) -> Option<NamedFile> {
    NamedFile::open(Path::new(&assets_dir.0).join(asset)).ok()
}

fn main() {
    rocket::ignite()
        .mount("/", routes![assets])
        .attach(AdHoc::on_attach("Assets Config", |rocket| {
            let assets_dir = rocket.config()
                .get_str("assets_dir")
                .unwrap_or("assets/")
                .to_string();

            Ok(rocket.manage(AssetsDir(assets_dir)))
        }))
        .launch();
}
```

