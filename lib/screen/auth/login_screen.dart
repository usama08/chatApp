import 'dart:developer';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechatapp/Helper/show_dialgue.dart';
import 'package:wechatapp/screen/Api/apis.dart';
import 'package:wechatapp/screen/auth/signup.dart';
import 'package:wechatapp/screen/auth/textfield.dart';
import '../../main.dart';
import '../home_screen.dart';

//login screen -- implements google sign in or sign up feature for app
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  void initState() {
    super.initState();

    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }

  // handles google login button click
  _handleGoogleBtnClick() {
    //for showing progress bar
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      //for hiding progress bar
      Navigator.pop(context);

      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExists())) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something Went Wrong (Check Internet!)');
      return null;
    }
  }

  ///===================function for sign in ==============================///

  Future<dynamic> signInEmailPassword(context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text.trim().toString(),
              password: password.text.trim().toString());

      if (userCredential.user != null) {
        // Navigate to the home page
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          },
        );

        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) =>  ),
        // );
      }
      // print("here is details ${userCredential}");
      // User? user = userCredential.user;
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('$e');

      return false;
    } catch (e) {
      return false;
    }
  }

  // sign out function
  // _signOut() async {
  //   await FirebaseAuth.instance.signOut();
  //   await GoogleSignIn().signOut();
  // }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      //app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to We Chat'),
      ),

      //body
      body: Stack(children: [
        //app logo
        AnimatedPositioned(
            top: mq.height * .15,
            right: _isAnimate ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset('images/icon.png')),
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                customtextfield(context, TextInputType.text, email,
                    'Username *', false, null, null),
                SizedBox(
                  height: 15,
                ),
                customtextfield(
                  context,
                  TextInputType.text,
                  password,
                  'Password *',
                  true,
                  null,
                  Icons.remove_red_eye,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: mq.height * .25,
          left: mq.width * .05,
          width: mq.width * .9,
          height: mq.height * .06,
          child: submittButton(
            context,
            250.0,
            45.0,
            Colors.blue,
            () async {
              signInEmailPassword(context);
            },
            "Login",
            Colors.white,
          ),
        ),
        //google login button
        Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .06,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handleGoogleBtnClick();
                },

                //google icon
                icon: Image.asset('images/google.png', height: mq.height * .03),

                //login with google label
                label: RichText(
                  text: const TextSpan(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      children: [
                        TextSpan(text: 'Login with '),
                        TextSpan(
                            text: 'Google',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                ))),
        const SizedBox(height: 10.0),
        Positioned(
          bottom: mq.height * .18,
          left: mq.width * .05,
          width: mq.width * .9,
          height: mq.height * .06,
          child: accounttext(context, 'if you have no Login?', "SignUp in", () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SignUpScreen()));
          }),
        ),
      ]),
    );
  }

  ////////////////////// ---------------  FinalButton  -------------------- //////////////
  Widget submittButton(BuildContext context, width, height, color,
      Function() onpress, presstext, textcolor) {
    return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          onPressed: onpress,
          // Navigator.pushNamed(context, 'verify');

          child: Text(presstext,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: textcolor,
                  fontSize: 20,
                  fontWeight: FontWeight.normal)),
        ));
  }
}
