import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/models/program.dart';
import 'package:smart_tags/models/program_role.dart';
import 'package:smart_tags/models/role.dart';
import 'package:smart_tags/models/user.dart';

User _buildUser({required int id, List<ProgramRole> programRoles = const []}) {
  return User(
    id: id,
    fullName: 'Test User',
    email: 'test@example.com',
    firstName: 'Test',
    lastName: 'User',
    title: 'Dr',
    orcid: '0000-0000-0000-0000',
    tel: '123',
    tel2: '456',
    address: '1 Test Street',
    hideContactInfoFromPublic: false,
    roles: const ['ROLE_TEST'],
    programRoles: programRoles,
  );
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.executor(conn.inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('AuthDao', () {
    test('saveProfile does not create duplicate rows for repeat logins', () async {
      final user = _buildUser(id: 42);

      await db.authDao.saveProfile(user);
      await db.authDao.saveProfile(user);

      final rows = await (db.select(db.userProfiles)..where((t) => t.ref.equals(42))).get();
      expect(rows, hasLength(1));
    });

    test('clearProfile does not throw when duplicate rows exist and removes them all', () async {
      // Simulate a corrupted local DB from before the fix, with two rows sharing the same ref.
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              ref: 7,
              email: 'a@example.com',
              fullName: 'A',
              firstName: 'A',
              lastName: 'A',
              title: 'Mr',
              orcid: '',
              tel: '',
              tel2: '',
              address: '',
              hideContactInfoFromPublic: false,
            ),
          );
      await db.into(db.userProfiles).insert(
            UserProfilesCompanion.insert(
              ref: 7,
              email: 'b@example.com',
              fullName: 'B',
              firstName: 'B',
              lastName: 'B',
              title: 'Mr',
              orcid: '',
              tel: '',
              tel2: '',
              address: '',
              hideContactInfoFromPublic: false,
            ),
          );

      await db.authDao.clearProfile(7);

      final rows = await (db.select(db.userProfiles)..where((t) => t.ref.equals(7))).get();
      expect(rows, isEmpty);
    });

    test('clearProfile removes program-role links, roles, and orphaned programs', () async {
      final user = _buildUser(
        id: 1,
        programRoles: const [
          ProgramRole(
            program: Program(id: 100, name: 'Program 100', code: 'P100'),
            role: Role(id: 200, name: 'Role 200', code: 'R200'),
          ),
        ],
      );

      await db.authDao.saveProfile(user);
      await db.authDao.clearProfile(1);

      expect(await (db.select(db.userProfiles)..where((t) => t.ref.equals(1))).get(), isEmpty);
      expect(await (db.select(db.userProgramRoles)..where((t) => t.userId.equals(1))).get(), isEmpty);
      expect(await (db.select(db.userRoles)..where((t) => t.userId.equals(1))).get(), isEmpty);
      expect(await (db.select(db.programs)..where((t) => t.id.equals(100))).get(), isEmpty);
    });

    test('saveProfile then loadProfile round-trips the profile by external id', () async {
      final user = _buildUser(
        id: 55,
        programRoles: const [
          ProgramRole(
            program: Program(id: 1, name: 'Prog', code: 'PR'),
            role: Role(id: 2, name: 'Role', code: 'RL'),
          ),
        ],
      );

      await db.authDao.saveProfile(user);
      final loaded = await db.authDao.loadProfile(55);

      expect(loaded, isNotNull);
      expect(loaded!.id, 55);
      expect(loaded.email, user.email);
      expect(loaded.roles, user.roles);
      expect(loaded.programRoles, hasLength(1));
      expect(loaded.programRoles.single.program.id, 1);
      expect(loaded.programRoles.single.role.id, 2);
    });
  });
}
