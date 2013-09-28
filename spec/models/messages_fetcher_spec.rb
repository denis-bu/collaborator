require 'spec_helper'

describe MessagesFetcher do

  before(:each) do
    @user1 = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @conversation = FactoryGirl.build(:conversation)
    @conversation.users = [@user1, @user2]
    @conversation.save!
  end

  describe 'default message scope' do

    it 'should fetch all messages from today' do
      past_m = @conversation.messages.create(:user => @user1, :content => 'Should not be in default scope (past)')
      past_m.created_at = Date.yesterday.end_of_day
      past_m.save!

      expected = []
      expected << @conversation.messages.create(:user => @user1, :content => 'Hello!')
      expected << @conversation.messages.create(:user => @user2, :content => 'Hi!')
      expected << @conversation.messages.create(:user => @user2, :content => 'How are you?')
      expected << @conversation.messages.create(:user => @user1, :content => 'Fine....')

      # This should not happen though :)
      future_m = @conversation.messages.create(:user => @user1, :content => 'Should not be in default scope (future)')
      future_m.created_at = Date.tomorrow.beginning_of_day
      future_m.save!

      subj = MessagesFetcher.new(@conversation, {})

      subj.messages.count.should == expected.count
      expected.each_with_index {|m, i| subj.messages[i].id.should == m.id }
    end

  end

  describe 'latest message scope' do

    it 'should fetch all messages after given sequence' do
      @conversation.messages.create(:user => @user2, :content => 'Hello!')
      m1 = @conversation.messages.create(:user => @user1, :content => 'Hi!')
      m2 = @conversation.messages.create(:user => @user2, :content => 'How are you?')
      m3 = @conversation.messages.create(:user => @user1, :content => 'Fine....')

      subj = MessagesFetcher.new(@conversation, {
          MessagesFetcher::PARAM_NAME_MODE => MessagesFetcher::MODE_LATEST,
          MessagesFetcher::PARAM_NAME_SEQ => m1.id,
      })

      subj.messages.count.should == 2
      subj.messages[0].id.should == m2.id
      subj.messages[1].id.should == m3.id
    end

  end

  describe 'history message scope' do
    it 'should fetch limited number of messages from a given sequence in a reverse order' do
      @conversation.messages.create(:user => @user2, :content => 'Not to be fetched')
      expected = []
      MessagesFetcher::LIMITS.second.times do |i|
        expected << @conversation.messages.create(
            :user => (i % 3 == 0 ? @user1 : @user2), :content => "Some message #{i}",
        )
      end
      topmost_m = @conversation.messages.create(:user => @user2, :content => 'Topmost message')

      subj = MessagesFetcher.new(@conversation, {
          MessagesFetcher::PARAM_NAME_MODE => MessagesFetcher::MODE_HISTORY,
          MessagesFetcher::PARAM_NAME_SEQ => topmost_m.id,
          MessagesFetcher::PARAM_NAME_LIMIT => MessagesFetcher::LIMITS.second,
      })

      subj.messages.count.should == MessagesFetcher::LIMITS.second
      expected.reverse.each_with_index {|m, i| subj.messages[i].id.should == m.id }
    end
  end

end
