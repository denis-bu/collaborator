class MessagesFetcher

  def initialize(conversation, params)
    @messages = conversation.messages
  end

  def messages
    @messages
  end

end