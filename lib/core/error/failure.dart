import 'package:fpdart/fpdart.dart';

abstract class Failure {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

typedef Result<T> = Either<Failure, T>;
