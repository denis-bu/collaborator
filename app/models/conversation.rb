class Conversation < ActiveRecord::Base
  attr_accessible :topic

  has_many :conversation_users
  has_many :users, :through => :conversation_users

  has_many :messages

  def user_messages(user)
    messages.where(:user_id => user.id)
  end
end
