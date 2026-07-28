// Test for user model.

import 'package:test/test.dart';

import '../utils/test_user.dart';

void main() {
  test('Test user model instantiation.', () async {
    final userModel = createTestUser(id: 1, fullName: 'Jiminy Cricket', email: 'JiminyCricket@Disney.it');
    expect(userModel.id, 1);
    expect(userModel.fullName, 'Jiminy Cricket');
    expect(userModel.email, 'JiminyCricket@Disney.it');
  });
}
