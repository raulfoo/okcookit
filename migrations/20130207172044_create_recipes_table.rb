Sequel.migration do
  up do
    create_table :recipes do
      String :recipe_id
      String :url
      String :recipe_title
      Float :rating, :size => 5
      Integer :reviews
      String :description
      String :img_url
      Float :commonality_score, :size => 6
      Integer :num_ingredients, :size => 2
      
      index :recipe_id
      index :recipe_title
      index :url
      
    end
  end

  down do
    drop_table :recipes
  end
end
