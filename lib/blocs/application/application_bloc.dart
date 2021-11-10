import 'dart:async';
import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:question_answer_app/constants/strings.dart';
import 'package:question_answer_app/data/repo/repository.dart';
import 'package:question_answer_app/data/repo/user_management_repository.dart';
import 'package:question_answer_app/di/components/service_locator.dart';
import 'application_events.dart';
import 'application_state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  // Indicates if the application is initialized or not.
  var _isInitialized = false;

  // Supported languages.
  final _supportedLanguages = [Strings.LANG_AR, Strings.LANG_EN];

  ApplicationBloc() : super(ApplicationState.initialState);

  // Supported locales
  Iterable<Locale> get supportedLocales => _supportedLanguages.map(
        (language) => Locale(language, ''),
  );

  @override
  ApplicationState get initialState => ApplicationState.initialState;

  @override
  Stream<ApplicationState> mapEventToState(ApplicationEvent event) async* {
    if (event is SetApplicationLanguageEvent) {
      yield await _handleSetApplicationLanguageEvent(event);
    }
    // if (event is SetUserInfoEvent) {
    //   yield await _handleSetUserInfoEventEvent();
    // }

    if (event is UserLogoutEvent) {
      yield await _handleUserLogoutEvent();
    }
  }


  Future<ApplicationState> _handleSetApplicationLanguageEvent(
      SetApplicationLanguageEvent event,
      ) async {
    switch (event.language) {
      case Strings.LANG_AR:
      // If the language is already arabic -> don't change anything.
        if (this.state.language == Strings.LANG_AR) return this.state;

        final setLanguageResult = await _setLanguage(Strings.LANG_AR);
        if (setLanguageResult) {
          return this.state.copyWith(language: Strings.LANG_AR);
        }

        return this.state;
      case Strings.LANG_EN:
      // If the language is already english -> don't change anything.
        if (this.state.language == Strings.LANG_EN) return this.state;

        final setLanguageResult = await _setLanguage(Strings.LANG_EN);
        if (setLanguageResult) {
          return this.state.copyWith(language: Strings.LANG_EN);
        }

        return this.state;
    }
    return this.state;
  }

  Future<ApplicationState> _handleUserLogoutEvent() async {
    // await GetIt.I<UserRepository>().logout();
    return this.state.clearProfile();
  }

  // Future<ApplicationState> _handleSetUserInfoEventEvent() async {
  //  // final profile = await UserRepository.cachedLoginProfile;
  //   final _userInfo =await getIt<UserManagementRepository>().getUserCachedInfo();
  //   print("user info for SetUserInfoEvent is ${_userInfo?.email??""}");
  //   return this.state.copyWith(user: _userInfo);
  // }

  Future<String> _getCurrentLanguage() async {
    final repo = getIt<Repository>();
    var lang = repo.currentLanguage;
    if (lang == null || lang.isEmpty) {
      await repo.changeLanguage(Strings.LANG_EN);
      lang = Strings.LANG_EN;
    }
    return lang;
  }

  Future<bool> _setLanguage(String language) async {
    final repo = getIt<Repository>();

    await repo.changeLanguage(language);
    return true;
  }

  bool get isInitialized => _isInitialized;
}
