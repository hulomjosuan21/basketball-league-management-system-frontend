import 'package:bogoballers/client/player/player_main_screen.dart';
import 'package:bogoballers/client/screens/client_login_screen.dart';
import 'package:bogoballers/client/screens/payment_cancelled_screen.dart';
import 'package:bogoballers/client/screens/payment_success_screen.dart';
import 'package:bogoballers/client/team_creator/team_creator_main_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/client/login/screen': (context) => ClientLoginScreen(),
  '/team-creator/home/screen': (context) => TeamCreatorMainScreen(),
  '/player/home/screen': (context) => PlayerMainScreen(),
  '/payment-success': (context) => const PaymentSuccessScreen(),
  '/payment-cancelled': (context) => const PaymentCancelledScreen()
};
