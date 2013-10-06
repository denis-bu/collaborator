/*
* MessagePane - class responsible for rendering messages. Currently accepts ol/ul containers.
*
* Messenger - class responsible for managing messages.
* Params:
*   element - selector of container.
*   url - default url for conversation
* */

function onlyDate(datetime) {
  var d = new Date(datetime);
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

function MessagePane(element) {
  this.$elementPane = jQuery(element);
}

MessagePane.MSG_CONTENT_CLASS = 'message-content';
MessagePane.MSG_DATE_HEADER_CLASS = 'message-date-header';

MessagePane.prototype.updateDateHeaders = function(timestamp, direction) {
  var msgDate = onlyDate(timestamp);
  if (!this.dateBegin && !this.dateEnd) {
    this.dateBegin = msgDate;
    this.dateEnd = msgDate;
    this.dateTag(msgDate).appendTo(this.$elementPane);
    return;
  }

  if (direction == 'prepend') {
    if (this.dateBegin.getTime() != msgDate.getTime()) {
      this.dateBegin = msgDate;
      this.dateTag(msgDate).prependTo(this.$elementPane);
    }
    return;
  }

  // Append.
  if (this.dateEnd.getTime() != msgDate.getTime()) {
    this.dateEnd = msgDate;
    this.dateTag(msgDate).appendTo(this.$elementPane);
  }
};

MessagePane.prototype.dateTag = function(date) {
  return jQuery('<div class="'+ MessagePane.MSG_DATE_HEADER_CLASS +'" />').text(date.toDateString());
};

MessagePane.prototype.contentTag = function(message) {
  var messageText = message.author + '(' + message.timestamp + '): ' + message.content;
  return jQuery('<div class="'+ MessagePane.MSG_CONTENT_CLASS +'" />').text(messageText);

};
MessagePane.prototype.prependMessage = function(message) {
  this.updateDateHeaders(message.timestamp, 'prepend');
  this.contentTag(message).insertAfter(this.$elementPane.find('div.' + MessagePane.MSG_DATE_HEADER_CLASS).first());
};

MessagePane.prototype.appendMessage = function(message) {
  this.updateDateHeaders(message.timestamp, 'append');
  this.contentTag(message).appendTo(this.$elementPane);
};


function Messenger(element, url) {
  this.fetcher = new MessageFetcher(url);
  this.pane = new MessagePane(element);

  this.sequence_begin = 4294967295;  // TODO: fix magic number.
  this.sequence_end = 0;

  this.fetchDefault();

  var that = this;
  var intervalGenerator = new DampedInterval(1000, 30000, 1.25);
  this.scheduler = new Scheduler(function() { that.fetchLatest(); }, intervalGenerator);

}

Messenger.prototype.fetchDefault = function() {
  var that = this;
  this.fetcher.fetchDefault(function(messages) {
    that.addMessagesForward(messages)
  });
};

Messenger.prototype.fetchLatest = function() {
  var that = this;
  this.fetcher.fetchLatest(function(messages) {
    that.addMessagesForward(messages)
  }, this.sequence_end);
};

Messenger.prototype.fetchBackward = function(limit) {
  var that = this;
  this.fetcher.fetchBackward(function(messages) {
    that.addMessagesBackward(messages)
  }, this.sequence_begin, limit);
};

Messenger.prototype.addMessagesForward = function(messages) {
  for (var i = 0; i < messages.length; i++) {
    this.pane.appendMessage(messages[i]);

    if (this.sequence_end < messages[i].sequence)
      this.sequence_end = messages[i].sequence;

    if (this.sequence_begin > messages[i].sequence)
      this.sequence_begin = messages[i].sequence;
  }

  //flash_success('Success in fetcher!');
};

Messenger.prototype.addMessagesBackward = function(messages) {
  for (var i = 0; i < messages.length; i++) {
    this.pane.prependMessage(messages[i]);

    if (this.sequence_end < messages[i].sequence)
      this.sequence_end = messages[i].sequence;

    if (this.sequence_begin > messages[i].sequence)
      this.sequence_begin = messages[i].sequence;
  }

  //flash_success('Success in fetcher!');
};

Messenger.prototype.pulse = function() {
  this.scheduler.pulse();
};