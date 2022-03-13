
class RateLimited {

  Function func;

  int usesBeforeLimit;

  Duration rateLimitedTime;

  late int usesRemaining;

  bool isCountingStarted = false;

  List<List<dynamic>> executionsInQueue = [];

  RateLimited(this.func, this.usesBeforeLimit, this.rateLimitedTime) {
    usesRemaining = usesBeforeLimit;
  }

  Object? call(List<dynamic> args, Map<Symbol, dynamic> namedArgs) {

    executionsInQueue.add([args, namedArgs]);

    execute();

  }

  void execute() {

    if (!isCountingStarted) {

      launchTimeReset();

    }

    if (usesRemaining >= 1) {

      usesRemaining--;

      Function.apply(func, executionsInQueue.first[0], executionsInQueue.first[1]);

      executionsInQueue.removeAt(0);

    }

  }

  Future<void> launchTimeReset() async {

    isCountingStarted = true;

    await Future.delayed(rateLimitedTime);

    usesRemaining = usesBeforeLimit;

    isCountingStarted = false;

    var limit = (executionsInQueue.length > 5) ? 5 : executionsInQueue.length;

    for (var i = 0; i < limit; i++) {

      execute();

    }

  }

}
