import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:twitter_clone/core/core.dart';
import 'package:twitter_clone/core/providers.dart';

final authAPRProvider = Provider((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthAPI(account: account);
});

abstract class IAuthAPI {

  FutureEither<model.Account> signUp({
    required String email,
    required String password,
  });

  FutureEither<model.Session> login({
    required String email,
    required String password,
  });

  Future<model.Account?> currentUserAccount();
}

class AuthAPI extends IAuthAPI {

  final Account _account;

  AuthAPI({required Account account}) : _account = account;

  @override
  FutureEither<model.Account> signUp({
    required String email,
    required String password
  }) async {
    
    // call the sign up api of appwrite
    try {

      final account = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password
      );

      return right(account);
    }
    on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.message ?? "Unexpected Error", stackTrace));
    }
    catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
  
  @override
  FutureEither<model.Session> login({
    required String email,
    required String password
  }) async {
    
    // make the create email session api call
    try {
      final session = await _account.createEmailSession(
        email: email,
        password: password
      );

      // return the email session
      return right(session);
    }
    on AppwriteException catch (e, stackTrace) {
      // or error
      return left(Failure(e.message ?? "Unexpected Error", stackTrace));
    }
    catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
  
  @override
  Future<model.Account?> currentUserAccount() async {
    
    try {
      return await _account.get();
    }
    on AppwriteException catch(e) {
      return null;
    }
    catch (e) {
      return null;
    }
  }
}