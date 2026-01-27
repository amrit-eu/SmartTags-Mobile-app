// Test for user model.

import 'package:smart_tags/models/user.dart';
import 'package:test/test.dart';

void main() {
  test('Test user model instantiation.', () async {
    const userModel = UserProfile(id: 1, fullName: 'Jiminy Cricket', email: 'JiminyCricket@Disney.it');
    expect(userModel.id, 1);
    expect(userModel.fullName, 'Jiminy Cricket');
    expect(userModel.email, 'JiminyCricket@Disney.it');
  });
}
