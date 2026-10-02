  //Packages
  import 'dart:io';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
  import 'package:file_picker/file_picker.dart';
  import 'package:get_it/get_it.dart';
  import 'package:provider/provider.dart';

  //Services

  //Widgets
  import '../services/cloud_storage_services.dart';
  import '../services/database_services.dart';
  import '../services/media_services.dart';
  import '../services/navigation_services.dart';
  import '../widgets/app_widgets.dart';
  import '../widgets/custom_input_fields.dart';
  import '../widgets/rounded_button.dart';
  import '../widgets/rounded_image.dart';

  //Providers
  import '../providers/authentication_provider.dart';

  //Themes
  import '../themes/app_theme.dart';

  class RegisterPage extends StatefulWidget {
    const RegisterPage({super.key});

    @override
    State<StatefulWidget> createState() {
      return _RegisterPageState();
    }
  }

  class _RegisterPageState extends State<RegisterPage> {
    late AuthenticationProvider _auth;
    late DatabaseService _db;
    late CloudStorageService _cloudStorage;
    late NavigationService _navigation;

    String? _email;
    String? _password;
    String? _name;
    PlatformFile? _profileImage;
    bool _isLoading = false;
    // Set when Register is pressed before a profile image was picked
    bool _isImageMissing = false;

    final _registerFormKey = GlobalKey<FormState>();

    @override
    Widget build(BuildContext context) {
      _auth = Provider.of<AuthenticationProvider>(context);
      _db = GetIt.instance.get<DatabaseService>();
      _cloudStorage = GetIt.instance.get<CloudStorageService>();
      _navigation = GetIt.instance.get<NavigationService>();
      return _buildUI();
    }

    Widget _buildUI() {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 4),
                _topRow(),
                const SizedBox(height: 16),
                _pageTitle(),
                const SizedBox(height: 28),
                _profileImageField(),
                const SizedBox(height: 28),
                _registerForm(),
                const SizedBox(height: 24),
                _registerButton(),
                const SizedBox(height: 12),
                _loginLink(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }

    Widget _topRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pulled towards the edge so the arrow lines up with the page content
          Transform.translate(
            offset: Offset(
                Directionality.of(context) == TextDirection.rtl ? 12 : -12, 0),
            child: IconButton(
              tooltip: context.tr('back'),
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _navigation.goBack(),
            ),
          ),
          const LanguagePill(),
        ],
      );
    }

    Widget _pageTitle() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('register_title'),
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('register_subtitle'),
            style: const TextStyle(fontSize: 15, color: AppColors.muted),
          ),
        ],
      );
    }

    Widget _profileImageField() {
      const double size = 112;
      return Column(
        children: [
          GestureDetector(
            onTap: () {
              GetIt.instance.get<MediaService>().pickImageFromLibrary().then(
                    (file) {
                  // Closing the picker without a choice keeps the current image
                  if (file == null || !mounted) {
                    return;
                  }
                  setState(
                        () {
                      _profileImage = file;
                      _isImageMissing = false;
                    },
                  );
                },
              ).catchError((e) {
                debugPrint("Error picking the profile image: $e");
              });
            },
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                () {
                  if (_profileImage != null) {
                    return RoundedImageFile(
                      image: _profileImage!,
                      size: size,
                    );
                  } else {
                    return const RoundedImageNetwork(
                      imagePath: "",
                      size: size,
                    );
                  }
                }(),
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 3),
                  ),
                  child: const Icon(Icons.photo_camera,
                      size: 17, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.tr(_isImageMissing
                ? 'profile_photo_required'
                : _profileImage == null
                    ? 'profile_photo_hint'
                    : 'profile_photo_change'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: _isImageMissing ? AppColors.danger : AppColors.muted,
            ),
          ),
        ],
      );
    }

    Widget _registerForm() {
      return Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                // Any name with at least one visible character
                regEx: r'\S',
                hintText: context.tr('name'),
                errorText: context.tr('error_name'),
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                obscureText: false),
            const SizedBox(height: 14),
            CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                regEx: emailRegEx,
                hintText: context.tr('email'),
                errorText: context.tr('error_email'),
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                obscureText: false),
            const SizedBox(height: 14),
            CustomTextFormField(
                onSaved: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                regEx: r".{8,}",
                hintText: context.tr('password'),
                errorText: context.tr('error_password'),
                icon: Icons.lock_outline,
                obscureText: true),
          ],
        ),
      );
    }

    Widget _registerButton() {
      return RoundedButton(
        name: context.tr('register'),
        height: 54,
        width: double.infinity,
        isLoading: _isLoading,
          onPressed: () async {
            bool isFormValid = _registerFormKey.currentState!.validate();
            if (_profileImage == null) {
              setState(() {
                _isImageMissing = true;
              });
            }
            if (isFormValid && _profileImage != null) {
              _registerFormKey.currentState!.save();
              FocusScope.of(context).unfocus();
              setState(() {
                _isLoading = true;
              });

              String? errorKey = await _register();

              // A successful registration replaces this page with the home page
              if (!mounted) {
                return;
              }
              setState(() {
                _isLoading = false;
              });
              if (errorKey != null) {
                showAppMessage(context, context.tr(errorKey));
              }
            }
          }
      );
    }

    // Creates the account, uploads the image and saves the profile. Returns
    // the translation key of what went wrong, or null when it all worked.
    Future<String?> _register() async {
      String? uid = await _auth.registerUserUsingEmailAndPassword(_email!, _password!);
      if (uid == null) {
        return _auth.errorKey ?? 'auth_error_generic';
      }

      try {
        // ✅ Convert `PlatformFile` to `File`
        File imageFile = File(_profileImage!.path!);

        String? imageURL = await _cloudStorage.saveUserImageToStorage(imageFile, uid);
        if (imageURL == null) {
          // Without this the email would stay taken by an account with no profile
          await _auth.deleteCurrentUser();
          return 'upload_failed';
        }

        await _db.createUser(uid, _email!, _name!, imageURL);
      } catch (e) {
        debugPrint("Error completing registration: $e");
        await _auth.deleteCurrentUser();
        return 'register_failed';
      }

      await _auth.logout();
      await _auth.loginUsingEmailAndPassword(_email!, _password!);
      return _auth.errorKey;
    }

    Widget _loginLink() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              context.tr('have_account'),
              style: const TextStyle(fontSize: 14.5, color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => _navigation.goBack(),
            child: Text(context.tr('sign_in')),
          ),
        ],
      );
    }
  }
