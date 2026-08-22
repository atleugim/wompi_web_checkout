// Internal serialization of the checkout models into the query
// parameter keys the Wompi Web Checkout expects. Not exported.
import 'package:wompi_web_checkout/src/models/customer_data.dart';
import 'package:wompi_web_checkout/src/models/payment_method_references.dart';
import 'package:wompi_web_checkout/src/models/shipping_address.dart';
import 'package:wompi_web_checkout/src/models/taxes.dart';

/// Serializes [WompiCustomerData] into its `customer-data:*` query
/// parameters.
extension CustomerDataQueryParams on WompiCustomerData {
  /// The query parameters for this data.
  Map<String, String> toQueryParams() {
    return <String, String>{
      if (email != null) 'customer-data:email': email!,
      if (fullName != null) 'customer-data:full-name': fullName!,
      if (phoneNumber != null) 'customer-data:phone-number': phoneNumber!,
      if (phoneNumberPrefix != null)
        'customer-data:phone-number-prefix': phoneNumberPrefix!,
      if (legalId != null) 'customer-data:legal-id': legalId!,
      if (legalIdType != null) 'customer-data:legal-id-type': legalIdType!.code,
    };
  }
}

/// Serializes [WompiShippingAddress] into its `shipping-address:*`
/// query parameters.
extension ShippingAddressQueryParams on WompiShippingAddress {
  /// The query parameters for this data.
  Map<String, String> toQueryParams() {
    return <String, String>{
      'shipping-address:address-line-1': addressLine1,
      'shipping-address:country': country,
      'shipping-address:region': region,
      'shipping-address:city': city,
      'shipping-address:phone-number': phoneNumber,
      if (addressLine2 != null)
        'shipping-address:address-line-2': addressLine2!,
      if (name != null) 'shipping-address:name': name!,
      if (postalCode != null) 'shipping-address:postal-code': postalCode!,
    };
  }
}

/// Serializes [WompiTaxes] into its `tax-in-cents:*` query parameters.
extension TaxesQueryParams on WompiTaxes {
  /// The query parameters for this data.
  Map<String, String> toQueryParams() {
    return <String, String>{
      if (vat != null) 'tax-in-cents:vat': '$vat',
      if (consumption != null) 'tax-in-cents:consumption': '$consumption',
    };
  }
}

/// Serializes [WompiPaymentMethodReferences] into its
/// `payment-method:*` query parameters.
extension PaymentMethodReferencesQueryParams on WompiPaymentMethodReferences {
  /// The query parameters for this data.
  Map<String, String> toQueryParams() {
    return <String, String>{
      if (referenceOne != null) 'payment-method:reference-one': referenceOne!,
      if (referenceTwo != null) 'payment-method:reference-two': referenceTwo!,
      if (referenceThree != null)
        'payment-method:reference-three': referenceThree!,
    };
  }
}
