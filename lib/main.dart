import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

// Aliased imports
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:provider/provider.dart' as provider;

import 'package:bogoballers/client/client_app.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/hive/app_box.dart';
import 'package:bogoballers/core/models/access_token.dart';
import 'package:bogoballers/core/models/player_model.dart';
import 'package:bogoballers/core/models/user.dart';
import 'package:bogoballers/core/services/notification_services.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/state/app_state.dart';
import 'package:bogoballers/core/state/entity_state.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  setupLocator();

  try {
    await dotenv.load(fileName: ".env");
    await AppBox.init();

    AccessToken? accessToken = AppBox.accessTokenBox.get('access_token');
    String? user_id;
    AccountTypeEnum? accountType;
    if (accessToken != null) {
      user_id = accessToken.user_id;
      accountType = AccountTypeEnum.fromValue(accessToken.getAccountType);
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService.instance.initialize();

    final List<provider.ChangeNotifierProvider> providers = [
      provider.ChangeNotifierProvider<AppState>.value(value: getIt<AppState>()),
      provider.ChangeNotifierProvider<EntityState<PlayerModel>>.value(
        value: getIt<EntityState<PlayerModel>>(),
      ),
      provider.ChangeNotifierProvider<EntityState<UserModel>>.value(
        value: getIt<EntityState<UserModel>>(),
      ),
    ];

    runApp(
      riverpod.ProviderScope(
        child: provider.MultiProvider(
          providers: providers,
          child: ClientMaterialScreen(
            user_id: user_id,
            accountType: accountType,
          ),
        ),
      ),
    );
  } catch (e) {
    debugPrint("Error: $e");
  } finally {
    FlutterNativeSplash.remove();
  }
}
