class CreateUserCounts < ActiveRecord::Migration[5.2]
  def change
    create_table :user_counts do |t|
      t.references :user
      t.references :count
      t.timestamps null: false
    end
  end
end
