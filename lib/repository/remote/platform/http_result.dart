class Error {
  final int code;
  final String? msg;

  Error(this.code, {this.msg});

  @override
  String toString() {
    return 'Error{code: $code, msg: $msg}';
  }
}

class Result<T> {
  final T? data;
  final Error? error;

  Result(this.data, this.error);

  Result.success(T data) : this(data, null);

  Result.failure(Error error) : this(null, error);

  bool hasError() => error != null;

  bool isSuccessful() => error == null && data != null;

  @override
  String toString() {
    return 'Result{data: $data, error: $error}';
  }
}
