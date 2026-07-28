import 'package:drift/drift.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/models/program.dart';
import 'package:smart_tags/models/program_role.dart';
import 'package:smart_tags/models/role.dart';
import 'package:smart_tags/models/user.dart';

part 'auth_dao.g.dart';

@DriftAccessor(
  tables: [UserProfiles, Programs, Roles, UserProgramRoles, UserRoles],
)
/// DAO to store user information, for use in AuthService only
class AuthDao extends DatabaseAccessor<AppDatabase> with _$AuthDaoMixin {
  /// Creates an [AuthDao] attached to [attachedDatabase].
  AuthDao(super.attachedDatabase);

  /// Write information about current user to DB
  Future<void> saveProfile(User profile) async {
    await transaction(() async {
      await into(userProfiles).insertOnConflictUpdate(
        UserProfilesCompanion.insert(
          ref: profile.id,
          email: profile.email,
          email2: Value(profile.email2),
          fullName: profile.fullName,
          firstName: profile.firstName,
          lastName: profile.lastName,
          title: profile.title,
          orcid: profile.orcid,
          tel: profile.tel,
          tel2: profile.tel2,
          address: profile.address,
          hideContactInfoFromPublic: profile.hideContactInfoFromPublic,
          country: Value(profile.country),
        ),
      );

      /// Write information about programs and roles included in current user's profile to the DB
      for (final pr in profile.programRoles) {
        await into(programs).insertOnConflictUpdate(
          ProgramsCompanion.insert(
            id: Value(pr.program.id),
            name: pr.program.name,
            code: pr.program.code,
          ),
        );
        await into(roles).insertOnConflictUpdate(
          RolesCompanion.insert(
            id: Value(pr.role.id),
            name: pr.role.name,
            code: pr.role.code,
          ),
        );
      }

      /// Link user's profile with their program roles (delete and replace).
      await (delete(userProgramRoles)
        ..where((t) => t.userId.equals(profile.id)))
        .go();
      if (profile.programRoles.isNotEmpty) {
        await batch((b) {
          b.insertAll(
            userProgramRoles,
            [
              for (final pr in profile.programRoles)
              UserProgramRolesCompanion.insert(
                userId: profile.id,
                programId: pr.program.id,
                roleId: pr.role.id,
              ),
            ],
          );
        });
      }

      /// Link user's roles outside of programs (delete and replace).
      await (delete(userRoles)..where((t) => t.userId.equals(profile.id)))
          .go();
      if (profile.roles.isNotEmpty) {
        await batch((b) {
        b.insertAll(
          userRoles,
          [
            for (final roleCode in profile.roles)
              UserRolesCompanion.insert(
              userId: profile.id,
              roleCode: roleCode,
            ),
          ],
          );
        });
      }
    });
  }

  /// Retrieve current user profile from the DB.
  Future<User?> loadProfile(int userId) async {
    final profileRow = await (select(userProfiles)
      ..where((t) => t.id.equals(userId)))
        .getSingleOrNull();
    if (profileRow == null) return null;

    // Join userProgramRoles -> programs / roles to rebuild ProgramRole objects.
    final query = select(userProgramRoles).join([
      innerJoin(programs, programs.id.equalsExp(userProgramRoles.programId)),
      innerJoin(roles, roles.id.equalsExp(userProgramRoles.roleId)),
    ])
      ..where(userProgramRoles.userId.equals(userId));

    final programRoleRows = await query.get();
    final programRoles = programRoleRows.map((row) {
      final programRow = row.readTable(programs);
      final roleRow = row.readTable(roles);
      return ProgramRole(
        program: Program(
          id: programRow.id,
          name: programRow.name,
          code: programRow.code,
        ),
        role: Role(
          id: roleRow.id,
          name: roleRow.name,
          code: roleRow.code,
        ),
      );
    }).toList();

    final roleRows = await (select(userRoles)
      ..where((t) => t.userId.equals(userId)))
        .get();
    final flatRoles = roleRows.map((r) => r.roleCode).toList();

    return User(
        id: profileRow.ref,
        email: profileRow.email,
        email2: profileRow.email2,
        fullName: profileRow.fullName,
        firstName: profileRow.firstName,
        lastName: profileRow.lastName,
        title: profileRow.title,
        orcid: profileRow.orcid,
        tel: profileRow.tel,
        tel2: profileRow.tel2,
        address: profileRow.address,
        hideContactInfoFromPublic: profileRow.hideContactInfoFromPublic,
        country: profileRow.country,
        roles: flatRoles,
        programRoles: programRoles,
    );
  }

  /// Remove the cached profile for [userRef] and its associated program-role and role rows.
  Future<void> clearProfile(int userRef) async {
    await transaction(() async {
      final userProfile = await (select(userProfiles)
        ..where((t) => t.ref.equals(userRef)))
          .getSingleOrNull();

      if (userProfile == null) {
        // Nothing to clear.
        return;
      }
      final userId = userProfile.id;

      // Capture which programs this user was linked to, before removing
      // the join rows, so we know what to check for orphaning.
      final programIds = await (selectOnly(userProgramRoles)
        ..addColumns([userProgramRoles.programId])
        ..where(userProgramRoles.userId.equals(userRef)))
          .map((row) => row.read(userProgramRoles.programId)!)
          .get();

      await (delete(userProgramRoles)
        ..where((t) => t.userId.equals(userRef)))
          .go();
      await (delete(userRoles)..where((t) => t.userId.equals(userRef))).go();
      await (delete(userProfiles)..where((t) => t.id.equals(userId))).go();
      await (delete(programs)..where((t) => t.id.isIn(programIds))).go();
    });
  }
}
