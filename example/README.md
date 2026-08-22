# wompi_web_checkout example

A Flutter app that opens Wompi's Web Checkout inside a `webview_flutter`
webview.

```bash
flutter run
```

## Setup screen

The app opens on a form asking for your **public key**, **integrity
key** and **country**. Get the keys from the Wompi commerce dashboard
(**Developers > Secrets for technical integration**) and use sandbox
ones (`pub_test_` / `test_integrity_`) so no real money moves — then pay
with the
[sandbox test cards](https://docs.wompi.co/docs/colombia/ambientes-y-llaves/).

Nothing is persisted: the keys live only for the session, so no
credential is ever committed here.

The form validates through the package itself: a `WompiValidationException`
from the `WompiWebCheckout` constructor is mapped back onto the field
that caused it, so there is no validation logic duplicated in the app.

The country picks the checkout host (`checkout.wompi.co` /
`checkout.wompi.pa`), the currency (COP / USD) and which optional
parameters are accepted. Go back to change it.

## Payments screen

Each button builds a different `WompiCheckoutData`: minimal, with payer
information, and with every optional field (taxes, shipping address,
expiration time, collection flags). Amounts, phone prefixes, document
types and addresses adapt to the country.

The last button also shows the country-specific parameters — the
consumption tax and the payment method references in Colombia, the
checkout language in Panama — which `getCheckoutUri` rejects when sent
to the wrong country. Any validation error is surfaced in a snackbar.

If the keys are production ones, a banner warns that payments are real.
