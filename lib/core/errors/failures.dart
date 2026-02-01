import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'حدث خطأ في الاتصال بالخادم']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'حدث خطأ في قراءة البيانات المحفوظة']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'لا يوجد اتصال بالإنترنت']);
}

class ParseFailure extends Failure {
  const ParseFailure([super.message = 'حدث خطأ في معالجة البيانات']);
}
