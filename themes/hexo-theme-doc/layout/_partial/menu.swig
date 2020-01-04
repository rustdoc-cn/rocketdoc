<div class='menu'>
    <div class="toggle">
        <span class="up"></span>
        <span></span>
        <span></span>
    </div>
    <header>
        <a href='{{ url_for("/") }}'>{{config.title}}</a>
    </header>
    <nav class='menu-nav'>
        {% for section in site.data.nav %}
        <ul class='nav1'>
            <span>{{ section.title }}</span>
            <ul class='nav2'>
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
<div class="bg"></div>