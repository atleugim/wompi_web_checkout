/// Base class for all Wompi-related exceptions
abstract class WompiException implements Exception {
  /// Creates a new [WompiException] instance with the given error message
  WompiException(this.message);

  /// The error message describing what went wrong
  final String message;

  @override
  String toString() {
    return '$runtimeType: $message';
  }
}

/// Error thrown when an invalid argument is provided
class WompiInvalidArgumentException extends WompiException {
  /// Creates a new [WompiInvalidArgumentException] instance with the given
  /// argument name and optional description
  WompiInvalidArgumentException(this.argument, {this.description})
    : super(
        '''Invalid argument $argument${description != null ? ': $description' : ''}''',
      );

  /// The name of the argument that caused the error
  final String argument;

  /// Optional description of the error
  final String? description;
}

/// Error thrown when an invalid signature integrity argument or arguments are
/// provided
class WompiInvalidSignatureIntegrityArgumentsException extends WompiException {
  /// Creates a new [WompiInvalidSignatureIntegrityArgumentsException] instance
  WompiInvalidSignatureIntegrityArgumentsException()
    : super('Invalid signature integrity arguments');
}

/// Error thrown when an invalid signature integrity is created
class WompiInvalidSignatureIntegrityException extends WompiException {
  /// Creates a new [WompiInvalidSignatureIntegrityException] instance
  WompiInvalidSignatureIntegrityException()
    : super('Invalid signature integrity');
}
