Sequel.migration do
  up do
    create_table :user_selections do
      String :first_select
      String :second_select
      Integer :select_for
      Integer :select_against
      index :first_select
      index :second_select
    end
  end

  down do
    drop_table :user_selections
  end
end
