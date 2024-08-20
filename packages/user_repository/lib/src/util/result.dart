class Result<T, E> {
  final T? value;
  final E? error;

  Result({
    this.value,
    this.error
  });

  bool get isSuccess => value != null;
  bool get isError => error != null;

  static Result<T, E> success<T, E>(T value) => Result(value: value);
  static Result<T, E> failure<T, E>(E error) => Result(error: error);
}
