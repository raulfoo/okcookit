Sequel.migration do
  up do
    create_table :simple_ingredients do
      String :ingredient
      Float :commonality, :size => 5
      Integer :selected_for
      Integer :selected_against
      
      index :ingredient
      index :selected_for
      index :selected_against
    end
  end

  down do
    drop_table :simple_ingredients
  end
end
