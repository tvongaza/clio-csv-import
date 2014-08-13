$( document ).ready(function() {

$("#success-tbl").hide();

$("#non-success-tbl").hide();

$("#success-btn").on("click",function(){
		$("#non-success-tbl").hide();
		$("#success-tbl").show();
        $("[name = 'button']").on("click",function(){
          var tr = $(this).closest('tr');
         tr.css("background-color","#FF3700");
         tr.fadeOut(400, function(){
            tr.remove();
         });
         
         var data = $(this).attr("data-contact-id");

         var contact = {id: data};
         
         $.ajax({
            url: 'create',
            type: 'POST',
            data: contact
         });
         return false;
        });

  });

$("#non-success-btn").on("click",function(){
		$("#success-tbl").hide();
		$("#non-success-tbl").show();

  });



});