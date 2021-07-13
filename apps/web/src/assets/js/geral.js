// // function mostraDialogo(mensagem, tipo, tempo){
    
// //     // se houver outro alert desse sendo exibido, cancela essa requisição
// //     if($("#message").is(":visible")){
// //         return false;
// //     }

// //     // se não setar o tempo, o padrão é 3 segundos
// //     if(!tempo){
// //         var tempo = 3000;
// //     }

// //     // se não setar o tipo, o padrão é alert-info
// //     if(!tipo){
// //         var tipo = "info";
// //     }

// //     // monta o css da mensagem para que fique flutuando na frente de todos elementos da página
// //     var cssMessage = "display: block; position: fixed; top: 0; left: 20%; right: 20%; width: 60%; padding-top: 10px; z-index: 9999";
// //     var cssInner = "margin: 0 auto; box-shadow: 1px 1px 5px black;";

// //     // monta o html da mensagem com Bootstrap
// //     var dialogo = "";
// //     dialogo += '<div id="message" style="'+cssMessage+'">';
// //     dialogo += '    <div class="alert alert-'+tipo+' alert-dismissable" style="'+cssInner+'">';
// //     dialogo += '    <a href="#" class="close" data-dismiss="alert" aria-label="close">×</a>';
// //     dialogo +=          mensagem;
// //     dialogo += '    </div>';
// //     dialogo += '</div>';

// //     // adiciona ao body a mensagem com o efeito de fade
// //     $("body").append(dialogo);
// //     $("#message").hide();
// //     $("#message").fadeIn(200);

// //     // contador de tempo para a mensagem sumir
// //     setTimeout(function() {
// //         $('#message').fadeOut(300, function(){
// //             $(this).remove();
// //         });
// //     }, tempo); // milliseconds

// // }


function formataData(evt, campo) 
{
	if (soNumero(evt, campo))
	{
		var unicode = (evt.which) ? evt.which : evt.keyCode;

		vr = campo.value;
		vr = vr.replace( ".", "" );
		vr = vr.replace( "-", "" );
		vr = vr.replace( "/", "" );
		vr = vr.replace( "/", "" );
		vr = vr.replace( "/", "" );
		tam = vr.length + 1;
		
		if (unicode >= 48 && unicode <= 57)
		{
			if (tam > 2 && tam < 5)
				campo.value = vr.substr(0, 2) + '/' + vr.substr(2, tam);
			if (tam >= 5 && tam <= 10)
				campo.value = vr.substr(0, 2) + '/' + vr.substr(2, 2) + '/' + vr.substr(4, 4); 
		}
		return true;
	}
	return false;
}

function soNumero(evt, campo)
{
	if (navigator.appCodeName == 'Mozilla' && (navigator.appName == 'Netscape' || navigator.appName == 'Opera'))
	{
		if (evt.which)
		{
			if ((evt.which < 48 || evt.which > 57) && evt.which != 8 && evt.which != 9)
			{
				if(navigator.appName == 'Opera') // Opera
				{
					if((evt.which == 86 || evt.which == 67) && evt.ctrlKey) // Ctrl + V ou Ctrl + C
					{
						return true;
					}
				}
				else // Firefox, Chrome, Safari
				{
					if((evt.which == 118 || evt.which == 99) && evt.ctrlKey) // Ctrl + V ou Ctrl + C
					{
						return true;
					}
				}
				
				campo = '';
				return false;
			}
		}
	}
	else // IE
	{
		if (evt.keyCode < 48 || evt.keyCode > 57)
		{
			campo = '';
			return false;
		}
	}
	
	return true;
}

  $(function(){
    $('.table-striped tbody tr')
      .mouseover(function(){
        $(this).addClass('over');
      })
      .mouseout(function(){
        $(this).removeClass('over');
      });
  });
