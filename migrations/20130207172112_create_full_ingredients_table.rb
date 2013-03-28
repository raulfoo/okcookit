Sequel.migration do
  up do
    create_table :full_ingredients do
      String :recipe_id
      String :ingredient
      String :ingredient_measure
    end
  end

  down do
    drop_table :full_ingredients
  end
end
