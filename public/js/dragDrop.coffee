$(document).ready ->

  $("#bayesianResults").live "mouseover", (e)->
    $(this).find(".draggable").draggable 
      containment: '#content'
      helper: 'clone'
  $("#bayesianResults").live "mouseover", (e)->  
    $("#resetPrefs").click (e) ->
      $("#dropLikes").text("")
      $("#dropDislikes").text("")
  
  $("#bayesianResults").live "mouseover", (e)->  
    $(this).find(".updatePrefs").droppable
      accept: ".draggable"
      drop: (event, ui) -> 
        newPref = $(ui.draggable).text().toLowerCase()
        
        checkArrays = [$("#dropLikes"), $("#dropDislikes")]
        removeDuplicate input,newPref for input in checkArrays
        
        temp = $(this).text()
        if temp == ""
          $(this).text(newPref)
        else
          $(this).text(temp+", "+ newPref)
  
  $("#bayesianResults").live "mouseover", (e)-> 
    
    $("#tryAgain").click (e) ->
      if $("#dropLikes").text() == ""
        $(".inputDescription").html("<p class='inputDescriptionText'>Please be sure to specify at least one ingredient in the 'Likes' box.</p>")
        return
      $("#suggestionWrapper").find("ul").hide("shake", 1000)
      
      likesInput = $("#dropLikes").text().split(", ").join(",")
      dislikeInput = $("#dropDislikes").text().split(", ").join(",")
      $.ajax "/bayesian_recipe",
        type: "post",
        url: "/bayesian_recipe",
        data: 
          {like : likesInput, dislike : dislikeInput, ajax:'true', risk:$("#risk").val()}
        success: (e) ->
          $("#bayesianResults").html(e)
  
  removeDuplicate = (input,e) ->
    tempArray = input.text().split(", ")  
    test = tempArray.indexOf(e)
    
    if test != -1
      tempArray.splice(test,1)
      
    input.text(tempArray.join(", "))
  
    
      