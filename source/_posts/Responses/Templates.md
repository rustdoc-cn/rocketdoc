---
layout: default
id: Templates
title: 模板
---

## 模板

Rocket包含内置的模板支持，该支持主要通过`rocket_contrib`中的[`Template`](https://api.rocket.rs/v0.4/rocket_contrib/templates/struct.Template.html)响应器来工作。例如，要渲染名为“ index”的模板，您可以返回`Template`如下类型的值：

```rust
#[get("/")]
fn index() -> Template {
    let context = /* object-like value */;
    Template::render("index", &context)
}
```

使用该`render`方法呈现模板。该方法采用模板的名称和用于渲染模板的上下文。上下文可以是实现`Serialize`并序列化为`Object`值的任何类型，例如struct `HashMaps`，和其他。

为了使模板可渲染，必须首先注册它。在`Template`连接时，**整流罩 Fairings**会自动记录所有发现的模板。所述[**整流罩 Fairings**](/rocketdoc/Fairings/Overview.html)导向的部分提供了关于**整流罩 Fairings**的更多信息。要附加模板整流罩，只需调用`.attach(Template::fairing())`以下实例`Rocket`：

```rust
fn main() {
    rocket::ignite()
        .mount("/", routes![...])
        .attach(Template::fairing());
}
```

Rocket在可[配置 附加功能](http://zzj5150.imwork.net/rocketdoc/Configuration/Extras.html)的 `template_dir` 中发现模板。火箭中的模板支撑与发动机无关。用于呈现模板的引擎取决于模板文件的扩展名。例如，如果文件以`.hbs`结尾，则使用把手；如果文件以 `.tera`结尾，则使用tera。

### 注意：模板的名称不包括其扩展名。

对于名为 `index.html.tera`的模板文件，调用 `render("index")` 并在模板中使用名称 `"index"` ，即，`{\% extends "index" \%}`或 `{\% extends "base" \%}` 作为`base.html.tera`。

### 实时重载

当您的应用程序在`debug`模式下编译时（没有`--release`传递给的标志`cargo`），在支持的平台上修改模板后，它们会自动重新加载。这意味着您无需重建应用程序即可观察模板更改：只需刷新即可！在发行版本中，禁用重新加载。

 [`Template`](https://api.rocket.rs/v0.4/rocket_contrib/templates/struct.Template.html) API文档包含有关模板的更多信息，包括如何自定义模板引擎以添加自定义帮助程序和筛选器。[Handlebars](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/handlebars_templates)模板示例是一个完全组合的应用程序，它使用Handlebars模板，而 [Tera](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/tera_templates)模板示例对Tera也一样。

