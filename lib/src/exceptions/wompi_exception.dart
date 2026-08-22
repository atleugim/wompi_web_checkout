import 'package:meta/meta.dart';

/// A single validation failure, as found in
/// [WompiValidationException.errors].
@immutable
final class WompiFieldError {
  /// Creates a [WompiFieldError] for [field].
  const WompiFieldError({required this.field, required this.message});

  /// Name of the field that failed validation (e.g. `amountInCents`).
  final String field;

  /// Human readable description of why the value is invalid.
  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WompiFieldError &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          message == other.message;

  @override
  int get hashCode => Object.hash(field, message);

  @override
  String toString() => '$field: $message';
}

/// Base class for every exception thrown by this package: catch it to
/// handle any error raised while building checkout data or a checkout
/// URL.
sealed class WompiException implements Exception {
  /// Creates a [WompiException] with a human readable [message].
  const WompiException(this.message);

  /// Human readable description of what went wrong.
  final String message;

  @override
  String toString() => 'WompiException: $message';
}

/// Thrown when one or more fields fail validation.
///
/// Every problem found is reported at once through [errors], so they can
/// be fixed in a single pass:
///
/// ```dart
/// try {
///   WompiCheckoutData(reference: '', amountInCents: 0);
/// } on WompiValidationException catch (e) {
///   for (final error in e.errors) {
///     print('${error.field}: ${error.message}');
///   }
/// }
/// ```
final class WompiValidationException extends WompiException {
  /// Creates a [WompiValidationException] with the [errors] found,
  /// stored as an unmodifiable view.
  ///
  /// Throws an [ArgumentError] if [errors] is empty.
  WompiValidationException(List<WompiFieldError> errors)
      : errors = List.unmodifiable(_checked(errors)),
        super(_describe(errors));

  /// Every validation error detected, in the order they were found.
  final List<WompiFieldError> errors;

  static List<WompiFieldError> _checked(List<WompiFieldError> errors) {
    if (errors.isEmpty) {
      throw ArgumentError.value(errors, 'errors', 'Cannot be empty.');
    }
    return errors;
  }

  static String _describe(List<WompiFieldError> errors) {
    final buffer = StringBuffer(
      errors.length == 1
          ? 'Found 1 validation error'
          : 'Found ${errors.length} validation errors',
    );
    for (final error in errors) {
      buffer.write('\n  • ${error.field}: ${error.message}');
    }
    return buffer.toString();
  }

  @override
  String toString() => 'WompiValidationException: $message';
}
