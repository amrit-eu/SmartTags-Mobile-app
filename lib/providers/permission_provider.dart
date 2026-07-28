import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/program_role.dart';
import 'package:smart_tags/providers/auth_provider.dart';

/// Available roles.
 enum Role {
   anonymous,
   loggedIn,
   programMember,
   programManager,
   superUser;

  String? get code => switch (this) {
    Role.programMember => 'program-member',
    Role.programManager => 'program-manager',
    _ => null, // anonymous/loggedIn/superUser aren't program-scoped ranks
  };
}
/// Available resources.
enum Resource { mission, deployment, asset, alert }
/// Available actions.
enum Action { view, viewSensitive, create, edit, delete, ack, unack, archive }

const Map<Resource, Map<Action, Role>> _policy = {
   // TODO(eawetchy): Add all relevant permissions mappings.
  Resource.deployment: {
    Action.view: Role.anonymous,
    Action.viewSensitive: Role.loggedIn,
    Action.create: Role.programMember,
    Action.edit: Role.programMember,
    Action.delete: Role.superUser,
  },
  Resource.asset: {
    Action.view: Role.programMember,
    Action.create: Role.programMember,
    Action.edit: Role.programMember,
    Action.delete: Role.programMember,
  },
  Resource.alert: {
    Action.view: Role.anonymous,
    Action.ack: Role.programMember,
    Action.unack: Role.programMember,
    Action.archive: Role.programMember,
    Action.delete: Role.superUser,
  },
};

// Role hierarchy, low to high.
const _roleRank = {
  'program-member': 1,
  'program-manager': 2,
};

/// Provides a function to check user authorisation for actions on resources in a program
final permissionProvider = Provider<bool Function(Action, Resource, {int? programId})>((ref) {
  final user = ref.watch(authProvider).value;

  return (Action action, Resource resource, {int? programId}) {
    if (user == null) {
      return _policy[resource]?[action] == Role.anonymous;
    }
    // TODO(eawetchy): Confirm actual string used
    // TODO(eawetchy): Are there other global roles that need to be taken into account here?
    if (user.roles.contains('superuser')) return true;

    final requiredRole = _policy[resource]?[action];
    if (requiredRole == null) return false; // permission not defined (log?)
    if (requiredRole == Role.loggedIn || requiredRole == Role.anonymous) return true; // grant anonymous actions to logged in users

    if (programId == null) return false;

    ProgramRole? programRole;
    for (final pr in user.programRoles) {
      if (pr.program.id == programId) {
        programRole = pr;
        break;
      }
    }

    if (programRole == null) return false;

    final userRank = _roleRank[programRole.role.code];
    final requiredRank = _roleRank[requiredRole.code];

    if (userRank == null || requiredRank == null) return false;

    return userRank >= requiredRank;
  };
});

/// Shortcuts to allow omitting the action when calling the provider
extension PermissionShortcuts on bool Function(Action action, Resource resource, {int? programId}) {
  bool canView(Resource resource, {int? programId}) => this(Action.view, resource, programId: programId);
  bool canCreate(Resource resource, {int? programId}) => this(Action.create, resource, programId: programId);
  bool canEdit(Resource resource, {int? programId}) => this(Action.edit, resource, programId: programId);
  bool canDelete(Resource resource, {int? programId}) => this(Action.delete, resource, programId: programId);
  bool canAck({int? programId}) => this(Action.delete, Resource.alert, programId: programId);
  bool canUnack({int? programId}) => this(Action.delete, Resource.alert, programId: programId);
  bool canArchive({int? programId}) => this(Action.delete, Resource.alert, programId: programId);
}
