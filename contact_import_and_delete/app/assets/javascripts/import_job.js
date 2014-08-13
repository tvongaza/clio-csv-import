$( document ).ready(function() {

$(":input[name*='type']").hide(); 
    
    $('select:input').change(function(){
    	var id = this.id+'_type'
        if($.inArray($(this).val(),["web_site","email_address","instant_messenger","phone_number"])) {
            $("[id = "+id+"]").show(); 
        } else {
            $("[id = "+id+"]").hide(); 
        } 
})

  $("select").selectBoxIt({

    theme: "bootstrap"

  });

});
