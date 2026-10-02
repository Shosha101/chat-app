import 'package:flutter/material.dart';

//Packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/navigation_services.dart';
import '../services/media_services.dart';
import '../services/cloud_storage_services.dart';
import '../services/database_services.dart';
import '../themes/app_theme.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPage({
    required Key key,
    required this.onInitializationComplete,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> {
  // True when the services could not be started; the page then offers a retry
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then(
          (_) {
        _start();
      },
    );
  }

  void _start() {
    _setup().then(
          (_) => widget.onInitializationComplete(),
      onError: (e) {
        debugPrint("Error starting the app: $e");
        if (mounted) {
          setState(() {
            _hasFailed = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatify',
      theme:AppTheme.darkTheme,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.contain,
                    image: AssetImage('assets/images/logo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Fixed height, so the logo stays put when the spinner gives way to the retry
              SizedBox(
                height: 140,
                child: _hasFailed ? _retry() : _loading(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loading() {
    return const Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: 26,
        width: 26,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    );
  }

  Widget _retry() {
    // The translations are only reachable from a context below MaterialApp
    return Builder(
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr('startup_error'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _hasFailed = false;
                    });
                    _start();
                  },
                  child: Text(context.tr('retry')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setup() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await dotenv.load(fileName: ".env"); // هذا هو السطر المهم

    _registerServices();
  }

  void _registerServices() {
    GetIt.instance.registerSingleton<NavigationService>(
      NavigationService(),
    );
    GetIt.instance.registerSingleton<MediaService>(
      MediaService(),
    );
    GetIt.instance.registerSingleton<CloudStorageService>(
      CloudStorageService(),
    );
    GetIt.instance.registerSingleton<DatabaseService>(
      DatabaseService(),
    );
  }
}
