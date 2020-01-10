---
layout: default
id: Conclusion
title: 总结
---

## 总结

就这样！确保已安装所有路由并测试应用程序。你现在写了一个简单的（~75行！）火箭里的巴斯特宾！这个小应用程序有许多潜在的改进，我们鼓励您通过其中的一些改进来更好地了解Rocket。以下是一些想法：

- 在索引中添加一个web表单，用户可以在其中手动输入新的粘贴。在`POST/`接受表单。使用`format`和`/`或`rank`指定应调用两个`POST/routes`中的哪一个。
- 通过添加新的`DELETE/<id>`路由，支持删除粘贴。使用`PasteID`验证`<id>`。
- 将上传限制为最大大小。如果上载超过该大小，则返回206部分状态代码。否则，返回201创建的状态代码。
- 在 `upload` 和 `retrieve` 中设置返回值的 `Content-Type` 为 `text/plain`。
- 每次上传后返回一个唯一的 **"key"** ，并要求在执行删除时key存在并匹配。使用Rocket的一个核心特征来进行关键验证。
- 添加一个`PUT /<id>`路由，允许用户用“ `<id>` ”键替换现有的粘贴（如果有的话）。
- 添加一个新路由，`GET/<id>/<lang>`该语法突出显示了语言`<lang>`的ID`<id>`粘贴。如果`<lang>`不是已知语言，请不要突出显示。可能用`FromParam`验证`<lang>`。
- 使用该[`local`模块](https://api.rocket.rs/v0.4/rocket/local/)为您的pastebin编写单元测试。
- 在进入`launch`Rocket 之前先分配一个线程，`main`以便定期清理`upload/`中空闲的旧粘贴。

您可以[在GitHub上找到完整的pastebin教程](https://github.com/SergioBenitez/Rocket/tree/v0.4/examples/pastebin)的完整源代码。