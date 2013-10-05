class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user

  attr_readonly :user_id
  attr_accessible :content, :user

  scope :sequence_forward, order('`messages`.`id` asc')
  scope :sequence_reverse, order('`messages`.`id` desc')

end
