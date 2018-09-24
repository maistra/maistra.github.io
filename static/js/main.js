$(document).ready(function() {
    // toggle toolbar buttons
    $(document).on('mouseenter', 'pre', function () {
        $(this).next().addClass("toolbar-show");
        $(this).next().next().addClass("toolbar-show");
        $(this).next().next().next().addClass("toolbar-show");
    });

    // toggle toolbar buttons
    $(document).on('mouseleave', 'pre', function () {
        $(this).next().removeClass("toolbar-show");
        $(this).next().next().removeClass("toolbar-show");
        $(this).next().next().next().removeClass("toolbar-show");
    });

    // toggle copy button
    $(document).on('mouseenter', 'button.copy', function () {
        $(this).addClass("toolbar-show");
    });

    // toggle copy button
    $(document).on('mouseleave', 'button.copy', function () {
        $(this).removeClass("toolbar-show");
    });

    // toggle download button
    $(document).on('mouseenter', 'button.download', function () {
        $(this).addClass("toolbar-show");
    });

    // toggle download button
    $(document).on('mouseleave', 'button.download', function () {
        $(this).removeClass("toolbar-show");
    });

    // toggle print button
    $(document).on('mouseenter', 'button.print', function () {
        $(this).addClass("toolbar-show");
    });

    // toggle print button
    $(document).on('mouseleave', 'button.print', function () {
        $(this).removeClass("toolbar-show");
    });
});
