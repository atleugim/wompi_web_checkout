import 'package:wompi_web_checkout/src/exceptions/wompi_exception.dart';

/// Aggregates validation errors so the models can report all of them in
/// a single [WompiValidationException]. Not exported.
final class ValidationErrorCollector {
  final List<WompiFieldError> _errors = [];

  /// Registers a validation error for the given [field].
  void add({required String field, required String message}) {
    _errors.add(WompiFieldError(field: field, message: message));
  }

  /// Throws a [WompiValidationException] with every collected error, if
  /// there is any.
  void throwIfAny() {
    if (_errors.isNotEmpty) throw WompiValidationException(_errors);
  }
}
