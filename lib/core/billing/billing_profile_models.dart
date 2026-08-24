class BillingProfileRecord {
  const BillingProfileRecord({
    required this.id,
    required this.organizationId,
    required this.label,
    required this.identityType,
    required this.legalName,
    required this.billingEmail,
    required this.addressLineOne,
    required this.city,
    required this.countryCode,
    required this.isDefault,
    required this.status,
    this.organizationName,
    this.taxIdentifier,
    this.billingPhone,
    this.addressLineTwo,
    this.state,
    this.postalCode,
  });
  final int id, organizationId;
  final String label,
      identityType,
      legalName,
      billingEmail,
      addressLineOne,
      city,
      countryCode,
      status;
  final bool isDefault;
  final String? organizationName,
      taxIdentifier,
      billingPhone,
      addressLineTwo,
      state,
      postalCode;
  factory BillingProfileRecord.fromJson(Map<String, dynamic> json) =>
      BillingProfileRecord(
        id: json['id'] as int,
        organizationId: json['organization_id'] as int,
        label: json['label'] as String,
        identityType: json['identity_type'] as String,
        legalName: json['legal_name'] as String,
        billingEmail: json['billing_email'] as String,
        addressLineOne: json['address_line_one'] as String,
        city: json['city'] as String,
        countryCode: json['country_code'] as String,
        isDefault: json['is_default'] as bool,
        status: json['status'] as String,
        organizationName:
            (json['organization'] as Map<String, dynamic>?)?['name'] as String?,
        taxIdentifier: json['tax_identifier'] as String?,
        billingPhone: json['billing_phone'] as String?,
        addressLineTwo: json['address_line_two'] as String?,
        state: json['state'] as String?,
        postalCode: json['postal_code'] as String?,
      );
  String get formattedAddress => [
    addressLineOne,
    addressLineTwo,
    city,
    state,
    postalCode,
    countryCode,
  ].whereType<String>().where((value) => value.isNotEmpty).join(', ');
}

class BillingProfileInput {
  const BillingProfileInput({
    required this.organizationId,
    required this.label,
    required this.identityType,
    required this.legalName,
    required this.billingEmail,
    required this.addressLineOne,
    required this.city,
    required this.countryCode,
    this.taxIdentifier,
    this.billingPhone,
    this.addressLineTwo,
    this.state,
    this.postalCode,
    this.isDefault = false,
  });
  final int organizationId;
  final String label,
      identityType,
      legalName,
      billingEmail,
      addressLineOne,
      city,
      countryCode;
  final String? taxIdentifier, billingPhone, addressLineTwo, state, postalCode;
  final bool isDefault;
  Map<String, dynamic> toJson() => {
    'organization_id': organizationId,
    'label': label,
    'identity_type': identityType,
    'legal_name': legalName,
    'tax_identifier': taxIdentifier,
    'billing_email': billingEmail,
    'billing_phone': billingPhone,
    'address_line_one': addressLineOne,
    'address_line_two': addressLineTwo,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'country_code': countryCode,
    'is_default': isDefault,
  };
}
