<!DOCTYPE html>
<html lang="zh-cn">
<head>
  {% include "_partial/meta.swig" %}
  <title>{{config.title + ' - ' + page.title}}</title>
  {% include "_partial/link.swig" %}
</head>
<body>
  {% include "_partial/menu.swig" %}
  <div class='page'>
    <div class='page-content'>
      <div class="markdown-body">{{page.content}}</div>
    </div>
  </div>
  {% include "_partial/script.swig" %}
</body>
</html>