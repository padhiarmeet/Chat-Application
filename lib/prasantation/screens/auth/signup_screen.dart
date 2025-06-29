import 'package:chat_application/core/common/custom_button.dart';
import 'package:chat_application/core/common/custom_textfield.dart';
import 'package:chat_application/core/utils/ui_utils.dart';
import 'package:chat_application/data/repositries/auth_repository.dart';
import 'package:chat_application/data/services/service_locator.dart';
import 'package:chat_application/logic/cubits/auth/auth_cubit.dart';
import 'package:chat_application/logic/cubits/auth/auth_state.dart';
import 'package:chat_application/prasantation/screens/auth/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../router/app_router.dart';
import '../../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    _nameFocus.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }
  //validate name
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Full Name';
    }
    return null;
  }

  //validate ussername
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Full Name';
    }
    return null;
  }

  //validate phone number
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your Full Name';
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  //validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address (e.g., example@email.com)';
    }
    return null;
  }

  Future<void> handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signUp(
          username: usernameController.text,
          fullName: nameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      print("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<AuthCubit, AuthState>(
        bloc: getIt<AuthCubit>(),
        listener: (context, state) {
          if (state.status == AuthStatus.authanticate) {
            getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
          } else if (state.status == AuthStatus.error && state.error != null) {
            Ui_utils.showSnakeBar(context, message: state.error!, isError: true);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please fill the details to continue',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    CustomTextfield(
                      controller: nameController,
                      focusNode: _nameFocus,
                      validator: _validateName,
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline_sharp),
                    ),
                    const SizedBox(height: 16),

                    CustomTextfield(
                      controller: usernameController,
                      focusNode: _usernameFocus,
                      validator: _validateUsername,
                      hintText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline_sharp),
                    ),
                    const SizedBox(height: 16),

                    CustomTextfield(
                      controller: emailController,
                      focusNode: _emailFocus,
                      validator: _validateEmail,
                      keybordType: TextInputType.emailAddress,
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextfield(
                      controller: phoneController,
                      focusNode: _phoneFocus,
                      maxLength: 10,
                      validator: _validatePhone,
                      hintText: 'Phone Number',
                      keybordType: TextInputType.number,
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.5),borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(7),
                              bottomRight: Radius.circular(17),
                              topLeft: Radius.circular(17),
                              topRight: Radius.circular(7))),
                          child: Center(
                            child: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextfield(
                      controller: passwordController,
                      focusNode: _passwordFocus,
                      obscureText: !_isPasswordVisible,
                      sufixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          icon: Icon(_isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined)),
                      validator: _validatePassword,
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      onPressed: handleSignUp,
                      child: state.status == AuthStatus.loading ? const CircularProgressIndicator(color: Color(0xffC4D9FF),) : const Text('Login', style: TextStyle(color: Colors.white)),
                      text: 'Create Account',
                    ),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account?  ",
                          style: const TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pop(context);
                                },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}