class CreateHandlesTable < ActiveRecord::Migration
  def change
    create_table :handles_tables do |t|
    	t.string :handle
    	t.references :user
    	t.timestamps
    end
  end
end
