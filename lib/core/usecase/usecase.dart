import 'package:flutter_application_1/core/error/failure.dart';

abstract interface class UseCase<Output, Params> {
  Future<Result<Output>> call(Params params);
}

class NoParams {
  const NoParams();
}
