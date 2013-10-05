/*
* flash_* - helpers for popup messages to user.
*
* ConstInterval - intervals generator (always const).
*
* DampedInterval - dumped intervals generator.
* Params:
*   start - timeout to begin with.
*   end - max timeout.
*   rate - rate to calculate next timeout. next(i) = next(i-1) * rate.
*
* Scheduler - execute callback according to given timeout generator.
* */
function make_flash(css_class, content) {
  $("<div class='" + css_class +"'></div>").html(content).purr();
}

function flash_success(content) {
  make_flash("alert alert-success", content);
}

function flash_info(content) {
  make_flash("alert alert-info", content);
}

function flash_warning(content) {
  make_flash("alert", content);
}

function flash_error(content) {
  make_flash("alert alert-error", content);
}


function ConstInterval(timeout) {
  this.timeout = timeout;
}

ConstInterval.prototype.reset = function() { };
ConstInterval.prototype.next = function() { return this.timeout; };


function DampedInterval(start, end, rate) {
  this.start = start;
  this.end = end;
  this.rate = rate;

  this.reset();
}

DampedInterval.prototype.reset = function() {
  this.current = this.start / this.rate;
};

DampedInterval.prototype.next = function() {
  this.current *= this.rate;
  if (this.current > this.end)
    this.current = this.end;

  return this.current;
};


function Scheduler(callback, intervalGenerator) {
  var that = this;

  var timerCallback = function() {
    if (that.timerId)
      callback();
    that.timerId = window.setTimeout(timerCallback, intervalGenerator.next());
  };

  timerCallback();

  this.pulse = function() {
    // Clear timeout.
    if (that.timerId) {
      window.clearTimeout(that.timerId);
      delete that.timerId;
    }
    // Restart generator.
    intervalGenerator.reset();

    timerCallback();
  };
}
