Sequel.migration do
  up do
    create_table :bayesian_pairs do
      String :ingredient_condition
      String :ingredient_prior
      Float :score, :size=> 5
      index :ingredient_condition
      index :ingredient_prior
    end
  end

  down do
    drop_table :bayesian_pairs
  end
end
