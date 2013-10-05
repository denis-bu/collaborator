/*
* MessagePane - class responsible for rendering messages. Currently accepts ol/ul containers.
*
* Messenger - class responsible for managing messages.
* Params:
*   element - selector of container.
*   url - default url for conversation
* */

function MessagePane(element) {
  this.$elementPane = jQuery(element);
}

MessagePane.prototype.prependMessage = function(message) {
  var messageText = message.author + '(' + message.timestamp + '): ' + message.content;
  jQuery('<li />').text(messageText).prependTo(this.$elementPane);
};

MessagePane.prototype.appendMessage = function(message) {
  var messageText = message.author + '(' + message.timestamp + '): ' + message.content;
  jQuery('<li />').text(messageText).appendTo(this.$elementPane);
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