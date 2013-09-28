class HomeController < ApplicationController
  def index
  end

  def start_conversation
    interlocutor = User.find(params[:interlocutor_id])

    #conv = current_user.conversations.joins(:conversation_users).
    #    where(:conversation_users => {:user_id => interlocutor.id}).first

    #conv =  ConversationUser.where(:user_id => interlocutor.id).
    #    where(:conversation_id => current_user.conversations).first.conversation

    conv =  interlocutor.conversations.where(:id => current_user.conversations).first

    if conv.nil?
      conv = Conversation.new
      conv.users = [current_user, interlocutor]
      conv.save!
    end

    redirect_to conversation_path(conv)
  end

end
