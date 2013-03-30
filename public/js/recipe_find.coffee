$(document).ready ->
  iterate = 5

  $("#simpleSearch").click (e) ->
    $(".standard").attr('action', "/search_recipe")
    $(".standard").submit()

    
       
  $("#bayesianSearch").click (e) ->
    $(".standard").attr('action', "/bayesian_recipe")
    $(".standard").submit()
    
  $("#simpleSearch").hover (e) ->
    $(".inputDescription").html("<p class='inputDescriptionText'>Simple Search: We will return the recipes that best highlight your chosen ingredients</p>")
  $("#simpleSearch").mouseout (e) -> 
    $(".inputDescription").html("")
    
  $("#bayesianSearch").hover (e) ->
    $(".inputDescription").html("<p class='inputDescriptionText'>Bayesian Search: We use our data to suggest synergystic ingredients - you do the rest!</p>")
  $("#bayesianSearch").mouseout (e) -> 
    $(".inputDescription").html("")
  
  $(".more").hover (e) ->
    $(".inputDescription").html("<p class='inputDescriptionText'>Add additional search criteria</p>")
  $(".more").mouseout (e) ->
    $(".inputDescription").html("")
  $(".more").click (e) ->
    $(".inputDescription").html("")
    
  $("#sliderWrap").hover (e) ->
    $(".inputDescription").html("<p class='inputDescriptionText'> Use the slider to change your results. Numbers close to 10 will be low risk, strongly rooted in existing recipes. Values closer to 0 will be riskier, but with a chance to make something new!</p>")
  $("#sliderWrap").mouseout (e) ->
    $(".inputDescription").html("")
  
  $("#previousSet").click (e) ->
    start = parseInt($("#currentPos").val())
    min = Math.max(start-iterate,1)   
    max = min+(iterate-1)
    $("#currentPos").val(min)

    reload_function(min,max)

  
  $("#nextSet").click (e) ->
    start = parseInt($("#currentPos").val())
    max = Math.min(start+(iterate+4),$("#maxSize").val())
    min = max-(iterate-1)
    $("#currentPos").val(min)
    reload_function(min,max)
    
    
  reload_function = (min,max) ->
    $("#currentPos").val(min)
    $("#beginning").text(min)
    $("#ending").text(max)
    $("#simpleSearchResult").load("/change_view_set",{ 'start': min, 'stop': max  })
    
    
    
  