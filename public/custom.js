function urlify(text)
{
    var urlRegex = /(https?:\/\/[^\s]+)/g;

    return text.replace(urlRegex, function(url)
    {
        return '<a href="' + url + '">' + url + '</a>';
    })
    // or alternatively
    // return text.replace(urlRegex, '<a href="$1">$1</a>')
}

function teamify(bg, fg, team)
{
    $('body').css('background-color', bg);

    $('#wrapper').css('background-color', bg);

    $('.test').css('color', fg);
    $('.test').css('background-color', bg);

    $('.' + team).css('color', fg);
    $('.' + team).css('background-color', bg);
    $('.' + team).css('border-color', fg);
}

function test(button)
{
    if ( button.className !== 'rops' )
    {
        var team = 'rops';
        button.className = team;
        teamify('#ffffff', '#0A4388', team)
    }
    else
    {
        var team = 'button';
        button.className = team;
        teamify('#000000', 'lime', team)
    }
}

function resize_ascii()
{
    var temp = $(".test").length;

    for (var i = 0; i < temp; i++)
    {
        var center = $("#x" + i).width()/2;

        var screenWidth = $(window).width()/2;

        var width = screenWidth - center;

        $("#x" + i).css("margin-left", width);
    }
}

$(document).ready(function()
{
    resize_ascii();
    $('#wrapper').html(urlify($('#wrapper').html()));
});

$(window).resize(function()
{
   resize_ascii();
});