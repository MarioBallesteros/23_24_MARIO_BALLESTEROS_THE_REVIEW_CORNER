$(function(){
    $("#wizard").steps({
        headerTag: "h2",
        bodyTag: "section",
        transitionEffect: "fade",
        enableAllSteps: true,
        transitionEffectSpeed: 500,
        labels: {
            finish: "Registrarme",
            next: "Continuar",
            previous: "Retroceder"
        },
        onFinished: function (event, currentIndex) {
            $("#wizard").submit();
        }
    });

    $("#wizard").submit(function(e) {
        e.preventDefault();
        var formData = $(this).serialize();
        $.post('/registro', formData, function(data) {
            alert('Registro completado con éxito.');
            window.location.href = '/'; // Redirige si el registro es exitoso.
        }).fail(function() {
            alert('Error al guardar los datos.');
        });
    });
    
    $('.wizard > .steps li a').click(function(){
    	$(this).parent().addClass('checked');
		$(this).parent().prevAll().addClass('checked');
		$(this).parent().nextAll().removeClass('checked');
    });
    // Custome Jquery Step Button
    $('.forward').click(function(){
    	$("#wizard").steps('next');
    })
    $('.backward').click(function(){
        $("#wizard").steps('previous');
    })
    // Select Dropdown
    $('html').click(function() {
        $('.select .dropdown').hide(); 
    });
    $('.select').click(function(event){
        event.stopPropagation();
    });
    $('.select .select-control').click(function(){
        $(this).parent().next().toggle();
    })    
    $('.select .dropdown li').click(function(){
        $(this).parent().toggle();
        var text = $(this).attr('rel');
        $(this).parent().prev().find('div').text(text);
    })
})
