import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_tags/models/program_role.dart';
import 'package:smart_tags/providers/auth_provider.dart';

/// Available roles.
enum Role {
  /// Not authenticated.
  anonymous,

  /// Authenticated, but not necessarily a member of any program.
  loggedIn,

  /// A regular member of a program.
  programMember,

  /// A manager of a program.
  programManager,

  /// Has elevated permissions across all programs.
  superUser;

  /// The API code for this role, or `null` if it isn't program-scoped.
  String? get code => switch (this) {
    Role.programMember => 'program-member',
    Role.programManager => 'program-manager',
    _ => null, // anonymous/loggedIn/superUser aren't program-scoped ranks
  };
}

/// Available resources.
enum Resource {
  /// A mission.
  mission,

  /// A deployment.
  deployment,

  /// An asset.
  asset,

  /// An alert.
  alert,
}

/// Available actions.
enum Action {
  /// View a resource.
  view,

  /// View sensitive details of a resource.
  viewSensitive,

  /// Create a resource.
  create,

  /// Edit a resource.
  edit,

  /// Delete a resource.
  delete,

  /// Acknowledge an alert.
  ack,

  /// Unacknowledge an alert.
  unack,

  /// Archive an alert.
  archive,
}

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

    if (user.roles.contains('alert_admin')) return true;

    final requiredRole = _policy[resource]?[action];
    if (requiredRole == null) return false; // permission not defined (log?)
    if (requiredRole == Role.loggedIn || requiredRole == Role.anonymous) {
      return true; // grant anonymous actions to logged in users
    }

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
  /// Whether the current user can view [resource].
  bool canView(Resource resource, {int? programId}) => this(Action.view, resource, programId: programId);

  /// Whether the current user can create [resource].
  bool canCreate(Resource resource, {int? programId}) => this(Action.create, resource, programId: programId);

  /// Whether the current user can edit [resource].
  bool canEdit(Resource resource, {int? programId}) => this(Action.edit, resource, programId: programId);

  /// Whether the current user can delete [resource].
  bool canDelete(Resource resource, {int? programId}) => this(Action.delete, resource, programId: programId);

  /// Whether the current user can acknowledge an alert.
  bool canAck({int? programId}) => this(Action.delete, Resource.alert, programId: programId);

  /// Whether the current user can unacknowledge an alert.
  bool canUnack({int? programId}) => this(Action.delete, Resource.alert, programId: programId);

  /// Whether the current user can archive an alert.
  bool canArchive({int? programId}) => this(Action.delete, Resource.alert, programId: programId);
}
