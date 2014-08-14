$( document ).ready(function() {

$(":input[name*='type']").hide(); 
    
    $('select:input').change(function(){
        if($.inArray($(this).val(),["web_site","email_address","instant_messenger","phone_number"])!== -1) {
            $("[id = "+this.id+"_type]").show(); 
        } else {
            $("[id = "+this.id+"_type]").hide(); 
        } 
})

});
