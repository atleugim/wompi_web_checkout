/// Currency in which a Wompi transaction is made.
///
/// The supported currency depends on the country of the merchant account:
/// Colombia supports only [cop] and Panama only [usd].
enum WompiCurrency {
  /// Colombian peso (`COP`).
  cop('COP'),

  /// United States dollar (`USD`).
  usd('USD');

  const WompiCurrency(this.code);

  /// The ISO 4217 code expected by the Wompi API for this currency.
  final String code;
}
