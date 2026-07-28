import 'package:smart_tags/models/program.dart';
import 'package:smart_tags/models/program_role.dart';
import 'package:smart_tags/models/role.dart';
import 'package:smart_tags/models/user.dart';

User createTestUser({
  String fullName = 'Joe Bloggs',
  int id = 123456,
  String email = 'joe.bloggs@test.com',
  String? email2,
  String firstName = 'Joe',
  String lastName = 'Bloggs',
  String title = 'Prof',
  String orcid = 'abc-123',
  String tel = '123456',
  String tel2 = '789123',
  String address = 'Postal Address, Location',
  bool hideContactInfoFromPublic = false,
  String? country,
  List<String> roles = const ['alert_editor'],
  List<ProgramRole> programRoles = const [
    ProgramRole(
      program: Program(id: 4, name: 'Argo Australia', code: 'argo-australia'),
      role: Role(id: 2, name: 'Program Manager', code: 'program-manager'),
    )
  ],
}) {
  return User(
    fullName: fullName,
    id: id,
    email: email,
    email2: email2,
    firstName: firstName,
    lastName: lastName,
    title: title,
    orcid: orcid,
    tel: tel,
    tel2: tel2,
    address: address,
    hideContactInfoFromPublic: hideContactInfoFromPublic,
    country: country,
    roles: roles,
    programRoles: programRoles,
  );
}
