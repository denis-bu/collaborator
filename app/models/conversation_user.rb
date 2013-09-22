class ConversationUser < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
  # attr_accessible :title, :body
end
