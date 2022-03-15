
class RateLimited {

  Function func;

  int usesBeforeLimit;

  Duration rateLimitedTime;

  late int usesRemaining;

  bool isCountingStarted = false;

  bool isSomethingExecuting = false;

  List<List<dynamic>> executionsInQueue = [];

  RateLimited(this.func, this.usesBeforeLimit, this.rateLimitedTime) {
    usesRemaining = usesBeforeLimit;
  }

  Future<void> call(List<dynamic> args, Map<Symbol, dynamic> namedArgs) async {

    executionsInQueue.add([args, namedArgs]);

    await execute();

  }

  Future<void> execute() async {

    if (isSomethingExecuting) {

      return;

    }

    if (!isCountingStarted) {

      launchTimeReset();

    }

    if (usesRemaining >= 1) {

      isSomethingExecuting = true;

      usesRemaining--;

      await Function.apply(func, executionsInQueue.first[0], executionsInQueue.first[1]);

      executionsInQueue.removeAt(0);

      isSomethingExecuting = false;

    }

  }

  Future<void> launchTimeReset() async {

    isCountingStarted = true;

    await Future.delayed(rateLimitedTime);

    usesRemaining = usesBeforeLimit;

    isCountingStarted = false;

    var limit = (executionsInQueue.length > usesBeforeLimit) ? usesBeforeLimit : executionsInQueue.length;

    for (var i = 0; i < limit; i++) {

      await execute();

    }

  }

}
