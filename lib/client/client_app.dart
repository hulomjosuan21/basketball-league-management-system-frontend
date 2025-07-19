import 'package:app_links/app_links.dart';
import 'package:bogoballers/client/player/player_main_screen.dart';
import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/client/team_creator/team_creator_main_screen.dart';
import 'package:bogoballers/core/helpers/fcm_token_handler.dart';
import 'package:bogoballers/core/service_locator.dart';
import 'package:bogoballers/core/socket_controller.dart';
import 'package:bogoballers/core/state/app_state.dart';
import 'package:bogoballers/core/widgets/error.dart';
import 'package:bogoballers/core/enums/user_enum.dart';
import 'package:bogoballers/core/routes.dart';
import 'package:bogoballers/core/services/entity_services.dart';
import 'package:bogoballers/core/theme/theme.dart';
import 'package:bogoballers/core/theme/theme_extensions.dart';
import 'package:bogoballers/core/utils/error_handling.dart';
import 'package:bogoballers/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ClientMaterialScreen extends StatefulWidget {
  const ClientMaterialScreen({
    super.key,
    required this.user_id,
    required this.accountType,
  });

  final String? user_id;
  final AccountTypeEnum? accountType;

  @override
  State<ClientMaterialScreen> createState() => _ClientMaterialScreenState();
}

class _ClientMaterialScreenState extends State<ClientMaterialScreen> {
  late Future<bool> _checkLoginFuture;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _checkLoginFuture = checkIfUserIsLoggedInAsync();
    initDeepLinks();
  }

  Future<bool> checkIfUserIsLoggedInAsync() async {
    if (widget.user_id == null || widget.accountType == null) return false;

    try {
      await FCMTokenHandler.syncToken(widget.user_id!);
      final service = EntityServices();
      await service.fetch(context, widget.user_id!);
      return true;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        throw ValidationException(
          "You are offline. Please check your connection.",
        );
      }
      return false;
    } catch (_) {
      throw ValidationException("Something went wrong!");
    }
  }

  void initDeepLinks() {
    _appLinks.uriLinkStream.first
        .then((uri) {
          if (uri != null) {
            _handleDeepLink(uri);
          }
        })
        .catchError((e) {
          debugPrint("Initial link error: $e");
        });

    _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (e) {
        debugPrint("Stream link error: $e");
      },
    );
  }

  void _handleDeepLink(Uri? uri) {
    if (uri == null) return;
    debugPrint("📱 Received deep link: $uri");

    final path = uri.path;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (path == '/app/payment-success') {
        navigatorKey.currentState?.pushNamed('/payment-success');
      } else if (path == '/app/payment-cancelled') {
        navigatorKey.currentState?.pushNamed('/payment-cancelled');
      } else {
        debugPrint("❓ Unknown deep link path: $path");
      }
    });
  }

  Widget _buildHomeScreen() {
    final userId = widget.user_id;
    final accountType = widget.accountType;

    if (userId != null && accountType != null) {
      try {
        getIt<AppState>().setUserId = userId;
        SocketService().init(userId: userId);
      } catch (e) {
        debugPrint("🧨 Socket init failed: $e");
        return const ClientLoginScreen();
      }

      switch (accountType) {
        case AccountTypeEnum.PLAYER:
          return const PlayerMainScreen();
        case AccountTypeEnum.TEAM_CREATOR:
          return const TeamCreatorMainScreen();
        default:
          return fullScreenRetryError(
            context,
            "Unsupported account type: ${accountType.value}",
            _retry,
          );
      }
    } else {
      return const ClientLoginScreen();
    }
  }

  void _retry() {
    setState(() {
      _checkLoginFuture = checkIfUserIsLoggedInAsync();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("User ID: ${widget.user_id ?? "None"}");
    debugPrint("Account Type: ${widget.accountType?.value ?? "None"}");

    return MaterialApp(
      title: 'BogoBallers',
      navigatorKey: navigatorKey,
      theme: lightTheme(context),
      routes: appRoutes,
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              extendBodyBehindAppBar: true,
              body: Center(
                child: CircularProgressIndicator(
                  color: context.appColors.accent900,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return fullScreenRetryError(context, snapshot.error, _retry);
          } else if (snapshot.data == true) {
            return _buildHomeScreen();
          } else {
            return const ClientLoginScreen();
          }
        },
      ),
    );
  }
}
