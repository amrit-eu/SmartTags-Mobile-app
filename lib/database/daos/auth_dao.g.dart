// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dao.dart';

// ignore_for_file: type=lint
mixin _$AuthDaoMixin on DatabaseAccessor<AppDatabase> {
  $UserProfilesTable get userProfiles => attachedDatabase.userProfiles;
  $ProgramsTable get programs => attachedDatabase.programs;
  $RolesTable get roles => attachedDatabase.roles;
  $UserProgramRolesTable get userProgramRoles =>
      attachedDatabase.userProgramRoles;
  $UserRolesTable get userRoles => attachedDatabase.userRoles;
  AuthDaoManager get managers => AuthDaoManager(this);
}

class AuthDaoManager {
  final _$AuthDaoMixin _db;
  AuthDaoManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db.attachedDatabase, _db.userProfiles);
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db.attachedDatabase, _db.programs);
  $$RolesTableTableManager get roles =>
      $$RolesTableTableManager(_db.attachedDatabase, _db.roles);
  $$UserProgramRolesTableTableManager get userProgramRoles =>
      $$UserProgramRolesTableTableManager(
        _db.attachedDatabase,
        _db.userProgramRoles,
      );
  $$UserRolesTableTableManager get userRoles =>
      $$UserRolesTableTableManager(_db.attachedDatabase, _db.userRoles);
}
