import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_tags/models/program.dart';
import 'package:smart_tags/models/program_role.dart';
import 'package:smart_tags/models/role.dart' as model show Role;
import 'package:smart_tags/models/user.dart';
import 'package:smart_tags/providers/auth_provider.dart';
import 'package:smart_tags/providers/permission_provider.dart';

import '../utils/FakeAuthNotifiers.dart';
import '../utils/test_user.dart';

void main() {
  late ProviderContainer container;

  ProviderContainer buildContainer(User? user) {
    return ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuthNotifier(user)),
      ],
    );
  }

  tearDown(() {
    container.dispose();
  });

  group('anonymous user', () {
    setUp(() {
      container = buildContainer(null);
    });

    test('is granted actions whose policy role is Role.anonymous', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.view, Resource.deployment), isTrue);
      expect(can(Action.view, Resource.alert), isTrue);
    });

    test('is denied actions whose policy role is not Role.anonymous', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.viewSensitive, Resource.deployment), isFalse);
      expect(can(Action.create, Resource.deployment), isFalse);
      expect(can(Action.view, Resource.asset), isFalse);
      expect(can(Action.delete, Resource.deployment), isFalse);
    });

    test('is denied actions for undefined resource/action combos', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      // Resource.mission has no policy entries defined at all.
      expect(can(Action.view, Resource.mission), isFalse);
    });
  });

  group('logged-in user with no special roles', () {
    setUp(() {
      final user = createTestUser(roles: const [], programRoles: const []);
      container = buildContainer(user);
    });

    test('is granted actions requiring Role.loggedIn', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.viewSensitive, Resource.deployment), isTrue);
    });

    test('is granted actions requiring Role.anonymous', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.view, Resource.deployment), isTrue);
    });

    test('is denied program-scoped actions when programId is not supplied', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.create, Resource.deployment, programId: null), isFalse);
    });

    test('is denied program-scoped actions when they have no program role', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.create, Resource.deployment, programId: 1), isFalse);
    });

    test('is denied superuser-only actions', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.delete, Resource.deployment), isFalse);
    });
  });

  group('superuser', () {
    setUp(() {
      final user = createTestUser(roles: const ['superuser'], programRoles: const []);
      container = buildContainer(user);
    });

    test('is granted every action regardless of policy', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.delete, Resource.deployment), isTrue);
      expect(can(Action.delete, Resource.asset), isTrue);
      expect(can(Action.create, Resource.asset, programId: 999), isTrue);
      // Even resource/action combos with no policy defined at all.
      expect(can(Action.archive, Resource.mission), isTrue);
    });
  });

  group('program-member user', () {
    setUp(() {
      final user = createTestUser(
      roles: const [],
      programRoles: const [
        ProgramRole(
          program: Program(id: 42, name: 'Test Program', code: 'test-program'),
          role: model.Role(id: 1, name: 'Program Member', code: 'program-member'),
        ),
      ],
      );

      container = buildContainer(user);
    });

    test('is granted program-member-level actions for their program', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.create, Resource.deployment, programId: 42), isTrue);
      expect(can(Action.edit, Resource.deployment, programId: 42), isTrue);
      expect(can(Action.view, Resource.asset, programId: 42), isTrue);
      expect(can(Action.ack, Resource.alert, programId: 42), isTrue);
    });

    test('is denied actions for a different program', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.create, Resource.deployment, programId: 7), isFalse);
    });

    test('is denied actions requiring a higher rank (superuser)', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.delete, Resource.deployment, programId: 42), isFalse);
    });
  });

  group('program-manager user', () {
    setUp(() {
      // Uses createTestUser's default of program-manager on program 4.
      container = buildContainer(createTestUser());

    });

    test('is granted actions requiring program-member', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.create, Resource.deployment, programId: 4), isTrue);
      expect(can(Action.edit, Resource.asset, programId: 4), isTrue);
    });
  });

  group('unknown role code', () {
    setUp(() {
      final user = createTestUser(
        roles: const [],
        programRoles: const [
          ProgramRole(
            program: Program(id: 42, name: 'Test Program', code: 'test-program'),
            role: model.Role(id: 99, name: 'Some Unmapped Role', code: 'some-unmapped-role'),
          ),
        ],
      );

      container = buildContainer(user);
    });

    test('is denied since rank cannot be resolved', () async {
      await container.read(authProvider.future);
      final can = container.read(permissionProvider);

      expect(can(Action.create, Resource.deployment, programId: 42), isFalse);
    });
  });


}
