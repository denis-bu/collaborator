class Message < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user

  attr_accessible :content

  def to_json
    {
        :sequence => id,
        :author => user.nickname,
        :content => content,
        :timestamp => created_at
    }.to_json
  end
end
