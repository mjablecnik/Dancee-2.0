import 'package:test/test.dart';
import 'package:dancee_event_service/models/service_result.dart';

void main() {
  group('ServiceResult', () {
    group('success factory', () {
      test('creates successful result with default values', () {
        final result = ServiceResult.success();

        expect(result.success, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.message, equals('Success'));
      });

      test('creates successful result with custom status code', () {
        final result = ServiceResult.success(statusCode: 201);

        expect(result.success, isTrue);
        expect(result.statusCode, equals(201));
        expect(result.message, equals('Success'));
      });

      test('creates successful result with custom message', () {
        final result = ServiceResult.success(message: 'Created successfully');

        expect(result.success, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.message, equals('Created successfully'));
      });

      test('creates successful result with custom status code and message', () {
        final result = ServiceResult.success(
          statusCode: 204,
          message: 'Deleted successfully',
        );

        expect(result.success, isTrue);
        expect(result.statusCode, equals(204));
        expect(result.message, equals('Deleted successfully'));
      });
    });

    group('error factory', () {
      test('creates error result with required parameters', () {
        final result = ServiceResult.error(
          statusCode: 404,
          message: 'Event not found',
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(404));
        expect(result.message, equals('Event not found'));
      });

      test('creates error result with 400 status code', () {
        final result = ServiceResult.error(
          statusCode: 400,
          message: 'Invalid request',
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(400));
        expect(result.message, equals('Invalid request'));
      });

      test('creates error result with 500 status code', () {
        final result = ServiceResult.error(
          statusCode: 500,
          message: 'Internal server error',
        );

        expect(result.success, isFalse);
        expect(result.statusCode, equals(500));
        expect(result.message, equals('Internal server error'));
      });
    });

    group('equality', () {
      test('two successful results with same values are equal', () {
        final result1 = ServiceResult.success(statusCode: 200);
        final result2 = ServiceResult.success(statusCode: 200);

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('two error results with same values are equal', () {
        final result1 = ServiceResult.error(
          statusCode: 404,
          message: 'Not found',
        );
        final result2 = ServiceResult.error(
          statusCode: 404,
          message: 'Not found',
        );

        expect(result1, equals(result2));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('results with different status codes are not equal', () {
        final result1 = ServiceResult.success(statusCode: 200);
        final result2 = ServiceResult.success(statusCode: 201);

        expect(result1, isNot(equals(result2)));
      });

      test('results with different messages are not equal', () {
        final result1 = ServiceResult.success(message: 'Success');
        final result2 = ServiceResult.success(message: 'Created');

        expect(result1, isNot(equals(result2)));
      });

      test('success and error results are not equal', () {
        final result1 = ServiceResult.success(statusCode: 200);
        final result2 = ServiceResult.error(
          statusCode: 200,
          message: 'Success',
        );

        expect(result1, isNot(equals(result2)));
      });
    });

    group('toString', () {
      test('returns formatted string for success result', () {
        final result = ServiceResult.success(statusCode: 201);

        expect(
          result.toString(),
          equals('ServiceResult(success: true, statusCode: 201, message: Success)'),
        );
      });

      test('returns formatted string for error result', () {
        final result = ServiceResult.error(
          statusCode: 404,
          message: 'Event not found',
        );

        expect(
          result.toString(),
          equals('ServiceResult(success: false, statusCode: 404, message: Event not found)'),
        );
      });
    });
  });
}
