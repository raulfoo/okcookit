

class OkCookIt < Sinatra::Base

  post "/search_recipe" do
    likes = Array.new()
    dislikes = Array.new()
    
    inputs = retrieve_input(params,likes,dislikes)
    
    likes = inputs[:likes]
    dislikes = inputs[:dislikes]
    
    errors = enforce_required_params([:like])
    
    if errors.empty?
      ingredient = FullIngredient.where(:ingredient => likes).exclude(:ingredient => dislikes)
  
      new = Array.new()
      output = ingredient.all
      if output.size > 0
        output.each do |temp|
          new.push(temp.recipe_id)
        end
        
        recipe_id_list = Array.new()
        new.uniq.each do |uniques| 
          recipe_id_list.push ({:recipe_id => uniques, :matches => new.count(uniques)})
        end
        
        recipe_id_list = recipe_id_list.sort_by{|x| x[:matches]}.reverse
        highest_match = recipe_id_list[0][:matches]
        
        recipe_search_list = recipe_id_list.select{|x| x[:matches] == highest_match}.map{|y| y[:recipe_id]}
        
        raw_recipes = Recipe.filter(:recipe_id => recipe_search_list).order(:recipe_id).all
        
        raw_recipes.map! do |rank|
          rank.values
        end
        
        ["commonality_score","num_ingredients"].each do |sort_col|  #"num_ingredients"
          temp = raw_recipes.sort_by{|k| k[sort_col.to_sym]}
          raw_recipes = temp 
          
          rank_index = 0
          raw_recipes.map! do |rank|
            rank_index = rank_index+1
            rank.merge({"#{sort_col}_rank".to_sym => rank_index})
          
          end
        end
        

        raw_recipes.map! do |row|
          temp_score = row[:commonality_score_rank] + row[:num_ingredients_rank]
          row.merge({:suitability_score => temp_score})
        
        end
    
        output = raw_recipes.sort_by{|k| k[:suitability_score]}
        $global_recipe_array = output
        if highest_match == likes.count
          match_return = "These recipes contain all of your desired ingredients. Buonissimo!"
        else
          match_return = "These recipes contain #{highest_match} of the #{likes.count} you specified ingredients"
        end
        
        erb :index, :locals => {:recipe_search => output, :number_matches => match_return}
      
      else
        flash[:errors] = "We could not find any of your search terms in our ingredient database. Please limit to one ingredient per box."
        redirect "/"
      end
      
    else
      flash[:errors] = errors
      redirect "/"
    end
  end
  

  post "/bayesian_recipe" do
  
    likes = Array.new()
    dislikes = Array.new()
    
    inputs = retrieve_input(params,likes,dislikes)
    
    puts params
    
    likes = inputs[:likes]
    dislikes = inputs[:dislikes]
    risk = params[:risk].to_i
    
    puts likes
    return_likes = likes.join(",")
    return_dislikes = dislikes.join(",")
    
    if risk == nil
      risk = 10
    end
    
    #puts risk.to_i
    
    errors = enforce_required_params([:like])
    
    if dislikes.nil?
      dislikes = Array.new()
    end
    
   
    if errors.empty?

      #testSearch = SimpleIngredient.filter(:ingredient => likes).sort_by(&:commonality)
      full_search = SimpleIngredient.all
      #full_bayesian = BayesianPair.all
      testSearch = nil
      
      likes.each do |row|
        testSearch = full_search.index {|x| x.ingredient == row}
      end
      
      #puts Benchmark.measure{tryThis(likes,full_search)}
   
      #puts  Benchmark.measure{andThis(likes,dislikes)}
      #should prewrite databases with all possible matches to search ingrediemts?
      if testSearch == nil
     
        flash[:errors] = "We could not find any of your search terms in our ingredient database!"
        redirect "/"
      else
      fail_safe = 0
        while true 
        
          fail_safe +=1
          if fail_safe > 20
            break
          end
          
          workDat = BayesianPair.where(:ingredient_prior => likes).exclude(:ingredient_condition => dislikes)#dislikes+starting_ingredients
          workDat = workDat.all
         
          e = Array.new()
          h = Array.new()
          peh = Array.new()
          
=begin         
          tempLikes = Array.new()
          likes.each do |row|
            tempLikes.push (0..full_bayesian.size-1).select{|x| full_bayesian[x].ingredient_prior == row}
          end
          tempLikes = tempLikes.flatten.uniq
          
          tempLikes.each do |select_index|
            temp_bayesian_select = full_bayesian[select_index]
            e.push temp_bayesian_select.ingredient_prior
            h.push temp_bayesian_select.ingredient_condition
            peh.push temp_bayesian_select.score.to_f

          end
=end
          
        
          workDat.each do |row|
            e.push row.ingredient_prior
            h.push row.ingredient_condition
            peh.push row.score.to_f
          
          end

          h.uniq.each do |row|
            #make a random integer here based on level of risk(, and only move on if passes that threshold
            #random(1-10) <= (10, - no risk, 1 high risk)
            random = rand()*10
            #puts random 
            #puts risk
            if h.count(row) < likes.length && random <= risk
              temp = find_index(h,row)
             
              temp.each do |remove|
                peh.delete_at(remove)   
                e.delete_at(remove)
                h.delete_at(remove)
              end
            end
          end
       
         #BREAK WHILE LOOP POINT HERE
         #check to make sure elements exist in pEH, if not, then break the loop and output to javascript
          if peh.size<1
          
            break
          end
  
          #base_priors = SimpleIngredient.filter(:ingredient => likes).sort_by(&:commonality)
          #full_search.index {|x| x.ingredient == row}
          
          pe = 0
          likes.each do |row|
            temp_prior = full_search[full_search.index {|x| x.ingredient == row}].commonality
            pe = pe + temp_prior
          end
          #pe = 0
          #base_priors.each do |row|
           # pe = pe + row.commonality
          #end
         
          bayesian_array = Array.new()
         
         
          h.uniq.each do |row|
      
            temp = find_index(h,row)
      
            total = 0
            temp.each do |select|
              total = total+peh[select.to_i]
            end
         
            peh_select = total/likes.length
            

            #before while loop, select all simple ingredients, and just find the from the array and take commonality
            temp_index  = full_search.index {|x| x.ingredient == row}
            ph = full_search[temp_index].commonality
            #ph = SimpleIngredient.filter(:ingredient => row).first
            #ph = ph.commonality
        
            bayesian = (peh_select/pe)*ph
            bayesian_array.push bayesian
          
          end
          
          #puts "full bayesian #{bayesian_array}"
          max_check = bayesian_array.sort.reverse[0]
         
          array_sum = bayesian_array.inject(0){|sum,item| sum + item}
         
          bayesian_array.map! do |row|
            row/array_sum
          end
         
          running_total = 0
          cumulative_array = [0]
         
          bayesian_array.each do |row|
            running_total = running_total+row
            cumulative_array.push running_total
          end

          random = rand()
         
          search_nearest = cumulative_array.select {|x| x > random}[0]
          select = cumulative_array.index(search_nearest)-1
         
          add_word = h[select]
         
          likes.push add_word
          dislikes.push add_word
          #puts "one loop done"
          e.clear
          h.clear
          peh.clear
          
          if max_check < 0.05 && risk < 10
            break
          end
          #workDat.clear
        end
      end
    else
     
      flash[:errors] = errors
      redirect "/"
    end
    
    if params[:ajax].nil? 
      puts "not ajax"
      erb :index, :locals => {:bayes_results => likes, :likelist => return_likes,:dislikelist => return_dislikes, :risk_value => risk}
    else
      puts "ajax"
      erb :_bayes_results, :locals => {:ingredients => likes, :likelist => return_likes,:dislikelist => return_dislikes}, :layout=> false
    end
        

  end
  
 #this function might be superfluous given the .index function.. 
  def find_index(array,search)
    temp = array.clone
    indices = Array.new()
    
    while true
      this_index = temp.index(search)    
      if this_index.nil? == false
        temp.delete_at(this_index)
        indices.push this_index
      else
        break
      end
    end
    temp.clear
    return indices
  end
  
  
  def retrieve_input(params,likes,dislikes)

    params.each do |key,input|
      
      if key[0..3] == "like"
        input.split(",").each do |temp|
          likes.push temp.downcase
        end
      elsif key[0..6] == "dislike"
        input.split(",").each do |temp|
          dislikes.push temp.downcase
        end
      end
    end
    
    #For data gathering and alogrithmn improvement...
    #UserSelection.update(:select_for => :select_for+1).where(:first_select => likes, :second_select => likes)
    #UserSelection.update(:select_against => :select_against+1).where(:first_select => likes, :second_select => dislikes)
    #Could also consider not liking two things a positive correlation
    #UserSelect.update(:select_for => :select_for+1).where(:first => dislikes, :second => dislikes)
    
    #for improving searches...
    #SimpleIngredient.update(:select_for => :select_for+1).where(:ingredient => likes)
    #SimpleIngredient.update(:select_against => :select_against+1).where(:ingredient => dislikes)
    
    return {:likes =>likes, :dislikes => dislikes}
  end
  
  
  
  
  def tryThis(likes,full_search)
=begin
    e = Array.new()
    h = Array.new()
    peh = Array.new()
    tempLikes = Array.new()
      likes.each do |row|
        tempLikes.push (0..full_bayesian.size-1).select{|x| full_bayesian[x].ingredient_prior == row}
      end
      tempLikes = tempLikes.flatten.uniq
      
      tempLikes.each do |select_index|
        temp_bayesian_select = full_bayesian[select_index]
        e.push temp_bayesian_select.ingredient_prior
        h.push temp_bayesian_select.ingredient_condition
        peh.push temp_bayesian_select.score.to_f

      end
=end

    pe = 0
          likes.each do |row|
            temp_prior = full_search[full_search.index {|x| x.ingredient == row}].commonality
            pe = pe + temp_prior
          end
   end
   
   def andThis(likes,dislikes)
=begin
     workDat = BayesianPair.where(:ingredient_prior => likes).exclude(:ingredient_condition => dislikes)#dislikes+starting_ingredients
     
      e = Array.new()
      h = Array.new()
      peh = Array.new()
      workDat = Array.new()
      
      workDat.each do |row|
        e.push row.ingredient_prior
        h.push row.ingredient_condition
        peh.push row.score.to_f
      
      end
=end

   base_priors = SimpleIngredient.filter(:ingredient => likes).sort_by(&:commonality)
   
   pe = 0
    base_priors.each do |row|
      pe = pe + row.commonality
    end
   end
   
   
  
end