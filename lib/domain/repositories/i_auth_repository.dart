abstract class IAuthRepository {
  Future<bool> signUp(String name, String email, String password);
  Future<bool> signIn(String email, String password);
  Future<String?> getCurrentUser();
  Future<String?> getCurrentEmail();
  Future<void> logOut();
}
