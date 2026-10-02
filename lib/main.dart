import 'package:chatify/themes/app_theme.dart';
import 'package:flutter/material.dart';

//Packages
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

//Services
import './services/navigation_services.dart';

//Widgets
import './widgets/app_widgets.dart';

//Providers
import './providers/authentication_provider.dart';

//Pages
import './pages/splash_page.dart';
import './pages/login_page.dart';
import './pages/register_page.dart';
import './pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  registerTimeAgoLocales();

  runApp(
    _localized(
      SplashPage(
        key: UniqueKey(),
        onInitializationComplete: () {
          runApp(
            _localized(const MainApp()),
          );
        },
      ),
    ),
  );
}

// Arabic first, English as the other language; the choice is remembered
Widget _localized(Widget child) {
  return EasyLocalization(
    supportedLocales: const [Locale('ar'), Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('ar'),
    // Arabic needs its own plural forms (3 to 10, 11 and up)
    ignorePluralRules: false,
    child: child,
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext context) {
            return AuthenticationProvider();
          },
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chatify',
        theme:AppTheme.darkTheme,
        navigatorKey: NavigationService.navigatorKey,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext context) => const LoginPage(),
          '/register': (BuildContext context) => const RegisterPage(),
          '/home': (BuildContext context) => const HomePage(),
        },
      ),
    );
  }
}
