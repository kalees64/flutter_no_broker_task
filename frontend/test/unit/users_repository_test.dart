import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/users/data/repositories/users_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late UsersRepository usersRepository;

  setUp(() {
    mockApiClient = MockApiClient();
    usersRepository = UsersRepository(apiClient: mockApiClient);
  });

  group('UsersRepository Unit Tests', () {
    test('fetchUsers returns parsed UserListResponse on successful API call', () async {
      when(() => mockApiClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => {
            'success': true,
            'data': {
              'items': [
                {
                  'id': 101,
                  'name': 'Amit Sharma',
                  'email': 'amit.sharma@nobroker.in',
                  'phone': '+91 9876543210',
                  'role': 'tenant',
                  'flat_number': 'Flat 402',
                  'society_name': 'Oakwood Residency',
                  'kyc_status': 'verified',
                  'is_active': true,
                }
              ],
              'page': 1,
              'totalPages': 3,
              'totalItems': 25,
            },
          });

      final result = await usersRepository.fetchUsers(page: 1, limit: 10);

      expect(result.items.length, 1);
      expect(result.items.first.name, 'Amit Sharma');
      expect(result.items.first.flatNumber, 'Flat 402');
      expect(result.totalItems, 25);
      expect(result.totalPages, 3);
    });

    test('createUser calls API and returns created UserModel', () async {
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {
            'success': true,
            'data': {
              'id': 102,
              'name': 'Priya Patel',
              'email': 'priya@nobroker.in',
              'role': 'owner',
              'kyc_status': 'verified',
              'is_active': true,
            },
          });

      final user = await usersRepository.createUser({
        'name': 'Priya Patel',
        'email': 'priya@nobroker.in',
        'password': 'Password123!',
      });

      expect(user.id, 102);
      expect(user.name, 'Priya Patel');
      expect(user.role, 'owner');
    });

    test('deleteUser calls API delete endpoint', () async {
      when(() => mockApiClient.delete(any())).thenAnswer((_) async => {
            'success': true,
            'message': 'User deleted successfully',
          });

      await expectLater(usersRepository.deleteUser(101), completes);
    });
  });
}
