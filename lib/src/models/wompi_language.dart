/// Language the Web Checkout page is rendered in.
///
/// Sent as `default-language`, documented for Panama only: a Colombian
/// checkout rejects it.
enum WompiLanguage {
  /// Spanish — `es`.
  spanish('es'),

  /// English — `en`.
  english('en');

  const WompiLanguage(this.code);

  /// The code expected by the Wompi Web Checkout for this language.
  final String code;
}
