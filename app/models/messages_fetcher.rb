class MessagesFetcher

  PARAM_NAME_MODE = :mode
  PARAM_NAME_SEQ = :sequence
  PARAM_NAME_LIMIT = :limit

  MODE_LATEST = 'latest'
  MODE_HISTORY = 'history'

  LIMITS = [25, 50, 100]

  def initialize(conversation, params)
    @params = params
    messages = conversation.messages
    @messages = case params[PARAM_NAME_MODE]
                  when MODE_LATEST
                    fetch_latest(messages)
                  when MODE_HISTORY
                    fetch_history(messages)
                  else
                    fetch_default(messages)
                end
  end

  def messages
    @messages
  end

  private

  def fetch_default(scope)
    within_str = '(`messages`.`created_at` > ?) and (`messages`.`created_at` < ?)'

    scope.sequence_forward.where(within_str, Date.yesterday.end_of_day, Date.tomorrow.beginning_of_day)
  end

  def fetch_latest(scope)
    sequence = @params[PARAM_NAME_SEQ]
    #TODO: limit number of returned messages somehow...
    scope.sequence_forward.where('`messages`.`id` > ?', sequence)
  end

  def fetch_history(scope)
    sequence = @params[PARAM_NAME_SEQ]
    scope = scope.where('`messages`.`id` < ?', sequence) if sequence.present?
    # Fetching messages in reverse order to apply limit.
    # This would be a part of an interface: history is in reverse order...
    scope.sequence_reverse.limit(limit_from_params)
  end

  def limit_from_params
    limit = @params[PARAM_NAME_LIMIT].to_i
    if LIMITS.include?(limit)
      limit
    else
      LIMITS.first
    end
  end

end