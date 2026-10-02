//packages
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
//widgets
import '../widgets/app_widgets.dart';
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

// providers
import '../providers/authentication_provider.dart';
//services
import '../services/navigation_services.dart';
//themes
import '../themes/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  final _loginFormKey = GlobalKey<FormState>();
  late AuthenticationProvider _auth;
  late NavigationService _navigation;


  String? _email;
  String? _password;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    _auth=Provider.of<AuthenticationProvider>(context);
    _navigation=GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Make the content scrollable
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: LanguagePill(),
              ),
              SizedBox(height: _deviceHeight * 0.07),
              _pageTitle(),
              const SizedBox(height: 36),
              _loginForm(),
              const SizedBox(height: 24),
              _loginButton(),
              const SizedBox(height: 12),
              _regiterAccountLink(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return Column(
      children: [
        Image.asset('assets/images/logo.png', height: 88, width: 88),
        const SizedBox(height: 16),
        Text(
          context.tr('app_name'),
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.3),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('login_subtitle'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _loginButton() {
    return RoundedButton(
        height: 54,
        name: context.tr('login'),
        width: double.infinity,
        isLoading: _isLoading,
        onPressed: () async {
          if (_loginFormKey.currentState!.validate()) {

            _loginFormKey.currentState!.save();
            FocusScope.of(context).unfocus();
            setState(() {
              _isLoading = true;
            });
            await _auth.loginUsingEmailAndPassword(_email!, _password!);
            // A successful login replaces this page with the home page
            if (!mounted) {
              return;
            }
            setState(() {
              _isLoading = false;
            });
            if (_auth.errorKey != null) {
              showAppMessage(context, context.tr(_auth.errorKey!));
            }
          }
        });
  }

  Widget _loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTextFormField(
            hintText: context.tr('email'),
            errorText: context.tr('error_email'),
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            obscureText: false,
            regEx: emailRegEx,
            onSaved: (String value) {
              setState(() {
                _email=value;
              });
            },
          ),
          const SizedBox(height: 14),
          CustomTextFormField(
            hintText: context.tr('password'),
            errorText: context.tr('error_password'),
            icon: Icons.lock_outline,
            obscureText: true,
            regEx: r".{8,}",
            onSaved: (String value) {
              setState(() {
                _password=value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _regiterAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            context.tr('no_account'),
            style: const TextStyle(fontSize: 14.5, color: AppColors.muted),
          ),
        ),
        TextButton(
          onPressed: () => _navigation.navigateToRoute('/register'),
          child: Text(context.tr('sign_up')),
        ),
      ],
    );
  }
}
