import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/RestApis.dart';
import '../screens/ChatScreen.dart';
import '../screens/RideDetailScreen.dart';
import '../utils/Extensions/StringExtensions.dart';
import '/model/FileModel.dart';
import '/model/LanguageDataModel.dart';
import 'AppTheme.dart';
import 'language/AppLocalizations.dart';
import 'language/BaseLanguage.dart';
import 'model/LoginResponse.dart';
import 'screens/NoInternetScreen.dart';
import 'screens/SplashScreen.dart';
import 'service/ChatMessagesService.dart';
import 'service/NotificationService.dart';
import 'service/UserServices.dart';
import 'store/AppStore.dart';
import 'utils/Colors.dart';
import 'utils/Common.dart';
import 'utils/Constants.dart';
import 'utils/DataProvider.dart';
import 'utils/Extensions/app_common.dart';

AppStore appStore = AppStore();
late SharedPreferences sharedPref;
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
Color defaultLoaderBgColorGlobal = Colors.white;
LatLng polylineSource = LatLng(0.00, 0.00);
LatLng polylineDestination = LatLng(0.00, 0.00);
late BaseLanguage language;
List<LanguageDataModel> localeLanguageList = [];
LanguageDataModel? selectedLanguageDataModel;

late List<FileModel> fileList = [];
bool mIsEnterKey = false;
bool isCurrentlyOnNoInternet = false;

ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();
UserService userService = UserService();
late Position currentPosition;

final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;

Future<void> initialize({
  double? defaultDialogBorderRadius,
  List<LanguageDataModel>? aLocaleLanguageList,
  String? defaultLanguage,
}) async {
  localeLanguageList = aLocaleLanguageList ?? [];
  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: default_Language);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  await initialize(aLocaleLanguageList: languageList());
  appStore.setLanguage(default_Language);

  await appStore.setLoggedIn(sharedPref.getBool(IS_LOGGED_IN) ?? false,
      isInitializing: true);
  await appStore.setUserEmail(sharedPref.getString(USER_EMAIL) ?? '',
      isInitialization: true);
  await appStore.setUserProfile(sharedPref.getString(USER_PROFILE_PHOTO) ?? '');

  await OneSignal.shared.setAppId(mOneSignalAppIdRider);
  OneSignal.shared.consentGranted(true);
  OneSignal.shared.promptUserForPushNotificationPermission();
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) {
    event.complete(event.notification);
  });
  saveOneSignalPlayerId();

  if (appStore.isLoggedIn) {
    updatePlayerId();
  }

  OneSignal.shared.setNotificationOpenedHandler(
      (OSNotificationOpenedResult notification) async {
    var notId = notification.notification.additionalData!["id"];
    var notType = notification.notification.additionalData!["type"];
    if (notId != null) {
      if (notId.toString().contains('CHAT')) {
        LoginResponse user = await getUserDetail(
            userId: int.parse(notId.toString().replaceAll("CHAT_", "")));
        launchScreen(getContext, ChatScreen(userData: user.data));
      } else if (notType == 'payment_status_message') {
        launchScreen(getContext, RideDetailScreen(orderId: notId));
      }
    }
  });
  runApp(MyApp());
}

Future<void> updatePlayerId() async {
  Map req = {
    "player_id": sharedPref.getString(PLAYER_ID),
  };
  updateStatus(req).then((value) {
    //
  }).catchError((error) {
    //
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
    connectivitySubscription.cancel();
  }

  void init() async {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      if (e == ConnectivityResult.none) {
        log('not connected');
        isCurrentlyOnNoInternet = true;
        launchScreen(
            navigatorKey.currentState!.overlay!.context, NoInternetScreen());
      } else {
        if (isCurrentlyOnNoInternet) {
          Navigator.pop(navigatorKey.currentState!.overlay!.context);
          isCurrentlyOnNoInternet = false;
          toast('Internet is connected.');
        }
        log('connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: mAppName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child!);
        },
        home: SplashScreen(),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations(),
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale:
            Locale(appStore.selectedLanguage.validate(value: default_Language)),
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
