
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

class ReturnedRateLimited<T> {

  Function func;

  int usesBeforeLimit;

  Duration rateLimitedTime;

  late int usesRemaining;

  bool isCountingStarted = false;

  bool isSomethingExecuting = false;

  List<List<dynamic>> executionsInQueue = [];

  ReturnedRateLimited(this.func, this.usesBeforeLimit, this.rateLimitedTime) {
    usesRemaining = usesBeforeLimit;
  }

  Future<T> call(List<dynamic> args, Map<Symbol, dynamic> namedArgs) async {

    executionsInQueue.add([args, namedArgs]);

    var result = await execute();

    return result;

  }

  Future<T> execute() async {

    while (isSomethingExecuting) {

      await Future.delayed(const Duration(seconds: 1));

    }

    while (usesRemaining <= 0) {

      await Future.delayed(const Duration(seconds: 1));

    }

    if (!isCountingStarted) {

      launchTimeReset();

    }

    usesRemaining--;

    isSomethingExecuting = true;

    var result = await Function.apply(func, executionsInQueue.first[0], executionsInQueue.first[1]);

    executionsInQueue.removeAt(0);

    isSomethingExecuting = false;

    return result;

  }

  Future<void> launchTimeReset() async {

    isCountingStarted = true;

    await Future.delayed(rateLimitedTime);

    usesRemaining = usesBeforeLimit;

    isCountingStarted = false;

  }

}

class SharedReturnedRateLimited {

  int usesBeforeLimit;

  Duration rateLimitedTime;

  late int usesRemaining;

  bool isCountingStarted = false;

  bool isSomethingExecuting = false;

  List<List<dynamic>> executionsInQueue = [];

  SharedReturnedRateLimited(this.usesBeforeLimit, this.rateLimitedTime) {
    usesRemaining = usesBeforeLimit;
  }

  Future<dynamic> call(Function func, List<dynamic> args, Map<Symbol, dynamic> namedArgs) async {

    executionsInQueue.add([func, args, namedArgs]);

    var result = await execute();

    return result;

  }

  Future<dynamic> execute() async {

    while (isSomethingExecuting) {

      await Future.delayed(const Duration(milliseconds: 100));

    }

    while (usesRemaining <= 0) {

      await Future.delayed(const Duration(milliseconds: 100));

    }

    if (!isCountingStarted) {

      launchTimeReset();

    }

    usesRemaining--;

    isSomethingExecuting = true;

    var result = await Function.apply(executionsInQueue.first[0], executionsInQueue.first[1], executionsInQueue.first[2]);

    executionsInQueue.removeAt(0);

    isSomethingExecuting = false;

    return result;

  }

  Future<void> launchTimeReset() async {

    isCountingStarted = true;

    await Future.delayed(rateLimitedTime);

    usesRemaining = usesBeforeLimit;

    isCountingStarted = false;

  }

}

