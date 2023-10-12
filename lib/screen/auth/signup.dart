import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:wechatapp/screen/auth/login_screen.dart';
import 'package:wechatapp/screen/auth/textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phoneno = TextEditingController();
  TextEditingController countryController = TextEditingController();
  bool isLoading = false;
  bool isMalePressed = false;
  bool isFemalePressed = false;
  var genderis;
  // ignore: non_constant_identifier_names
  static bool isOnline = false;
  static var pushToken = "";
  @override
  void initState() {
    super.initState();
  }

// =========================== token ==============================///
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        pushToken = t;
        // log('Push Token: $t');
      }
    });

    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  ///========================= function for creating account======================///

  Future<dynamic> registerEmailPassword(context) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text.trim().toString(),
              password: password.text.trim().toString());
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid.trim().toString())
            .set({
          "id": userCredential.user!.uid.trim(),
          "name": firstname.text.trim(),
          "Lastname": lastname.text.trim(),
          "email": email.text.trim(),
          "Gender": genderis,
          "created_at": time,
          "about": "Hey, I'm using We Chat!",
          'is_oonline': isOnline,
          "last_active": "",
          "push_token": pushToken,
        });
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 2,
              ),
            );
          },
        );

        await Future.delayed(const Duration(seconds: 3));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        // // Navigate to the home page

        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) =>  ),
        // );
      }
      // User? user = userCredential.user;
      return userCredential.user!.uid;
    } on FirebaseAuthException catch (e) {
      print('$e');

      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 100.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Sign Up',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Wrap(
              spacing: 30,
              runSpacing: 10,
              children: [
                InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    setState(() {
                      isMalePressed = !isMalePressed;
                      isFemalePressed = false;
                      if (isMalePressed) {
                        genderis = "Male";
                      } else {
                        genderis = "";
                      }
                    });
                  },
                  child: actionButton(
                    context,
                    isMalePressed
                        ? Color.fromARGB(255, 219, 40, 97)
                        : Color.fromARGB(255, 222, 222, 220),
                    "Male",
                    isMalePressed ? Colors.white : Colors.black,
                  ),
                ),
                InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    setState(() {
                      isFemalePressed = !isFemalePressed;
                      isMalePressed = false;
                      if (isFemalePressed) {
                        genderis = "Female";
                      } else {
                        genderis = "";
                      }
                    });
                  },
                  child: actionButton(
                    context,
                    isFemalePressed
                        ? Color.fromARGB(255, 219, 40, 97)
                        : Color.fromARGB(255, 222, 222, 220),
                    "Female",
                    isFemalePressed ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    customtextfield(context, TextInputType.text, firstname,
                        'First Name *', false, null, null),
                    SizedBox(
                      height: 15.0,
                    ),
                    customtextfield(context, TextInputType.text, lastname,
                        'Last Name *', false, null, null),
                    SizedBox(
                      height: 15.0,
                    ),
                    customtextfield(context, TextInputType.text, email,
                        'Email *', false, null, null),
                    SizedBox(
                      height: 15.0,
                    ),
                    customtextfield(context, TextInputType.text, password,
                        'Password *', false, null, null),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            submittButton(
              context,
              double.infinity,
              45.0,
              Color.fromARGB(255, 219, 40, 97),
              () {
                if (firstname.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your First Name is Empty*'),
                    ),
                  );
                } else if (lastname.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your Last Name is Empty*'),
                    ),
                  );
                } else if (email.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your Email Name is Empty*'),
                    ),
                  );
                } else if (password.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your Password Name is Empty*'),
                    ),
                  );
                } else {
                  registerEmailPassword(context);
                }
              },
              "SignUp",
              Colors.white,
            ),
            const SizedBox(height: 10.0),
            Text(
              "or",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.blue,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
            ),
            const SizedBox(height: 10.0),
            accounttext(context, 'Already a Member?', "Log in", () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget actionButton(BuildContext context, color, gender, color2) {
    return Container(
      width: 140.0,
      height: 50.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        gender,
        style: Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(color: color2, fontWeight: FontWeight.normal),
      ),
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
