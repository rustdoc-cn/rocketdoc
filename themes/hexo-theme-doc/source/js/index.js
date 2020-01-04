$(function(){

    // 显示隐藏侧边栏
    (function () {
        var body = $('body');
        var toggle = $('.toggle');
        var click = false;
        toggle.on('click', function() {
            if(click) {
               body.removeClass('click');
            } else {
                body.addClass('click');
            }
            click = !click;
        });

        var bg = $('.bg');
        bg.on('click', function() {
            body.removeClass('click');
            click = false;
        })
    })();

})