class UpdateHandles < ActiveRecord::Migration
  def change
  	change_table(:handles) do |t|
    	t.string :handle
    	t.references :user
    end
  end
end
