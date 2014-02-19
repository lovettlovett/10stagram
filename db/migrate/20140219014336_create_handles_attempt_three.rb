class CreateHandlesAttemptThree < ActiveRecord::Migration
  def change
    create_table :handles do |t|
    	t.string :handle
    	t.references :user
    	t.timestamps
    end
  end
end
