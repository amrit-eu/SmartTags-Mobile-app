import 'package:smart_tags/database/daos/auth_dao.dart';
import 'package:smart_tags/database/db.dart';
import 'package:smart_tags/database/db_connection.dart' as conn;
import 'package:smart_tags/services/auth_service.dart';

/// An [AuthService] whose [getAccessToken] always returns `null`.
///
/// [AuthService] requires an [AuthDao], so this is backed by a throwaway
/// in-memory database; the DAO itself is never queried. Useful for fakes
/// that need *some* [AuthService] to satisfy a constructor but don't
/// exercise auth themselves.
class NoOpAuthService extends AuthService {
  NoOpAuthService() : super(authDao: AppDatabase.executor(conn.inMemoryConnection()).authDao);

  @override
  Future<String?> getAccessToken() async => null;
}
