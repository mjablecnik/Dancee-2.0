import 'package:flutter_test/flutter_test.dart';
import 'package:dancee_app/models/event_info.dart';

void main() {
  group('EventInfo', () {
    test('should create an EventInfo with all required fields', () {
      const eventInfo = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      expect(eventInfo.type, EventInfoType.price);
      expect(eventInfo.key, 'Entry Fee');
      expect(eventInfo.value, '150 Kč');
    });

    test('should create EventInfo with text type', () {
      const eventInfo = EventInfo(
        type: EventInfoType.text,
        key: 'Dress Code',
        value: 'Casual',
      );

      expect(eventInfo.type, EventInfoType.text);
      expect(eventInfo.key, 'Dress Code');
      expect(eventInfo.value, 'Casual');
    });

    test('should create EventInfo with url type', () {
      const eventInfo = EventInfo(
        type: EventInfoType.url,
        key: 'Facebook Event',
        value: 'https://facebook.com/events/123456',
      );

      expect(eventInfo.type, EventInfoType.url);
      expect(eventInfo.key, 'Facebook Event');
      expect(eventInfo.value, 'https://facebook.com/events/123456');
    });

    test('copyWith should create a new instance with updated fields', () {
      const eventInfo = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      final updated = eventInfo.copyWith(
        value: '200 Kč',
      );

      expect(updated.type, EventInfoType.price);
      expect(updated.key, 'Entry Fee');
      expect(updated.value, '200 Kč');
      expect(identical(eventInfo, updated), false);
    });

    test('copyWith should allow changing type', () {
      const eventInfo = EventInfo(
        type: EventInfoType.text,
        key: 'Info',
        value: 'Some text',
      );

      final updated = eventInfo.copyWith(
        type: EventInfoType.url,
        value: 'https://example.com',
      );

      expect(updated.type, EventInfoType.url);
      expect(updated.key, 'Info');
      expect(updated.value, 'https://example.com');
    });

    test('copyWith should return same values when no parameters provided', () {
      const eventInfo = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      final copied = eventInfo.copyWith();

      expect(copied.type, eventInfo.type);
      expect(copied.key, eventInfo.key);
      expect(copied.value, eventInfo.value);
    });

    test('should support value equality', () {
      const eventInfo1 = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      const eventInfo2 = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      expect(eventInfo1, equals(eventInfo2));
      expect(eventInfo1.hashCode, equals(eventInfo2.hashCode));
    });

    test('should not be equal when fields differ', () {
      const eventInfo1 = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '150 Kč',
      );

      const eventInfo2 = EventInfo(
        type: EventInfoType.price,
        key: 'Entry Fee',
        value: '200 Kč',
      );

      expect(eventInfo1, isNot(equals(eventInfo2)));
    });

    test('should not be equal when type differs', () {
      const eventInfo1 = EventInfo(
        type: EventInfoType.text,
        key: 'Info',
        value: 'Some value',
      );

      const eventInfo2 = EventInfo(
        type: EventInfoType.url,
        key: 'Info',
        value: 'Some value',
      );

      expect(eventInfo1, isNot(equals(eventInfo2)));
    });

    test('EventInfoType enum should have all expected values', () {
      expect(EventInfoType.values.length, 3);
      expect(EventInfoType.values, contains(EventInfoType.text));
      expect(EventInfoType.values, contains(EventInfoType.url));
      expect(EventInfoType.values, contains(EventInfoType.price));
    });
  });
}
