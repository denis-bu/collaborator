class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :topic

      t.timestamps
    end
  end
end
