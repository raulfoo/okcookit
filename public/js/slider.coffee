$(document).ready ->

  $("#slider").slider 
    value: $("#risk").val(),
    orientation: "horizontal",
    range: "max",
    min: 1,
    max: 10,
    slide: (event, ui) -> 
      $("#risk").val(ui.value) 
      $("#sliderValue").text(ui.value)
  
