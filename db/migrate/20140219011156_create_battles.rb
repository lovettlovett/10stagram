class CreateBattles < ActiveRecord::Migration
  def change
    create_table :battles do |t|
    	t.string :versus_handle
    	t.references :handle
    end
  end
end
