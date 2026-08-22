# Wompi Web Checkout

[![Pub Version](https://img.shields.io/pub/v/wompi_web_checkout)](https://pub.dev/packages/wompi_web_checkout)
![Pub Publisher](https://img.shields.io/pub/publisher/wompi_web_checkout)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A pure Dart client for [Wompi](https://wompi.co)'s **Web Checkout**. Build integrity-signed checkout URLs and let your customers complete their payments on Wompi's hosted checkout page — from any Dart or Flutter application.

Supports both **Colombia** (`checkout.wompi.co`, COP) and **Panama** (`checkout.wompi.pa`, USD).

- 🔒 **Integrity-signed URLs** — SHA-256 signature generation per the [official spec](https://docs.wompi.co/docs/colombia/widget-checkout-web/#web-checkout)
- 🧩 **Complete parameter coverage** — customer data, shipping address, taxes, expiration time, language, payment method references and collection flags
- ✅ **Fail-fast validation** — every invalid field is reported at once through a single, descriptive exception
- 🔑 **Key & environment checks** — key format validation, plus a console warning when production credentials are used in debug builds
- 🪶 **Lightweight** — pure Dart, no Flutter required

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  wompi_web_checkout: ^2.0.0
```

Then run:

```bash
dart pub get
# or
flutter pub get
```

## Usage

### 1. Create the client

Get your keys from the [Wompi commerce dashboard](https://comercios.wompi.co) (**Developers > Secrets for technical integration**). Sandbox keys are prefixed with `pub_test_`, production keys with `pub_prod_`.

```dart
import 'package:wompi_web_checkout/wompi_web_checkout.dart';

final wompi = WompiWebCheckout(
  publicKey: '<YOUR_PUBLIC_KEY>',
  integrityKey: '<YOUR_INTEGRITY_SECRET>',
);
```

The country owns the currency: `WompiCountry.colombia` always signs and sends `COP`, `WompiCountry.panama` always `USD`. There is no per-payment currency, so the signed value and the value in the URL can never disagree.

For a **Panamanian** merchant account, set the country — the checkout host and currency adjust accordingly:

```dart
final wompi = WompiWebCheckout(
  publicKey: '<YOUR_PUBLIC_KEY>',
  integrityKey: '<YOUR_INTEGRITY_SECRET>',
  country: WompiCountry.panama,
);
```

### 2. Describe the payment

Only `amountInCents` and `reference` are required:

```dart
final data = WompiCheckoutData(
  amountInCents: 4950000, // COP $49.500
  reference: 'order-123', // unique per payment
  redirectUrl: 'https://mystore.com/payments/result',
);
```

Add optional data to pre-fill the checkout and improve the payer experience:

```dart
final data = WompiCheckoutData(
  amountInCents: 11900000,
  reference: 'order-123',
  redirectUrl: 'https://mystore.com/payments/result',
  expirationTime: DateTime.now().add(const Duration(hours: 1)),
  collectShipping: true,
  collectCustomerLegalId: true,
  taxes: WompiTaxes(vat: 1900000),
  customerData: WompiCustomerData(
    email: 'lola@perez.com',
    fullName: 'Lola Perez',
    phoneNumber: '3019777777',
    phoneNumberPrefix: '+57',
    legalId: '123456789',
    legalIdType: WompiLegalIdType.cc,
  ),
  shippingAddress: WompiShippingAddress(
    addressLine1: 'Carrera 123 # 4-5',
    addressLine2: 'Apto 123',
    country: 'CO',
    region: 'Cundinamarca',
    city: 'Bogotá',
    phoneNumber: '3019988888',
    name: 'Pedro Perez',
    postalCode: '110111',
  ),
);
```

### 3. Generate the checkout URL and redirect the payer

```dart
final uri = wompi.getCheckoutUri(data);
```

Open `uri` in a browser or a webview (see the [example app](example) for a complete Flutter integration with `webview_flutter`).

## Parameters

| Parameter | Required | Description |
| --- | --- | --- |
| `amountInCents` | ✅ | Total amount **in cents** (e.g. `4950000` for COP $49.500 or `9500` for USD $95) |
| `reference` | ✅ | Unique payment reference in your system. Alphanumeric, optionally with dashes (`-`) or underscores (`_`) |
| `redirectUrl` | — | Where the payer is sent after paying; Wompi appends the transaction `id`. `http` and `https` are both accepted |
| `expirationTime` | — | Payment expiration; activates a countdown. Normalized to UTC with millisecond precision (`2030-06-09T20:28:50.000Z`) and validated as "in the future" when the URL is generated |
| `customerData` | — | Pre-fills the contact form. `phoneNumber` requires `phoneNumberPrefix`; `legalId` requires `legalIdType` |
| `shippingAddress` | — | Pre-fills the shipping form |
| `taxes` | — | `vat` and/or `consumption` in cents. Informational only: taxes must already be included in `amountInCents`. Panama reports ITBMS through `vat` and rejects `consumption` |
| `paymentMethodReferences` | — | `payment-method:reference-one` (origin IP), `-two` (product opening date, `yyyymmdd`) and `-three` (beneficiary ID). **Colombia only** — rejected on a Panamanian checkout |
| `defaultLanguage` | — | `WompiLanguage.spanish` / `WompiLanguage.english` (`default-language`). **Panama only** — rejected on a Colombian checkout |
| `collectShipping` | — | Shows the shipping information view |
| `collectCustomerLegalId` | — | Activates the identity document field |

The currency is not listed here on purpose: it comes from `WompiWebCheckout.country`.

Every model exposes a strictly typed `copyWith` for assigning values (a `null` argument means "keep the current value") and a `clear` for taking optional fields back out:

```dart
final cheaper = data.copyWith(amountInCents: 2000000);
final withoutExpiration = data.clear(expirationTime: true);
```

`clear` still validates, so it will not let you break a pair Wompi requires together — clearing only `phoneNumber` and leaving `phoneNumberPrefix` throws.

### Country-specific legal ID types

`WompiLegalIdType` is the full catalog of identity document types, but Wompi accepts different types per country. Each country exposes its valid subset: `WompiCountry.colombia.legalIdTypes` (`CC`, `CE`, `NIT`, `PP`, `TI`, `DNI`, `RG`, `OTHER`) and `WompiCountry.panama.legalIdTypes` (`CC`, `CE`, `RUC`, `PP`). The client validates the combination when generating the URL, so a Colombian-only type like `NIT` can't be sent to a Panamanian checkout by mistake.

The same idea applies to the other country-specific parameters, each exposed as a flag on `WompiCountry` and enforced by `getCheckoutUri`:

| Flag | Colombia | Panama | What it gates |
| --- | --- | --- | --- |
| `supportsConsumptionTax` | ✅ | — | `WompiTaxes.consumption` (`tax-in-cents:consumption`); Panama reports the ITBMS through `vat` |
| `supportsDefaultLanguage` | — | ✅ | `defaultLanguage` (`default-language`) |
| `supportsPaymentMethodReferences` | ✅ | — | `paymentMethodReferences` (`payment-method:reference-one` / `-two` / `-three`) |

Those three parameters, plus the currency and the legal ID types, are the **only** differences between the two documented catalogs. Customer data, shipping address, the collection flags, the redirect URL and the expiration time behave identically in both countries, so they are never gated.

For the full parameter reference see the [official Wompi documentation](https://docs.wompi.co/docs/colombia/widget-checkout-web/).

## Error handling

Every field is validated when the models are constructed. Instead of failing on the first problem, a single `WompiValidationException` reports **all** of them:

```dart
try {
  final data = WompiCheckoutData(amountInCents: 0, reference: '');
  final uri = wompi.getCheckoutUri(data);
} on WompiValidationException catch (e) {
  for (final error in e.errors) {
    print('${error.field}: ${error.message}');
  }
  // amountInCents: Amount in cents must be greater than 0.
  // reference: Reference cannot be empty.
}
```

All errors thrown by this package extend `WompiException`, so you can catch everything with a single `on WompiException` clause.

## Good to know

- **Environments.** Keys are validated on creation: sandbox keys start with `pub_test_`/`test_integrity_` and production keys with `pub_prod_`/`prod_integrity_`. The detected environment is available through `wompi.environment`.
- **Two moments of validation.** The models validate their own fields on construction, so a `WompiCheckoutData` never holds a malformed value. Anything that depends on the merchant (legal ID type, consumption tax, checkout language, payment method references) or on the clock (expiration time) is validated by `getCheckoutUri`, which keeps checkout data safe to build, store and reuse. The same `WompiCheckoutData` can therefore be handed to a Colombian and a Panamanian client, and each one tells you what does not apply.
- **Debug safety net.** If you run a debug build with **production** credentials, a warning is logged to the console — it never blocks the integration, it just reminds you that real transactions may be created.
- **Confirm payments with events, not redirections.** The redirect is informative for the user; use the [Wompi events (webhooks)](https://docs.wompi.co/docs/colombia/eventos/) to reliably learn when a transaction reaches a final state, and the `id` query parameter appended to your `redirectUrl` to [look up the transaction](https://docs.wompi.co/docs/colombia/transacciones/).

## Additional information

- See the [example app](example) for a complete Flutter integration.
- Found a bug or have a suggestion? [Open an issue](https://github.com/atleugim/wompi_web_checkout/issues).
- Contributions are welcome — feel free to submit a [pull request](https://github.com/atleugim/wompi_web_checkout/pulls).

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
