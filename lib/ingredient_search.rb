class CookIt < Sinatra::Base

  get "/search_suggest" do
    
    search = params[:input]
    ingredient_suggestions = SimpleIngredient.filter(:ingredient => /#{search}/)#.sort_by(&:times_selected)
    
    output = ingredient_suggestions.all[0..9]
    output.map! do |result|
      result.ingredient
    end
     
    return output.to_json
  
  end  
  
  
  post "/change_view_set" do
  
    start = params[:start]
    stop = params[:stop]
    erb :_recipe_search, :locals=>{:start => start, :stop => stop}, :layout=> false
 
  end
 
end