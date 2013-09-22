module HomeHelper
  def conv_topic(conv)
    if conv.topic.blank?
      "Conversation of #{conv.users.first.nickname} and #{conv.users.last.nickname}"
    else
      conv.topic
    end
  end

end
