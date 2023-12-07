import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../language/AppLocalizations.dart';

import '../language/BaseLanguage.dart';
import '../main.dart';
import '../model/LanguageDataModel.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isLoading = false;

  @observable
  int userId = 0;

  @observable
  String uId = '';

  @observable
  String userEmail = '';

  @observable
  String firstName = '';

  @observable
  String userName = '';

  @observable
  String userProfile = '';

  @observable
  bool isDarkMode = false;

  @observable
  String selectedLanguage = "en";

  @observable
  String walletPresetTopUpAmount = PRESENT_TOP_UP_AMOUNT_CONST;

  @observable
  String walletPresetTipAmount = PRESENT_TOP_UP_AMOUNT_CONST;

  @observable
  String currencyCode = 'R\$';

  @observable
  String currencyPosition = "RIGHT";

  @observable
  String currencyName = currencyNameConst;

  @observable
  String? rideMinutes;

  @observable
  int? minAmountToAdd;

  @observable
  int? maxAmountToAdd;

  @observable
  String? isRiderForAnother = "0";

  @action
  Future<void> setIsRiderForAnother(String? val) async {
    isRiderForAnother = val!;
  }

  @action
  Future<void> setFirstName(String? val) async {
    firstName = val!;
  }

  @action
  Future<void> setMaxAmountToAdd(int? val) async {
    maxAmountToAdd = val;
  }

  @action
  Future<void> setMinAmountToAdd(int? val) async {
    minAmountToAdd = val;
  }

  @action
  Future<void> setRiderMinutes(String? val) async {
    rideMinutes = val;
  }

  @action
  Future<void> setCurrencyName(String val) async {
    currencyName = val;
  }

  @action
  Future<void> setCurrencyCode(String val) async {
    currencyCode = val;
  }

  @action
  Future<void> setCurrencyPosition(String val) async {
    currencyPosition = val;
  }

  @action
  Future<void> setWalletTipAmount(String val) async {
    walletPresetTipAmount = val;
  }

  @action
  Future<void> setWalletPresetTopUpAmount(String val) async {
    walletPresetTopUpAmount = val;
  }

  @action
  Future<void> setUserProfile(String val) async {
    userProfile = val;
  }

  @action
  Future<void> setUserName(String val, {bool isInitialization = false}) async {
    userName = val;
    if (!isInitialization) await sharedPref.setString(USER_NAME, val);
  }

  @action
  Future<void> setUId(String val, {bool isInitialization = false}) async {
    uId = val;
    if (!isInitialization) await sharedPref.setString(UID, val);
  }

  @action
  Future<void> setUserEmail(String val, {bool isInitialization = false}) async {
    userEmail = val;
    if (!isInitialization) await sharedPref.setString(USER_EMAIL, val);
  }

  @action
  Future<void> setUserId(int val, {bool isInitializing = false}) async {
    userId = val;
    if (!isInitializing) await sharedPref.setInt(USER_ID, val);
  }

  @action
  Future<void> setLoading(bool val) async {
    isLoading = val;
  }

  @action
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (!isInitializing) await sharedPref.setBool(IS_LOGGED_IN, val);
  }

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = viewLineColor;
      defaultLoaderBgColorGlobal = Colors.black26;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;
      defaultLoaderBgColorGlobal = Colors.white;
    }
  }

  @action
  Future<void> setLanguage(String aCode, {BuildContext? context}) async {
    selectedLanguageDataModel = getSelectedLanguageModel(
        defaultLanguage: defaultValues.defaultLanguage);
    selectedLanguage = "en";

    if (context != null) language = BaseLanguage.of(context)!;
    language = await AppLocalizations().load(Locale(selectedLanguage));
  }
}
