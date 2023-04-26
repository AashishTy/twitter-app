import 'package:appwrite/models.dart' as model;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter_clone/apis/auth_api.dart';
import 'package:twitter_clone/apis/user_api.dart';
import 'package:twitter_clone/core/utils.dart';
import 'package:twitter_clone/features/auth/view/login_view.dart';
import 'package:twitter_clone/features/home/view/home_view.dart';
import 'package:twitter_clone/models/user_model.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>((ref) {
  
  final authAPI = ref.watch(authAPRProvider);
  final userAPI = ref.watch(userAPIProvider);
  return AuthController(authAPI: authAPI, userApi: userAPI);
});

final currentUserAccountProvider = FutureProvider((ref) {

  final authController = ref.watch(authControllerProvider.notifier);
  return authController.currentUser();
});

final currentUserDetailsProvider = FutureProvider((ref) {

  final currentUserId = ref.watch(currentUserAccountProvider).value!.$id;
  final userDetails = ref.watch(userDetailsProvider(currentUserId));
  return userDetails.value;
});

final userDetailsProvider = FutureProvider.family((ref, String uid) {

  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {

  final AuthAPI _authAPI;
  final UserApi _userApi;

  AuthController({
    required AuthAPI authAPI,
    required UserApi userApi
  }) : _authAPI = authAPI, _userApi = userApi, super(false);

  Future<model.Account?> currentUser() => _authAPI.currentUserAccount();

  void signp({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = true;
    final res = await _authAPI.signUp(
      email: email,
      password: password
    );
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) async {
        // here call create user
        UserModel userModel = UserModel(
          email: email,
          name: getNameFromEmail(email),
          followers: const [],
          following: const [],
          profilePic: '',
          bannerPic: '',
          uid: r.$id,
          bio: '',
          isTwitterBlue: false
        );

        final res2 = await _userApi.saveUserData(userModel);
        res2.fold(
          (l) => showSnackBar(context, l.message),
          (r) {
            showSnackBar(context, "Account Created ! Please login");
            // sign up successful take to login screen
            Navigator.push(context, LoginView.route());
          }
        );
      }
    );
  }

  void login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {

    // isLoading
    state = true;

    // call login api
    final res = await _authAPI.login(email: email, password: password);

    state = false;

    // handle success / failure
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        // user logs in successfully
        showSnackBar(context, "Login Successful");

        // redirect to homescreen
        Navigator.push(context, HomeView.route());
      }
    );
  }

  Future<UserModel> getUserData(String uid) async {
    final document = await _userApi.getUserData(uid);
    final updatedUser = UserModel.fromMap(document.data);
    return updatedUser;
  }
}