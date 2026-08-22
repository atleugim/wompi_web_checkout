import 'package:wompi_web_checkout/src/models/legal_id_type.dart';
import 'package:wompi_web_checkout/src/models/wompi_currency.dart';

/// A country where Wompi operates the Web Checkout.
///
/// Wompi documents one Web Checkout per country, and the two parameter
/// catalogs are not identical. The country determines the checkout host,
/// the only [currency] supported, the identity document types accepted,
/// and which optional parameters may be sent at all.
///
/// Everything not gated here — customer data, shipping address, the
/// collection flags, the redirect URL and the expiration time — is
/// documented identically for both.
enum WompiCountry {
  /// Colombia — `checkout.wompi.co`, only [WompiCurrency.cop].
  colombia(
    currency: WompiCurrency.cop,
    checkoutHost: 'checkout.wompi.co',
    legalIdTypes: [
      WompiLegalIdType.cc,
      WompiLegalIdType.ce,
      WompiLegalIdType.nit,
      WompiLegalIdType.pp,
      WompiLegalIdType.ti,
      WompiLegalIdType.dni,
      WompiLegalIdType.rg,
      WompiLegalIdType.other,
    ],
    supportsConsumptionTax: true,
    supportsDefaultLanguage: false,
    supportsPaymentMethodReferences: true,
    displayName: 'Colombia',
  ),

  /// Panama — `checkout.wompi.pa`, only [WompiCurrency.usd].
  panama(
    currency: WompiCurrency.usd,
    checkoutHost: 'checkout.wompi.pa',
    legalIdTypes: [
      WompiLegalIdType.cc,
      WompiLegalIdType.ce,
      WompiLegalIdType.ruc,
      WompiLegalIdType.pp,
    ],
    supportsConsumptionTax: false,
    supportsDefaultLanguage: true,
    supportsPaymentMethodReferences: false,
    displayName: 'Panama',
  );

  const WompiCountry({
    required this.currency,
    required this.checkoutHost,
    required this.legalIdTypes,
    required this.supportsConsumptionTax,
    required this.supportsDefaultLanguage,
    required this.supportsPaymentMethodReferences,
    required this.displayName,
  });

  /// The only currency supported by the Web Checkout in this country.
  final WompiCurrency currency;

  /// Host of the Web Checkout page for this country.
  final String checkoutHost;

  /// The identity document types accepted for the payer in this country.
  final List<WompiLegalIdType> legalIdTypes;

  /// Whether `tax-in-cents:consumption` can be reported here.
  ///
  /// Colombia only; Panama reports the ITBMS through `tax-in-cents:vat`.
  final bool supportsConsumptionTax;

  /// Whether `default-language` can be sent here. Panama only.
  final bool supportsDefaultLanguage;

  /// Whether `payment-method:reference-one`, `-two` and `-three` can be
  /// sent here. Colombia only.
  final bool supportsPaymentMethodReferences;

  /// Human readable name of the country, used in error messages.
  final String displayName;
}
