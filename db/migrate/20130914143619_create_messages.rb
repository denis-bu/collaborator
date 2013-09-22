class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :conversation, :null => false
      t.references :user, :null => false

      t.text :content

      t.timestamps
    end
    add_index :messages, :conversation_id
    add_index :messages, :user_id
  end
end
