## 3.0.0

Adds a way to keep the integrity secret out of the app, which is what
[Wompi recommends](https://docs.wompi.co/docs/colombia/widget-checkout-web/#paso-3-genera-una-firma-de-integridad).

### Breaking changes

- The unnamed `WompiWebCheckout(...)` constructor was removed: a client
  is now built with `WompiWebCheckout.fromServer` or
  `WompiWebCheckout.fromClient`. Replacing
  `WompiWebCheckout(publicKey: ..., integrityKey: ...)` with
  `WompiWebCheckout.fromClient(publicKey: ..., integrityKey: ...)` keeps
  the previous behavior unchanged.

### Added

- `WompiWebCheckout.fromServer`, which takes the `integritySignature`
  computed by the merchant's backend, so the integrity secret never
  reaches the client. The signature is validated as a SHA-256 digest
  (64 hexadecimal characters) and reported through the
  `integritySignature` field of `WompiValidationException`.
- `WompiWebCheckout.fromClient`, the explicit name for the previous
  behavior: the app holds the secret and hashes locally.
- `WompiWebCheckout.signsLocally`, `true` only for clients built with
  `fromClient`.

### Fixed

- Surrounding whitespace is dropped from the public key, the integrity
  key and the integrity signature. A trailing newline — from an `.env`
  file, an HTTP body or a dashboard copy-paste — used to reach the
  checkout URL percent-encoded, and to be hashed into the signature,
  producing a URL Wompi rejects for no visible reason. A value that is
  only whitespace is still reported as empty.

## 2.0.0

Full overhaul: leaner API, richer validation, and Panama support.

### Breaking changes

- Renamed: `WompiWebCheckoutData` → `WompiCheckoutData`,
  `WompiWebCheckoutCustomerInfo` → `WompiCustomerData` (field
  `customerInfo` → `customerData`), `WompiWebCheckoutShippingAddressInfo`
  → `WompiShippingAddress` (field `shippingAddressInfo` →
  `shippingAddress`), `WompiLegalId` → `WompiLegalIdType`.
- Removed `WompiCheckoutData.currency`: it is derived from
  `WompiWebCheckout.country`.
- The three `WompiInvalid*Exception` types were replaced by a single
  `WompiValidationException` that aggregates every error in `errors`.
- `getCheckoutUri` is now synchronous.
- `WompiWebCheckout.integrityKey` is no longer publicly readable.
- `expirationTime` is validated by `getCheckoutUri`, not by the
  constructor.
- Stricter `reference` and phone number validation, per the docs.
- Requires Dart SDK >= 3.0.0; dropped the `email_validator` dependency.

### Added

- **Panama support** through the new `WompiCountry` enum, which selects
  the checkout host, the currency (`WompiCurrency`), the accepted
  `legalIdTypes` and which optional parameters may be sent.
- Parameters missing from 1.x: `WompiTaxes`, `phoneNumberPrefix`,
  `collectShipping`, `collectCustomerLegalId`, `WompiLanguage` /
  `defaultLanguage` and `WompiPaymentMethodReferences`.
- `WompiEnvironment`, derived from the public key prefix, plus key format
  validation and a console warning when production credentials run in a
  debug build.
- Cross-field validation (`phoneNumber`/`phoneNumberPrefix`,
  `legalId`/`legalIdType`).
- `clear` on every model, to remove optional fields that `copyWith`
  cannot.
- Value equality on all models.

### Fixed

- `expirationTime` is normalized to UTC milliseconds, the format Wompi
  documents — `DateTime.now()` would otherwise emit microseconds in both
  the URL and the signature.
- `WompiLegalIdType.fromCode` previously threw for every valid code; a
  nullable `tryFromCode` was added.
- `WompiValidationException` rejects an empty error list with an
  `ArgumentError` instead of an `assert`.
- The production-credentials warning no longer fires in Flutter profile
  builds.

## 1.1.0

- Implemented customer info validation
- Implemented shipping address info validation
- Added validation utilities for email and phone number
- Added tests

## 1.0.0+1

- Fixed pub.dev analysis issues

## 1.0.0

- Initial release
