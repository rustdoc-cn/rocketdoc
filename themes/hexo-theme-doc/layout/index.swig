<!DOCTYPE html>
<html>
<head>
  {% include "_partial/meta.swig" %}
  <title>{{config.title}}</title>
  {% include "_partial/link.swig" %}
</head>
<body>
  {% include "_partial/menu.swig" %}
  <div class='page'>
  {% for post in page.posts %}
    {% if post.indexshow == true %}
      <div class='page-content'>
        <div class="markdown-body">{{post.content}}</div>
      </div>
    {% endif %}
  {% endfor %}
  </div>
  {% include "_partial/script.swig" %}
</body>
</html>