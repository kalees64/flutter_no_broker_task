import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late AuthRepository authRepository;

  setUp(() {
    mockApiClient = MockApiClient();
    authRepository = AuthRepository(apiClient: mockApiClient);
  });

  group('AuthRepository Unit Tests', () {
    test('login returns AuthResponseModel on successful API call', () async {
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {
            'success': true,
            'data': {
              'accessToken': 'mock_access_token',
              'refreshToken': 'mock_refresh_token',
              'user': {
                'id': 1,
                'name': 'Rajesh Sharma',
                'email': 'rajesh@nobroker.in',
                'role': 'tenant',
                'is_active': true,
              },
            },
          });

      final result = await authRepository.login(
        identifier: 'rajesh@nobroker.in',
        password: 'Password123!',
      );

      expect(result.accessToken, 'mock_access_token');
      expect(result.refreshToken, 'mock_refresh_token');
      expect(result.user.name, 'Rajesh Sharma');
      expect(result.user.email, 'rajesh@nobroker.in');
    });

    test('register returns created UserModel on success', () async {
      when(() => mockApiClient.post(
            any(),
            data: any(named: 'data'),
          )).thenAnswer((_) async => {
            'success': true,
            'data': {
              'user': {
                'id': 2,
                'name': 'Amit Sharma',
                'email': 'amit.sharma@nobroker.in',
                'role': 'tenant',
                'flat_number': 'Flat 402',
                'society_name': 'Oakwood Residency',
                'kyc_status': 'verified',
              },
            },
          });

      final user = await authRepository.register(
        name: 'Amit Sharma',
        email: 'amit.sharma@nobroker.in',
        password: 'Password123!',
        role: 'tenant',
        flatNumber: 'Flat 402',
        societyName: 'Oakwood Residency',
      );

      expect(user.id, 2);
      expect(user.name, 'Amit Sharma');
      expect(user.flatNumber, 'Flat 402');
      expect(user.kycStatus, 'verified');
    });
  });
}
