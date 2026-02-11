import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/models/venue.dart';
import 'package:dancee_app/models/address.dart';

void main() {
  group('Venue', () {
    const testAddress = Address(
      street: 'Vodičkova 36',
      city: 'Prague',
      postalCode: '110 00',
      country: 'Czech Republic',
    );

    test('should create a Venue with all required fields', () {
      const venue = Venue(
        name: 'Lucerna Music Bar',
        address: testAddress,
        description: 'Historic music venue in the heart of Prague',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      expect(venue.name, 'Lucerna Music Bar');
      expect(venue.address, testAddress);
      expect(venue.description, 'Historic music venue in the heart of Prague');
      expect(venue.latitude, 50.0813);
      expect(venue.longitude, 14.4253);
    });

    test('copyWith should create a new instance with updated fields', () {
      const venue = Venue(
        name: 'Lucerna Music Bar',
        address: testAddress,
        description: 'Historic music venue in the heart of Prague',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      const newAddress = Address(
        street: 'Komunardů 30',
        city: 'Prague',
        postalCode: '170 00',
        country: 'Czech Republic',
      );

      final updated = venue.copyWith(
        name: 'Dance Arena Prague',
        address: newAddress,
        latitude: 50.1025,
      );

      expect(updated.name, 'Dance Arena Prague');
      expect(updated.address, newAddress);
      expect(updated.description, 'Historic music venue in the heart of Prague');
      expect(updated.latitude, 50.1025);
      expect(updated.longitude, 14.4253);
      expect(identical(venue, updated), false);
    });

    test('copyWith should return same values when no parameters provided', () {
      const venue = Venue(
        name: 'Lucerna Music Bar',
        address: testAddress,
        description: 'Historic music venue in the heart of Prague',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      final copied = venue.copyWith();

      expect(copied.name, venue.name);
      expect(copied.address, venue.address);
      expect(copied.description, venue.description);
      expect(copied.latitude, venue.latitude);
      expect(copied.longitude, venue.longitude);
    });

    test('should support value equality', () {
      const venue1 = Venue(
        name: 'Lucerna Music Bar',
        address: testAddress,
        description: 'Historic music venue in the heart of Prague',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      const venue2 = Venue(
        name: 'Lucerna Music Bar',
        address: testAddress,
        description: 'Historic music venue in the heart of Prague',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      expect(venue1, equals(venue2));
      expect(venue1.hashCode, equals(venue2.hashCode));
    });

    test('should not be equal when fields differ', () {
      const venue1 = Venue(
        name: 'Lucerna Music Bar',
        address: testAddress,
        description: 'Historic music venue in the heart of Prague',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      const venue2 = Venue(
        name: 'Dance Arena Prague',
        address: testAddress,
        description: 'Modern dance studio with professional floor',
        latitude: 50.1025,
        longitude: 14.4378,
      );

      expect(venue1, isNot(equals(venue2)));
    });

    test('should not be equal when address differs', () {
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

      const venue1 = Venue(
        name: 'Lucerna Music Bar',
        address: address1,
        description: 'Historic music venue',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      const venue2 = Venue(
        name: 'Lucerna Music Bar',
        address: address2,
        description: 'Historic music venue',
        latitude: 50.0813,
        longitude: 14.4253,
      );

      expect(venue1, isNot(equals(venue2)));
    });
  });
}
