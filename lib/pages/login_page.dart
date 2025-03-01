//packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
//widgets
import '../widgets/custom_input_fields.dart';
import '../widgets/rounded_button.dart';

// providers
import '../providers/authentication_provider.dart';
//services
import '../services/navigation_services.dart';
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  late double _deviceHeight;
  late double _deviceWidth;
  final _loginFormKey = GlobalKey<FormState>();
  late AuthenticationProvider _auth;
  late NavigationService _navigation;


  String? _email;
  String? _password;
  @override
  Widget build(BuildContext context) {
    _auth=Provider.of<AuthenticationProvider>(context);
    _navigation=GetIt.instance.get<NavigationService>();
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SingleChildScrollView( // Make the content scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: _deviceHeight * 0.2), // Add top padding for spacing
              _pageTitle(),
              SizedBox(
                height: _deviceHeight * 0.08,
              ),
              _loginForm(),
              SizedBox(
                height: _deviceHeight * 0.04,
              ),
              _loginButton(),
              SizedBox(
                height: _deviceHeight * 0.02,
              ),
              _regiterAccountLink(),
              SizedBox(height: _deviceHeight * 0.1), // Add bottom padding for spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageTitle() {
    return SizedBox(
      height: _deviceWidth * 0.16,
      child: const Text(
        'Chatify',
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _loginButton() {
    return RoundedButton(
        height:50,
        name: 'Login',
        width: _deviceHeight * 0.3,
        onPressed: () {
          if (_loginFormKey.currentState!.validate()) {

            _loginFormKey.currentState!.save();
            _auth.loginUsingEmailAndPassword(_email!, _password!);
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
            hintText: 'Email',
            obscureText: false,
            regEx: r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            onSaved: (String _value) {
              setState(() {
                _email=_value;
              });
            },
          ),
          SizedBox(height: _deviceHeight * 0.04),
          CustomTextFormField(
            hintText: 'Password',
            obscureText: true,
            regEx: r".{8,}",
            onSaved: (String _value) {
              setState(() {
                _password=_value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _regiterAccountLink() {
    // Determine the theme brightness (light or dark mode)
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Set background color based on theme
    final backgroundColor =
        isDarkMode ? Colors.white : const Color.fromRGBO(0, 94, 218, 1.0);
    return GestureDetector(
      onTap: () => _navigation.navigateToRoute('/register'),
      child: Text(
        'Don\'t have an account? Sign up',
        style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600, color: backgroundColor),
      ),
    );
  }
}
