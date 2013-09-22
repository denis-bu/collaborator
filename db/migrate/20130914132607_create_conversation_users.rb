class CreateConversationUsers < ActiveRecord::Migration
  def change
    create_table :conversation_users, :id => false do |t|
      t.references :conversation, :null => false
      t.references :user, :null => false

      t.timestamps
    end
    add_index :conversation_users, [:conversation_id, :user_id], :unique => true
  end
end
