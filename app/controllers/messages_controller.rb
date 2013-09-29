class MessagesController < ApplicationController

  #respond_to :json

  before_filter :fetch_conversation

  def index
    fetcher = MessagesFetcher.new @conversation, params
    @messages = fetcher.messages
    respond_to do |format|
      format.html { render }
      format.json { render :json => @messages, :status => :ok }
    end
  end

  def create
    @message = @conversation.messages.build(params[:message])
    @message.user = current_user
    if @message.save
      respond_to do |format|
        format.html { redirect_to conversation_path(@conversation)}
        format.json { render :json => { :sequence => @message.id }.to_json, :status => :ok }
      end
    else
      respond_to do |format|
        logger.warn @message.errors.full_messages
        format.html { redirect_to conversation_path(@conversation), :alert => 'Failed to create message!'}
        format.json { render :json => @message.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def update
    #fetch_message
    #
    #if @message.update_attributes(params[:message])
    #  respond_with(@message)
    #else
    #  respond_with(:status => 422)
    #end
  end

  private

  def fetch_message
    @message = @conversation.user_messages(current_user).find(params[:id])
  end

  def fetch_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

end
