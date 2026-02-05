import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/models/address.dart';

void main() {
  group('Address', () {
    test('should create an Address with all required fields', () {
      const address = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      expect(address.street, 'Vodičkova 36');
      expect(address.city, 'Prague');
      expect(address.postalCode, '110 00');
      expect(address.country, 'Czech Republic');
    });

    test('should return correct fullAddress', () {
      const address = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      expect(
        address.fullAddress,
        'Vodičkova 36, 110 00 Prague, Czech Republic',
      );
    });

    test('copyWith should create a new instance with updated fields', () {
      const address = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      final updated = address.copyWith(
        street: 'Komunardů 30',
        postalCode: '170 00',
      );

      expect(updated.street, 'Komunardů 30');
      expect(updated.city, 'Prague');
      expect(updated.postalCode, '170 00');
      expect(updated.country, 'Czech Republic');
      expect(identical(address, updated), false);
    });

    test('copyWith should return same values when no parameters provided', () {
      const address = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      final copied = address.copyWith();

      expect(copied.street, address.street);
      expect(copied.city, address.city);
      expect(copied.postalCode, address.postalCode);
      expect(copied.country, address.country);
    });

    test('should support value equality', () {
      const address1 = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      const address2 = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      expect(address1, equals(address2));
      expect(address1.hashCode, equals(address2.hashCode));
    });

    test('should not be equal when fields differ', () {
      const address1 = Address(
        street: 'Vodičkova 36',
        city: 'Prague',
        postalCode: '110 00',
        country: 'Czech Republic',
      );

      const address2 = Address(
        street: 'Komunardů 30',
        city: 'Prague',
        postalCode: '170 00',
        country: 'Czech Republic',
      );

      expect(address1, isNot(equals(address2)));
    });
  });
}
