import 'package:flutter/material.dart';
import 'package:jhatfat/Auth/MobileNumber/UI/phone_number.dart';
import 'package:jhatfat/Auth/Registration/UI/register_page.dart';
import 'package:jhatfat/Auth/Verification/UI/verification_page.dart';
import 'package:jhatfat/HomeOrderAccount/home_order_account.dart';
import 'package:jhatfat/Routes/routes.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LoginRoutes {
  static const String loginRoot = 'login/';
  static const String registration = 'login/registration';
  static const String verification = 'login/verification';
  static const String homepage = 'login/home_order_account';
}

class LoginNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var canPop = navigatorKey.currentState!.canPop();
        if (canPop) {
          navigatorKey.currentState!.pop();
        }
        return !canPop;
      },
      child: Navigator(
        key: navigatorKey,
        initialRoute: LoginRoutes.loginRoot,
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case LoginRoutes.loginRoot:
              builder = (BuildContext _) => PhoneNumber_New();
              return MaterialPageRoute(builder: builder, settings: settings);

              break;
            case LoginRoutes.registration:
              builder = (BuildContext _) => RegisterPage();
              return MaterialPageRoute(builder: builder, settings: settings);

              break;
            case LoginRoutes.verification:
              builder = (BuildContext _) => VerificationPage(
                    () {
                  Navigator.popAndPushNamed(
                      context, PageRoutes.homeOrderAccountPage);
                },
              );

              return MaterialPageRoute(builder: builder, settings: settings);

              break;
            case LoginRoutes.homepage:
              builder = (BuildContext _) => HomeOrderAccount(0);
              return MaterialPageRoute(builder: builder, settings: settings);

              break;
          }
        },
        onPopPage: (Route<dynamic> route, dynamic result) {
          return route.didPop(result);
        },
      ),
    );
  }
}