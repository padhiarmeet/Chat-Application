import 'package:chat_application/core/common/custom_button.dart';
import 'package:chat_application/core/common/custom_textfield.dart';
import 'package:chat_application/data/services/service_locator.dart';
import 'package:chat_application/logic/cubits/auth/auth_state.dart';
import 'package:chat_application/prasantation/home/home_screen.dart';
import 'package:chat_application/prasantation/screens/auth/signup_screen.dart';
import 'package:chat_application/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/ui_utils.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  final TextEditingController emailConstroller = TextEditingController();
  final TextEditingController passwordConstroller = TextEditingController();

  bool _isPasswordVisible = false;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

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

  Future<void> handleSignIn()async{
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signIn(
            email: emailConstroller.text,
            password: passwordConstroller.text,
            );
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }

    } else {
      print("Form is invalid");
    }

  }

  @override
  void dispose(){
    emailConstroller.dispose();
    passwordConstroller.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit,AuthState>(
      bloc: getIt<AuthCubit>(),

        listener:(context, state) {
        if(state.status == AuthStatus.authanticate){
        getIt<AppRouter>().pushAndRemoveUntil(const HomeScreen());
        }
        else if (state.status == AuthStatus.error && state.error != null) {
        Ui_utils.showSnakeBar(context, message: state.error!);
        }
        },
        builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
       body: Form(
         key: _formKey,
           child: SingleChildScrollView(
             padding: const EdgeInsets.symmetric(horizontal: 20.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
             const SizedBox(height: 30,),
             Text('Welcome Back',style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight :FontWeight.bold),),
             const SizedBox(height: 10,),
             Text('signIn to continue',style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
             const SizedBox(height: 35,),
             CustomTextfield(
               controller: emailConstroller,
               validator: _validateEmail,
               focusNode: _emailFocus,
               hintText: 'Email',
               prefixIcon: Icon(Icons.email_outlined),),
             const SizedBox(height: 16,),

             CustomTextfield(
               controller: passwordConstroller,
               validator: _validatePassword,
               focusNode: _passwordFocus,
               hintText: 'Password',
               obscureText: !_isPasswordVisible,
               sufixIcon: IconButton(
                   onPressed: (){
                     setState(() {
                       _isPasswordVisible = ! _isPasswordVisible;
                     });
                   },
                   icon: Icon(_isPasswordVisible?Icons.visibility_outlined:Icons.visibility_off_outlined)),
               prefixIcon: Icon(Icons.lock_outline),),
             const SizedBox(height: 30,),

             CustomButton(
               onPressed: handleSignIn,
               child: state.status == AuthStatus.loading? const CircularProgressIndicator():const Text('Login',style: TextStyle(color: Colors.white),),
               text: 'Login',),
             const SizedBox(height: 10,),
             Center(
               child: RichText(text: TextSpan(text: "Don't have an account?  ",style: TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(text: 'Sign up',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,),
                            recognizer: TapGestureRecognizer()..onTap = (){
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupScreen()));
                              getIt<AppRouter>().push(const SignupScreen());
                            }
                      )
                    ])),
             )
                        ],
                      ),
           )),
      );}
    );
  }
}
