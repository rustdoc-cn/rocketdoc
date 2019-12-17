<!DOCTYPE html>
<html>
<head>
  <meta charSet='utf-8' />
  <title>{{config.title + ' - ' + page.title}}</title>
  <link href="https://cdn.bootcss.com/normalize/8.0.1/normalize.min.css" rel="stylesheet">
  <link href="https://cdn.bootcss.com/github-markdown-css/3.0.1/github-markdown.min.css" rel="stylesheet">
  <link href='{{ url_for("css/doc.css") }}' rel='stylesheet'>
</head>
<body>
  <div class='menu'>
    <nav class='menu-nav'>
      {% for section in site.data.nav %}
        <ul class='nav'>
          <span>{{ section.title }}</span>
          <ul class='nav'>
            {% for item in section.items %}
              <li>
                <a href='{{item.href || url_for(section.category + "/" + item.id + ".html") }}'{% if item.id == page.id %} class='active'{% endif %}>{{item.title}}</a>
              </li>
            {% endfor %}
          </ul>
        </ul>
      {% endfor %}
    </nav>
  </div>
  <div class='page'>
    <div class='page-content'>
      <h1>{{page.title}}</h1>
      <div class="markdown-body">{{page.content}}</div>
    </div>
  </div>
  {% if page.total > 1 %}
  <div class='switch-page'>
    {% if page.prev %}
      <a class='previous' href='{{ url_for(page.prev) }}'>Previous</a>
    {% endif %}
    {% if page.next %}
      <a class='next' href='{{ url_for(page.next) }}'>Next</a>
    {% endif %}
  </div>
  {% endif %}
</body>
</html>