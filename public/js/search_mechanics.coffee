json_ingredients = ""

$.getJSON "/json/simple_search.json", (e) ->
    json_ingredients = e  
    
$(document).ready ->
  $(".more").live "click", (e)->
    currentRow = $(this).closest('tr')
    idNumber = $(this).closest('tbody').children().length-1;
    
    newHTML = '<tr>'+
        '<td>'+
          '<p class="more"><a class="button">+</a></p>' +
        '</td>'+
        '<td>'+
          '<input type="text" name="like'+idNumber+'" class="ingredientSearch"/>'+
        '</td>'+
        '<td>'+
          '<input type="text" name="dislike'+idNumber+'" class="ingredientSearch"/>'+
        '</td>'+
      '</tr>'
    $(this).parent().html('<p class="less"><a class="button">-</a></p>')
    currentRow.after(newHTML).fadeIn('slow')
    
    $(".less").live "click", (e)->
      currentRow = $(this).closest('tr') 
      currentRow.fadeOut('fast')
   
    #$(".suggestion").live "click", (e)->
      #alert $(this).parent().parent().parent().parent()
      
     # $(this).parent().parent().parent().parent().eq(0).val($(this).text())

#$(".suggestion").live "click", (e)->
  #BoxChildren = $(this).parent().parent().parent().parent().parent().children()
  #BoxChildren.eq(0).val($(this).text())
  #BoxChildren.eq(1).remove()
  
#$(".ingredientSearch").live "change", (e)->
  #$(this).parent().children().eq(1).remove()

  
  $(".ingredientSearch").live "keyup", (e)->
      
      inputUse = $(this)
      #suggestListParent = inputUse.parent()
      #suggestListDiv =  inputUse.parent().children().eq(1)
      sendDat = inputUse.attr("value")
  
      if sendDat.length < 3
        #suggestListDiv.remove()
      
      else  
        inputUse.autocomplete({ source : json_ingredients})
        #load json on load, and set that as source
        #$.ajax "/search_suggest",
          #type: "get"
          #url: "/search_suggest"
          #data: 
            #input: sendDat
          #success: (res) -> 
            #if suggestListParent.children().length > 1
              #suggestListDiv.html(res)
              
              #inputUse.text(res[0])
            #else
             
              
              #inputUse.autocomplete({ source : JSON.parse res})
             
              #suggestListParent.append(res)
              
              
            