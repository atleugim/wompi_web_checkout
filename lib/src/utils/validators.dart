/// Internal field validators shared by the checkout models.
///
/// These validators are intentionally **not exported** by the package:
/// they are an implementation detail and may change without notice.
abstract final class WompiValidators {
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static final RegExp _phoneNumberRegex = RegExp(r'^\d{7,15}$');

  static final RegExp _phoneNumberPrefixRegex = RegExp(r'^\+\d{1,4}$');

  static final RegExp _countryCodeRegex = RegExp(r'^[A-Z]{2}$');

  static final RegExp _referenceRegex = RegExp(r'^[A-Za-z0-9_-]+$');

  static final RegExp _compactDateRegex = RegExp(r'^\d{8}$');

  /// Whether [value] looks like a valid email address.
  static bool isValidEmail(String value) => _emailRegex.hasMatch(value);

  /// Whether [value] is 7 to 15 digits, the E.164 national significant
  /// number limits. The country code travels separately.
  static bool isValidPhoneNumber(String value) =>
      _phoneNumberRegex.hasMatch(value);

  /// Whether [value] is a valid phone number prefix (country code).
  ///
  /// Expected format: a `+` sign followed by 1 to 4 digits (e.g. `+57`).
  static bool isValidPhoneNumberPrefix(String value) =>
      _phoneNumberPrefixRegex.hasMatch(value);

  /// Whether [value] is a valid ISO 3166-1 Alpha-2 country code
  /// (2 capital letters, e.g. `CO`).
  static bool isValidCountryCode(String value) =>
      _countryCodeRegex.hasMatch(value);

  /// Whether [value] is alphanumeric with optional dashes (`-`) or
  /// underscores (`_`).
  ///
  /// Anything else is percent-encoded in the URL and can silently break
  /// the reconciliation of the payment.
  static bool isValidReference(String value) => _referenceRegex.hasMatch(value);

  /// Whether [value] is a valid `yyyymmdd` date.
  static bool isValidCompactDate(String value) {
    if (!_compactDateRegex.hasMatch(value)) return false;

    final year = int.parse(value.substring(0, 4));
    final month = int.parse(value.substring(4, 6));
    final day = int.parse(value.substring(6, 8));
    if (month < 1 || month > 12 || day < 1 || day > 31) return false;

    // Rejects overflowing days such as 20230231, which DateTime would
    // silently roll over to March 3rd.
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }

  /// Whether [value] is an absolute `http` or `https` URL with a host.
  static bool isValidHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return false;
    return uri.isScheme('http') || uri.isScheme('https');
  }
}
